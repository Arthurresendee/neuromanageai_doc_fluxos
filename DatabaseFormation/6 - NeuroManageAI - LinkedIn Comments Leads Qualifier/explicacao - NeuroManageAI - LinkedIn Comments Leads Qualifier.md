## Dúvidas

- Qual o gatilho de disparo desse fluxo? Onde chamam?

## Possíveis correções/ melhorias:

## Objetivo

Encontrar leads qualificados no LinkedIn a partir de posts com comentarios, enriquecer os perfis (pessoa + empresa), aplicar filtros de ICP e gravar o resultado na tabela qualified_leads_comments

## webhook

- Início do fluxo, gatilhos para o restantes dos nodes serem executados

## Edit Fields2

- Gera um número random inteiro de 0 a 59, usado posteriormente.

## wait

- O fluxo trava e vai esperar a quantidade de tempo em minutos g  erado anteriormente de forma aleatória.

Por que existe:
- Introduz variacao de tempo para nao concentrar execucoes no mesmo momento.

## Users Keywords

- Define array de keywords (foco odontologia/saude oral e variacoes).
- ex:"["odontologia", "dentista", "clinica odontologica", "saude", "saude oral", "sorriso", "estetica", "bem estar", "tratamento", "atendimento", "implante", "ortodontia", "clareamento", "proteses", "cirurgiaoral", "canal", "limpeza", "aparelho", "harmonizacao", "esteticaoral", "harmonizacaofacial", "sorriso perfeito", "autoestima", "qualidade", "odontogram", "odontolovers", "vidadeodontista", "rotinaodontologica", "odontopost", "odontobrasil", "odontologia", "saude", "clinicas"]"

## Random Selector

- Embaralha a lista de keywords com Fisher-Yates.
- Seleciona 15 termos aleatorios.
- Retorna a quantidade de selectedKeywords.
- Evita sempre buscar os mesmos termos na mesma ordem.

## Split Out1

O que faz:
- Quebra selectedKeywords em itens individuais (1 item por keyword).
- Permite executar busca de posts por termo, de forma controlada.

## Scrape For Posts URL

- Busca URLs de posts recentes do LinkedIn por palavra-chave.

## O que é API Fy? O que é Ator? O que é o Id que fica na URL da requisição?

O que é a Apify?
A Apify é uma plataforma que hospeda "robôs" prontos de scraping. Em vez de você desenvolver e manter scrapers para cada site (LinkedIn, Google, etc.), você usa esses robôs pela API, passando parâmetros e recebendo os dados estruturados.

O que é um Actor (ator)
Um Actor é um desses robôs na Apify: um script pronto para extrair dados de um site ou serviço.
LinkedIn Profile Scraper – busca perfis por cargo, indústria, localização
LinkedIn Company Scraper – extrai dados de páginas de empresas
Google Maps Scraper – extrai estabelecimentos do Google Maps
Cada Actor tem um ID único que a Apify usa para identificar qual robô executar. É parecido com o ID de um pacote no npm ou de uma biblioteca em um repositório: é o que identifica exatamente qual Actor você está chamando.

Por que usamos o “Request Actor” (passamos o ID)
Quem executa? → A Apify.
O que executar? → O Actor indicado pelo ID.
Com quais parâmetros? → O que vem do node anterior (o customBody = JSON da query).
Quando configuramos actorId: 5QnEH5N71IK2mFLrP, estamos dizendo ao n8n:
> "Chame a Apify e peça para ela rodar o Actor com ID 5QnEH5N71IK2mFLrP."

## Filter Commented Posts

Regra:
- stats.comments >= 1
- Mantem apenas posts que realmente tiveram comentarios.
- Remove posts que não contenham comentarários

## Remove Duplicates

- post_url
- Elimina URLs de posts repetidas.
- Evita reprocessamento do mesmo post.

## Aggregate

- Prepara o link dos posts para o scrap de comentário de posts

## Scrape For Posts Comments

- Coleta os comentarios dos autores dos comentarios.
- Creio que esse seja a parte principal do fluxo. Aqui é onde encontramos os potenciais

## Edit Fields

- Padroniza os campos que vieram dos comentarios.
Mapeamentos principais:
- comment = text
- author_name = author.name
- author_headline = author.headline
- author_linkedin_profile = author.profile_url
- comment_date = posted_at.date
- post_input_url = post_input

## Remove Duplicates1

Campo:
- author_linkedin_profile

O que faz:
- Remove perfis repetidos de comentaristas.
- Evita enriquecer e gravar o mesmo lead varias vezes na mesma execucao.

## Aggregate1

-Agrega a urls dos perfis para coleta de informações dos autores no próximo scrap.

## Scrape Profiles1

- enrique dados do leads com informações pessoais igual nós já fizemos várias vezes em outros fluxos (experiencia, empresa atual, localizacao etc.).

## Empty spaces

- Filtra perfis incompletos sem URL valida ou sem empresa vinculada.
- Garante qualidade minima antes de enriquecer empresa e seguir para merge. Pois no próximo scrap, buscamos pela empresa. E se não tem empresa, é um lead inválido.

## Remove Duplicates2

- Remover informações de perfis duplicadas.

## Aggregate3

- Agrupa URLs de empresas dos leads para scrape de company. Pois o próximo scrap é para buscar essas empresas.

## Scrape Companies

Actor: AjfNXEI9qTA2IdaAX
- Busca e dados da empresa (website, descricao, headcount etc.).

## Filter Employees Count

Regras:
- employeeCount >= 10
- employeeCount <= 100

- Mantem empresas com quantidade de funcionários desejado.

## Loop Over Items4

- Agora que temos uma lista de empresas, precisamos buscar os funcionários de cada uma com o próximo scrap. Por isso precisamos desse loop

## Filter BR located Leads

- Mantem apenas leads/empresas localizados no Brasil. usando o filtro
- location.countryCode == BR
- ou location.countryCode == br

## Merge4

- Une as informações de empresa com funcionário.

## Create a row1

tabela: qualified_leads_comments
- Por fim, armazemos todas essas informações estruturadas no perfil de cada lead dentro do banco.
