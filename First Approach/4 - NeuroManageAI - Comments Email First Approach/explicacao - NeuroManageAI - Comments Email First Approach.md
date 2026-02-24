## Dúvidas

## Possíveis correções/ melhorias:

## Objetivo

Executar uma cadencia de first approach por e-mail para leads da base Comments, gerando mensagem personalizada com IA, enviando por contas rotativas de Gmail, registrando o que foi enviado no Supabase e respeitando intervalos de envio para reduzir risco de bloqueio/spam.

## webhook

- Inicia o fluxo por chamada POST.

## edit Fields

- Gera um número random inteiro de 0 a 10, usado posteriormente.

## wait

- O fluxo trava e vai esperar a quantidade de tempo em minutos gerado anteriormente de forma aleatória.

Por que existe:

## Get many rows

Tabela: qualified_leads_comments

O que faz:
- Carrega leads com e-mail disponivel. Como esse é um fluxo de envio de emails, Obrigatóriamente deve haver email.

## If5

Regra:
- Mensagem Enviada Email esta vazia.

O que faz:
- Mantem apenas leads ainda nao contactados por e-mail.
- Evita duplicidade de disparo e reduz risco de spam/repeticao.

## Sort

Ordenação
- Data Mensagem LinkedIn desc

O que faz:
- Ordena por Data de mensagem mais recente

## Limit5

Configuracao:
- maxItems: 25
- keep: lastItems

- Limita o processamento a 25 leads por execucao.

## Add index to each item

Garante que cada lead tenha um emailIndex (0 a 4) para o Switch decidir por qual conta de e-mail aquele lead vai ser enviado.

1º lead → conta 0
2º lead → conta 1
…
6º lead → conta 0 de novo
etc.

## Loop Over Items1

- Processa item a item da lista

## Switch

- Distribui cada lead para uma faixa de envio.

Regras:
- emailIndex = 0
- emailIndex = 1
- emailIndex = 2
- emailIndex = 3
- emailIndex = 4

## Importante aqui

Depois do Switch, a lógica (agente, prompt, RAG, formatação) é a mesma nos 5 ramos. O que muda é só quem envia e como o resultado é amarrado ao lead.

## If (Após switch)

O que faz: Verifica se o campo Mensagem Enviada Email do lead está vazio.

- Só deixa seguir para o Email Agent e para o envio quem ainda não foi contactado por e-mail

## Agent Node (x5)

- Recebem dados do lead e geram JSON final:
  { to, subject, message }

## OpenAI Chat Model / OpenRouter Chat Model (x5)

- É um modelo de linguagem da Openai, GPT 4.1-mini
- Enviamos todos os dados, prompt, etc... e recebemos uma respostade volta.
- Se o modelo principal falhar, usamos o pre-definido no open router

## CONSULTA AO SCRIPT / Vector Store Supabase

Tabela vetorial: documents_email
- base de dados usado para consultas RAG e informações específicas.

## Embeddings OpenAI (x5) +

- Melhora o contexto das informações recuperadas, gerando embedding e

## Reranker Cohere (x5)

- O Reranker Cohere é um componente da integração do LangChain com Cohere dentro do n8n.
- Ele serve para reordenar (rerank) uma lista de resultados ou documentos com base em relevância, usando os modelos de linguagem da Cohere.
- Em fluxos de IA, isso é útil quando você tem várias respostas ou documentos recuperados (por exemplo, de uma busca em base de conhecimento) e quer que o modelo indique quais são os mais relevantes para a consulta do usuário.

## Code in JavaScript

- Separa paragrafo em pontos-chave (saudacao, dor, proposta, CTA, assinatura)
- Normaliza quebras de linha.
- Cria versao HTML via replace(\n -> <br>)

## Send a message

- Envia o Fato o email, passando informações como to/subject/message

## Update a row

Campos atualizados:
- Data Mensagem Email = now
- Mensagem Enviada Email = subject + corpo
- Alimentam os filtros de "ja enviado" nas proximas execucoes

## Wait

- Espera um intervalo entre cada envio
