## Dúvidas

## Possíveis correções/ melhorias:

## Objetivo

Disparar, em horarios definidos (dias uteis, manha), um resumo das bases de leads por e-mail

## Webhook

- Ponto inicial do fluxo. É onde tudo começa. É basícamente um endpoint POST

## Target Keywords

- Define array de keywords de nicho (odontologia, dentista, ortodontia, implante etc.).

## Random Keyword Selector

- Embaralha a lista de keywords
- Seleciona as 3 primeiras apos embaralhar.
- Retorna selectedKeywords, totalOriginal e totalSelected.

- Evita sempre consultar as mesmas hashtags na mesma ordem.

## Split Keywords

- Divide selectedKeywords em itens individuais, podenso fazer scrap por termo separadamente

## Scrape Instagram Reels

ator: reGe1ST3OBgYZSsZJ

- Busca reels por hashtag no Instagram, para posteriormente procurar por comentários relevantes.
- O codigo remove pontuacao/simbolos da keyword antes de enviar.

## Filter Commented Posts

Regra:
- commentsCount >= 1
- Mantem apenas posts com comentarios.
- Como esse automação depende dos comentários para achar prospectar, dependemos desse filtro

## Aggregate Post URLs

- Organiza URLs dos posts para o proximo scrape.

## Scrape Post Comments

- Coleta comentarios dos posts e metadados dos autores.

## Aggregate Usernames

- Agrupa usernames dos autores coletados.
- Cria uma base para verificar na tabela cache do supabase.

## Deduplicate Instagram Users

- Remove duplicatas entre itens.
- So retorna itens com usernames novos.
- Evita processamento repetido dentro da mesma execucao.

## Check Supabase Cache

Tabela:
- instagram_prospects_cache

- Verifica se username ja esta salvo no banco.
- Evita reprocessar perfis ja descobertos em execucoes anteriores.

## Aggregate Non-Cached Users

- Agrega os usuários que já estão em cache

## Prepare Usernames for Scraping

- Le todos os usernames deduplicados da etapa anterior.
- Remove do conjunto final quem ja existe no banco.
- Retorna:
  - usernames_to_scrape
  - count
  - total_original
  - cached_count

- Garante que apenas usuarios novos avancem para próximo scrape.

## Scrape Instagram Profiles

ator dSCLg0C3YEZ83HzYX

- Busca dados de perfil desses usuarios novos.

## Parse Bio Smart

- tenta extrair local por padroes (UF, cidades BR, emojis de localizacao).
- tenta inferir titulo/profissao
- Monta objeto output padronizado
- Transforma bio livre em dado estruturado utilizavel no funil.
- location/title recebem "NÃO FOI POSSÍVEL DETERMINAR" quando nao encontrados.

## Filter Has Title

- Mantem apenas perfis onde foi possivel identificar um titulo.

## Filter Keywords Early

- Normaliza texto (sem acento/pontuacao).
- Verifica se output.title contem palavras-chave odontologicas.

## Save to Instagram Prospects

Tabela: instagram_prospects_cache
- Persiste prospects qualificados
