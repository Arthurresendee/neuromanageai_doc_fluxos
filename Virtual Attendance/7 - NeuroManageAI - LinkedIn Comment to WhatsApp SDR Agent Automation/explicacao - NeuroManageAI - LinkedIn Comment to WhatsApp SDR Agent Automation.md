## Dúvidas

## Possíveis correções/ melhorias:

## Objetivo
Automatizar atendimento SDR no LinkedIn: receber comentário em post, iniciar chat via Unipile, montar contexto, responder com IA consultiva (TT&Co) e registrar lead na tabela ttco_qualified_leads_icp. O envio da resposta é sempre pela API Unipile. O canal efetivo (WhatsApp ou LinkedIn) depende da configuração da conta Unipile; a mensagem é formatada para WhatsApp.

## LinkedIn Comment Webhook
- Recebe payload do LinkedIn via Unipile e inicia o fluxo.
- Dois pontos de entrada: comentários públicos e mensagens diretas.

## Listar Comentários
- GET Unipile para buscar comentários do post e identificar o comentarista.

## If2 / Update Qualified Leads Linkedin
- Verifica condição e atualiza resposta_linkedin e Conectado LinkedIn na tabela ttco_qualified_leads_icp.

## INICIAR CHAT / If1 / Create a row1 / Update Qualified Leads Linkedin1
- Inicia conversa direta com o comentarista via Unipile.
- Cria ou atualiza registro do lead com Mensagem Enviada LinkedIn.

## Code in JavaScript
- Parseia body bruto do webhook para extrair event, account_id, chat_id, message, attendee_name, attendee_id, is_sender.

## SET_VARIAVEIS
- Padroniza variáveis: user.name, message.sender, chat_id, fromMe, account_id, user_provider_id.

## Rotas de Mensagens
- Switch que direciona por tipo: Texto, Audio, Imagem, pdf, Erro.

## Nodes de conversão e OpenAI
- Converte audio, imagem e pdf em texto para enviar ao agente.

## Bufferização
Tipo: Redis + Wait + Switch
- Acumula mensagens por tipo (Redis Buffer Texto/Audio/Imagem/pdf/Erro), aguarda janela e consolida em CONCATENAR DADOS.

## Gerenciamento de Usuário (Supabase)
- GET_USER busca lead. Se não existe, CREATE_USER cria. SET_USER padroniza dados.

## Agente de IA (Agent - TT&Co Renttax)
- SDR consultivo sobre Reforma Tributária.
- OpenAI Chat Model + Postgres Chat Memory (por chat_id).
- Tools: criar_reuniao, reagendar_reuniao, cancelar_reuniao, verificar_disponibilidade.
- RAG: Vector Store Supabase (neuromanageai_documents_linkedin).
- Redis controla status AGENTE_OFF para handoff humano.

## Split de Mensagem / LOOP_SLIT / WAIT_SPLIT / Send Message via Linkedin
- LLM Chain divide resposta em até 4 blocos curtos (max 150 chars), com regras de markdown do WhatsApp.
- Loop envia cada bloco via API Unipile: POST https://api23.unipile.com:15389/api/v1/chats/{chat_id}/messages.
- Canal de envio: WhatsApp ou LinkedIn conforme conta Unipile.




