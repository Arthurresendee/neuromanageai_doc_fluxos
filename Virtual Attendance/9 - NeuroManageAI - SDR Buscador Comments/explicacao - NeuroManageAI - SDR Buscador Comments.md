## Dúvidas

## Possíveis correções/ melhorias:

## Objetivo

Enviar mensagem inicial por WhatsApp para leads da base de comentários (Comments), a partir da tabela qualified_leads_comments.


## Inicio (Schedule)

- Cron: entre 8h e 12h, seg a sex.
- Dispara o fluxo automaticamente no período configurado.


## Credenciais

- Define supabase_url, supabase_apikey, wa_instance.


## Lista

- Busca ate 10 leads onde Data Mensagem Whatsapp e nula.
- Atenção: no JSON a URL ainda aponta para "Qualified Leads - ICP"; para Comments deve apontar para a tabela qualified_leads_comments.


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

Tabela: qualified_leads_comments

- Atualizam Data Mensagem Whatsapp e Mensagem Enviada Whatsapp.
- Recomendado: usar filtro por Telefone (não por Nome). Verificar referência $('Enviar texto') vs $('whatsapp').


## Execute a SQL query

- Atualiza mensagem_enviada_em em várias tabelas (incluindo qualified_leads_comments).
