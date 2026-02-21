# NeuroManageAI - Send LinkedIn Connections Invites

## Objetivo

Disparar convites de conexão no LinkedIn para leads da base, registrar a mensagem/data de envio no banco e fazer uma limpeza de leads sem telefone (de acordo com a regra atual do fluxo).

---

## Sequência dos nodes (ordem de execução)

### Webhook

- Início do fluxo e gatilho para os demais nodes serem executados.

---

### Edit Fields

- Gera um número random inteiro de 0 a 20, usado posteriormente.

---

### Wait

- O fluxo trava e vai esperar a quantidade de tempo em minutos gerada anteriormente de forma aleatória.

**Por que existe:** Introduz variação de tempo para não concentrar execuções no mesmo momento.

---

### Get many rows - ICP

- Busca até 200 registros na tabela `qualified_leads_icp`.

### Get many rows - Comments

- Busca até 200 registros na tabela `qualified_leads_comments`.

### Get many rows - Maps

- Busca até 200 registros na tabela `qualified_leads_google_maps`.

### Get many rows - Jobs

- Busca até 200 registros na tabela `qualified_leads_jobs_offers`.

**Observação importante:** Nesses 4 gets não há filtro de elegibilidade no próprio node. O filtro real acontece depois, no node If.

---

### Merge

- Junta os dados de todos os Gets em um único fluxo de itens.

---

### If

**Regra:**
- `Data Mensagem LinkedIn` deve estar vazia **E**
- `Email` deve estar preenchido

**O que faz:** Filtra para continuar somente com leads que ainda não receberam mensagem no LinkedIn e que têm email.

---

### Sort

- Ordena por `created_at` desc (mais novos primeiro).
- Prioriza leads mais recentes para abordagem.

---

### Limit

- Limita processamento a 25 itens por execução.

---

### Provider ID

- Resolve o `provider_id` (identificador do usuário no provedor) necessário para enviar convite.
- O envio de convite no endpoint de invite precisa do `provider_id`.

**O que faz:** Faz uma requisição HTTP GET na API da Unipile para buscar o usuário do LinkedIn e retornar o `provider_id`. Monta a URL dinamicamente a partir do campo `URL Linkedin` do lead:

```
{{ $json["URL Linkedin"].split('/').pop() }}
```

(ou seja, pega o último trecho da URL, que normalmente é o identificador público do perfil). Envia `account_id` como query param para informar qual conta da Unipile está sendo usada.

#### O que é a Unipile nesse contexto?

A Unipile é o serviço intermediário que permite operar ações de LinkedIn por API (consultar usuário, enviar convite etc.). Nesse fluxo, ela é responsável por:

1. Encontrar o usuário via identificador do perfil.
2. Devolver o `provider_id` que será usado no envio do convite.

#### O que é `account_id` e por que passa aqui?

`account_id` identifica qual conta conectada no Unipile vai executar a ação. Sem esse parâmetro, a API pode não saber qual "identidade" usar para buscar e convidar.

#### O que é `X-API-KEY`?

É a credencial de autenticação da API da Unipile. Serve para autorizar o workflow a consumir esse endpoint.

---

### Edit Fields3

**O que faz:**
- Monta mensagem personalizada: "Olá, {primeiro_nome}! Seria um prazer me conectar com você para trocarmos experiências sobre você e a {empresa}, topa?!"

---

### Send Connection Invite

Envia requisição HTTP POST para o endpoint de convite da Unipile:

```
https://api23.unipile.com:15389/api/v1/users/invite
```

**Configuração:** Processa com `batchSize: 1` e `batchInterval: 600000` (10 minutos entre cada convite). Usado para evitar bloqueios ou restrições de contas.

**Por que essa etapa existe:** É onde o convite de conexão no LinkedIn é efetivamente disparado.

#### O que é o endpoint `/api/v1/users/invite`?

Endpoint da Unipile para enviar convites de conexão no LinkedIn. Recebe:

- **provider_id** – quem convidar
- **account_id** – de qual conta enviar
- **message** – mensagem do convite

---

### Update a row - ICP

**Tabela:** `qualified_leads_icp`

**Campos atualizados:**
- Mensagem Enviada LinkedIn
- Data Mensagem LinkedIn
- Provider ID
- created_at

**Por que existe:** Registrar que houve disparo e quando aconteceu.

---

### Update a row - Comments

**Tabela:** `qualified_leads_comments`  
- Mesmo update do node ICP para a tabela comments.

---

### Update a row - Jobs

**Tabela:** `qualified_leads_comments`

** Ponto de atenção:** Nome indica Jobs, mas `tableId` está como `qualified_leads_comments`. Validar se é intencional.

---

### Update a row - Maps

**Tabela:** `qualified_leads_google_maps`  
- Mesmo update, aplicado na tabela maps.

---

### Merge1

- Pega o campo `user_email` do Input 1.
- Compara com o campo `Email` do Input 2.
- Se os valores forem iguais → combina os objetos.

---

### If1

**O que faz:**
- Se `Telefone` estiver vazio, dispara exclusão do lead nas 4 tabelas.
- Regra atual remove leads sem telefone.

---

### Delete a row (ICP, Comments, Jobs, Maps)

- Deleta por `URL Linkedin` em cada tabela correspondente.

---

## Dúvidas

- Qual o gatilho de disparo desse fluxo? Onde chamam?

---

## Possíveis correções / melhorias

**Possível erro no node "Update a row - Jobs"**

- Nome indica Jobs, mas `tableId` está como `qualified_leads_comments`.
- Validar se é intencional.
