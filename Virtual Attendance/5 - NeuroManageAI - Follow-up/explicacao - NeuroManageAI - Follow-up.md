## Dúvidas

## Possíveis correções/ melhorias:

## Objetivo

Executar a cadência de Follow-up no WhatsApp com base na tabela follow_up.

## Schedule Trigger / Start

- Inicia a execucao automatica da cadencia em intervalos definidos no n8n

## Get many rows / BUSCAR TABELA FOLLOWUP / BUSCAR STATUS DO FOLLOWUP

- Le os contatos e seus estados atuais na tabela follow_up

## Loop Over Items

- Processa cada contato individualmente buscado no banco.

## VERIFICAR STATUS

- pendente -> segue para calculo de tempo e condicoes.
- concluido -> nao envia.
- cancelado -> nao envia.

## CONVERTER TEMPO / TEMPO / TEMPO 2

Calcula os minutos passados (minutes_passed) com base na última mensagem (last_message)

====================
==== Importante ====
====================

Como o fluxo a partir daqui faz a mesmo coisa em todos os IFs vamos ver apenas um, A única diferenca é a contagem de tempo para cada follow Up.

## IFs

- Verifica se minutes_passed passou do limite e se a flag da etapa ainda esta false.

## FOLLOWUP

- Define o texto da mensagem da etapa.

## ENVIA_FOLLOWUP

- API http://evolution-api:8080/message/sendText/Menthalis

- Realiza envio no canal WhatsApp via Evolution API.

## UPDATE_FOLLOWP

- Atualiza a flag da etapa enviada (followup_*_sent = true), usado como filtro anteriormente

## Wait1 / Wait2

- Aplica um intervalo durante o fluxo.



































