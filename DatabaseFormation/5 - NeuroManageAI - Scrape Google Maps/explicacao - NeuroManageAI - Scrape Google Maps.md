# NeuroManageAI - Scrape Google Maps

## Dúvidas

- Qual o gatilho de disparo desse fluxo? Onde chamam?

## Possíveis correções / melhorias

*(a preencher)*

---

## Objetivo

Prospecção de busca no Google Maps: passa por enriquecimento no LinkedIn, filtra os leads qualificados e grava na tabela `neuromanageai_qualified_leads_google_maps` através de um upsert.

---

## Nodes do fluxo

### Webhook

- Início do fluxo; gatilho para o restante dos nodes serem executados.

### Edit Fields (random)

- Gera um número aleatório inteiro de 0 a 10, usado posteriormente.

### Wait

- O fluxo aguarda a quantidade de tempo (em minutos) gerada anteriormente de forma aleatória.

**Por que existe:** introduz variação de tempo para não concentrar execuções no mesmo momento.

### Edit Fields (parâmetros da campanha)

- Define os parâmetros-base da campanha:
  - **Setor:** "Supermercados, Atacados, Shoppings, Dentista, Loja"
  - **Número de Leads:** 1
  - **Local:** "São Paulo, Belo Horizonte, Rio de Janeiro"

### Segreggate Input

- Quebra campos de entrada por vírgula (setores e locais).
- Remove duplicatas de setores com `Set`.
- Gera 1 item por local, mantendo array de setores e número de leads.

### Google Maps Scrape

**Actor:**  
[https://console.apify.com/actors/nwua9Gu5YrADL7ZDj/input](https://console.apify.com/actors/nwua9Gu5YrADL7ZDj/input)

- Busca estabelecimentos no Google Maps usando os parâmetros configurados.
- Retorna resultados de empresas/locais encontrados.

#### O que é Apify? O que é Ator? O que é o ID na URL?

**O que é a Apify?**  
A Apify é uma plataforma que hospeda "robôs" prontos de scraping. Em vez de desenvolver e manter scrapers para cada site (LinkedIn, Google, etc.), você usa esses robôs pela API, passando parâmetros e recebendo os dados estruturados.

**O que é um Actor (ator)?**  
Um Actor é um desses robôs na Apify: um script pronto para extrair dados de um site ou serviço. Exemplos:

- **LinkedIn Profile Scraper** – busca perfis por cargo, indústria, localização
- **LinkedIn Company Scraper** – extrai dados de páginas de empresas
- **Google Maps Scraper** – extrai estabelecimentos do Google Maps

Cada Actor tem um **ID único** que a Apify usa para identificar qual robô executar. É parecido com o ID de um pacote no npm ou de uma biblioteca em um repositório.

**Por que usamos o "Request Actor" (passamos o ID)?**

| Pergunta        | Resposta                                                                 |
|-----------------|---------------------------------------------------------------------------|
| Quem executa?   | A Apify.                                                                  |
| O que executar? | O Actor indicado pelo ID.                                                 |
| Com quais parâmetros? | O que vem do node anterior (o `customBody` = JSON da query).       |

Quando configuramos `actorId: UwSdACBp7ymaGUJjS`, estamos dizendo ao n8n:

> "Chame a Apify e peça para ela rodar o Actor com ID UwSdACBp7ymaGUJjS."

---

### If3

**O que faz:**

- Permite seguir apenas itens com telefone presente.
- Evita gastar chamadas em registros fracos para contato comercial.

### Aggregate

**O que faz:**

- Consolida títulos coletados para envio ao próximo Actor.

### Scrape Companies

**Actor:**  
[https://console.apify.com/actors/UwSdACBp7ymaGUJjS/input](https://console.apify.com/actors/UwSdACBp7ymaGUJjS/input)

**O que faz:**

- Recebe os títulos agregados e busca empresas no LinkedIn.
- Sem essa etapa, não haveria busca de funcionários.

### Location, Employees and HR filter

- Filtra empresas por geografia, setor indesejado e tamanho.
- Mantém empresas brasileiras; exclui nicho não desejado (HR).

### Loop Over Items

**O que faz:**

- Processa empresas de 10 em 10 (Batch Size = 10).

### Aggregate1

**O que faz:**

- Junta URLs de empresas para alimentar o scrape de funcionários.

### Scrape Employees (dentro do loop)

**O que faz:**  
Para cada empresa da lista, são buscados funcionários relacionados a esse estabelecimento.

**Actor:**  
[https://console.apify.com/actors/Vb6LZkh4EqRlR0Ka9/input](https://console.apify.com/actors/Vb6LZkh4EqRlR0Ka9/input)

- Busca perfis de colaboradores associados às empresas filtradas.
- Gera o insumo principal para outreach futuro (nome, cargo, LinkedIn, e-mail etc.).

### Filter empty outputs

- Descarta outputs vazios ou inválidos do scrape de funcionários.
- Impede que itens sem dados atrapalhem o parse, merge e upsert.

### Filter companies that have Linkedin profiles

- Filtra itens com website de empresa preenchido.

### Parse Output

- Normaliza o retorno bruto de pessoas em schema padrão.
- Padroniza a estrutura para integração com o banco.

Após sair do loop, o fluxo segue para o **Merge** (juntar os dados coletados).

### Merge

**Regra de join:**

- `website` (ramo empresa) = `company_website` (ramo pessoa)

- Une contexto empresarial e contexto pessoal em um único item.
- Sem o merge, você teria duas metades de informação desconectadas.

### Upsert Supabase

**Tabela:** `neuromanageai_qualified_leads_google_maps`

**Endpoint:**  
`/rest/v1/neuromanageai_qualified_leads_google_maps`

- Persiste o registro final no banco com estratégia de upsert.

Além dos parâmetros **apikey**, **Authorization** e **Content-Type**, há o header **Prefer** com:

| Valor                     | Significado                                                                 |
|---------------------------|-----------------------------------------------------------------------------|
| `return=representation`   | Retorna os registros criados ou atualizados no corpo da resposta.          |
| `resolution=merge-duplicates` | Em conflito de chave única: em vez de erro, atualiza o registro existente (merge). |

---

## Resumo do fluxo

Esse fluxo descobre empresas no Google Maps, valida no LinkedIn, busca funcionários, normaliza os dados e grava no Supabase com deduplicação.
