# NeuroManageAI - Leads Enrichment for Email and Phone

## Objetivo

Basicamente enriquecer as tabelas de leads com informações do tipo **email** e **telefone**, com base na busca do perfil utilizando a URL do LinkedIn.

---

## Sequência dos nodes (ordem de execução)

### Webhook

- Início do fluxo e gatilho para os demais nodes serem executados.

### Edit Fields

- Gera um número random inteiro de 0 a 20, usado posteriormente.

### Wait

- O fluxo aguarda a quantidade de tempo gerada anteriormente de forma aleatória.

### Get many rows - ICP

- Busca até 200 registros onde `Telefone` is null na tabela `qualified_leads_icp`.

### Get many rows - Comments

- Busca até 200 registros onde `Telefone` is null na tabela `qualified_leads_comments`.

### Get many rows - Maps

- Busca até 200 registros onde `Telefone` is null na tabela `qualified_leads_google_maps`.

### Get many rows - Jobs

- Busca até 200 registros onde `Telefone` is null na tabela `qualified_leads_jobs_offers`.

### Merge

- Junta os dados de todos os Gets em um único fluxo de itens.

### Sort

- Ordena os leads a partir do campo `lead_score` em ordem decrescente.

**Por que existe:**
- Processar primeiro os leads de maior valor potencial.
- Otimizar uso de crédito/chamada da API externa.

### Limit

- Limita a execução para no máximo 100 itens.

**Por que existe:**
- Controle de custo e tempo por rodada.
- Evita execuções muito longas.

### Sales SQL Person Enrich (HTTP Request)

**O que faz:**
- Chama a API: `GET https://api-public.salesql.com/v1/persons/enrich`
- Envia query param: `linkedin_url = {{ $json["URL Linkedin"] }}`
- Headers:
  - `Authorization: Bearer ...`
  - `accept: application/json`

**Saída:**
- Resposta de enriquecimento com possíveis arrays `emails` e `phones`.

### If1

**O que faz:**
- Condição 1: `emails` não vazio **OU**
- Condição 2: `phones[0].phone` não vazio
- Combinador: **OR**

**Saída:**
- **Verdadeiro:** segue para updates nas tabelas.
- **Falso:** não atualiza.

**Por que existe:**
- Impede gravação vazia/inútil no banco.
- Garante update apenas quando houve enriquecimento válido.

### Update ICP

- **Tabela:** `qualified_leads_icp`
- **Condição de update:** o link do LinkedIn ser o mesmo que vem do banco.
- **Normalização:** URL Linkedin = `linkedin_url` normalizado para `https://www.`

### Update Comments

- **Tabela:** `qualified_leads_comments`
- Mesma lógica do Update ICP, aplicada na base de comments.

### Update Maps

- **Tabela:** `qualified_leads_google_maps`
- Mesma lógica de filtro e campos de update.

### Update Jobs

- **Tabela:** `qualified_leads_jobs_offers`
- Mesma lógica de filtro e campos de update.

---

## O que acontece com dados sem retorno da API?

Se a SalesQL **não** retornar e-mail nem telefone:

- o item não passa no If1;
- nenhum update é executado;
- o registro permanece sem contato para uma tentativa futura.

**Motivo dessa estratégia:**
- Evita gravar dados inúteis.
- Preserva qualidade da base.
- Mantém rastreabilidade do que foi realmente enriquecido.

---

## Visão geral

Em cada execução, o workflow:

1. Recebe o gatilho por webhook.
2. Cria um atraso aleatório para distribuir carga.
3. Busca leads sem telefone nas 4 bases.
4. Junta tudo, prioriza por `lead_score` e limita em 100.
5. Envia cada LinkedIn para enriquecimento na SalesQL.
6. Só aceita itens com retorno útil (email ou telefone).
7. Grava os contatos encontrados nas tabelas do Supabase.

---

## Dúvidas

- Qual o gatilho para esse workflow ser ativado?
- Qual o objetivo do campo `lead_score` das tabelas de leads qualificados? Todos os valores estão persistidos com valor 0. Em que momento é definido?

---

## Possíveis correções / melhorias

- `Outros Telefones` está recebendo também JSON de e-mails — ideal separar em `Outros Emails` e `Outros Telefones`.
- O token Bearer está fixo no node HTTP Request. Ideal: mover para credencial segura do n8n ou variável de ambiente.
