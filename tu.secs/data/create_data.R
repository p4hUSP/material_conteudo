rm(list = ls())

library(tidyverse)
library(cepespR)

colunas <- c("ANO_ELEICAO",
             "NUM_TURNO",
             "DESCRICAO_ELEICAO",
             "SIGLA_UF",
             "NOME_CANDIDATO",
             "NUMERO_CANDIDATO",
             "SIGLA_UE",
             "NUM_TITULO_ELEITORAL_CANDIDATO",
             "DES_SITUACAO_CANDIDATURA",
             "DESC_SIT_TOT_TURNO",
             "NUMERO_PARTIDO",
             "SIGLA_PARTIDO",
             "CODIGO_LEGENDA",
             "SIGLA_LEGENDA",
             "COMPOSICAO_LEGENDA",
             "NOME_COLIGACAO",
             "DESCRICAO_SEXO",
             "DESCRICAO_ESTADO_CIVIL",
             "DESCRICAO_GRAU_INSTRUCAO",
             "DESCRICAO_COR_RACA",
             "DESPESA_MAX_CAMPANHA")



candidates <- get_candidates(2014, 6, columns_list = colunas)

votes <- get_votes(2014, 6, 2) %>% 
  rename(SIGLA_UF = UF) %>% 
  select(SIGLA_UF, SIGLA_UE, NUM_TURNO, NUMERO_CANDIDATO, QTDE_VOTOS)

complete <- candidates %>%
  left_join(votes, by = c("NUMERO_CANDIDATO", "SIGLA_UE", "NUM_TURNO", "SIGLA_UF"))

write_csv(complete, "tu.secs/data/CANDIDATOS_DEPUTADO_FEDERAL_2014.csv")
