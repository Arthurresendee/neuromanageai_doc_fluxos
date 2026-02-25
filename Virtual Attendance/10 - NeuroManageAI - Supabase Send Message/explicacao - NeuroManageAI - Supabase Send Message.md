## Dúvidas

## Possíveis correções/ melhorias:

## Objetivo

Enviar mensagem inicial por WhatsApp para leads carregados do Supabase (via API REST). O fluxo busca registros com Data Mensagem Whatsapp nula, gera mensagem com agente SDR e atualiza data/mensagem na tabela no Supabase. No estado atual usa a tabela qualified_leads_comments nos updates.


## Execute Workflow Trigger (subworkflow)

- O fluxo nao possui Cron/Schedule. E acionado quando outro workflow o chama (Execute Workflow Trigger); recebe dados do workflow pai.


## Credenciais

- Define supabase_url, supabase_apikey, wa_instance.
- A URL deve apontar para a mesma tabela usada nos updates (ex.: Qualified Leads - Comments).


## Lista

- GET REST ao Supabase: ate 10 leads onde Data Mensagem Whatsapp e nula.
- Atenção: no JSON a URL aponta para "Qualified Leads - ICP"; os updates usam qualified_leads_comments. Alinhar à tabela desejada.


## Organiza contatos

- Normaliza Telefone (só números, prefixo 55 se faltar).


## Loop Over Items

- Processa cada lead da lista individualmente. Ao acabar, sai para o próximo node.


## Delay / Wait / Horario / If

- Delay aleatório 30–60 s, espera, verificação se hora < 19:00; se for >= 19 não envia.


## Prepara dados para agente

- Prepara para o agente: leadName (Empresa), leadPhone, leadEmail, chatInput.


## Agent

- Gera mensagem de first approach SDR (persona Gabriel, NeuroManageAI). Modelo: gpt-4.1-mini.


## whatsapp

- Envia a mensagem gerada para o lead.


## registra mensagem enviada

- Formata telefone do retorno e data_envio.


## If1

- Sucesso: Registra Mensagem. Erro: Registra erro e volta ao Loop.


## Registra Mensagem / Update Mensage / Update Data Mensage

Tabela (conforme JSON): qualified_leads_comments

- Atualizam Data Mensagem Whatsapp e Mensagem Enviada Whatsapp.
- Recomendado: filtro por Telefone (não por Nome). Verificar referência $('Enviar texto') vs $('whatsapp').


## Execute a SQL query

- Atualiza mensagem_enviada_em em várias tabelas (icp, google_maps, jobs_offers, comments).
