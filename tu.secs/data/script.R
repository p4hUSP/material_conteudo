rm(list = ls())

library(tidyverse)

candidatos <- read_csv("tu.secs/data/CANDIDATOS_DEPUTADO_FEDERAL_2014.csv")

candidatos <- candidatos %>%
  filter(DES_SITUACAO_CANDIDATURA %in% c("DEFERIDO", "DEFERIDO COM RECURSO"))

candidatos <- candidatos %>%
  mutate(RES_ELEICAO = ifelse(DESC_SIT_TOT_TURNO %in% c("ELEITO POR MÉDIA", "ELEITO POR QP"), "Eleito", "Não Eleito"))

candidatos <- candidatos %>%
  mutate(RACA = case_when(DESCRICAO_COR_RACA == "BRANCA"   ~ "Brancos",
                          DESCRICAO_COR_RACA == "INDÍGENA" ~ "Não Brancos",
                          DESCRICAO_COR_RACA == "PARDA"    ~ "Não Brancos",
                          DESCRICAO_COR_RACA == "PRETA"    ~ "Não Brancos"))


candidatos %>% 
  group_by(SIGLA_PARTIDO) %>% 
  summarise(PROP_MULHERES    = sum(DESCRICAO_SEXO == "FEMININO")/n(),
            PROP_NAO_BRANCOS = sum(RACA == "Não Brancos", na.rm = T)/n(),
            n = n()) %>% 
  ggplot(mapping = aes(x = PROP_NAO_BRANCOS, y = PROP_MULHERES, label = SIGLA_PARTIDO)) +
  geom_text_repel(family = "Arial Bold") +
  geom_point(color = "red") +
  theme_minimal() +
  theme(axis.title = element_text(face = "bold", size = 12),
        title = element_text(face = "bold", size = 14)) +
  scale_x_continuous(labels = str_c(seq(20,70, by = 10), "%")) +
  scale_y_continuous(labels = str_c(seq(20,50, by = 10), "%")) +
  labs(x = "Proporção de Não Brancos (Pretos, Pardos e Indígenas)",
       y = "Proporção de Mulheres",
       title = "Perfil dos Candidatos a Deputado Federal por Partido",
       subtitle = "Eleições Gerais de 2014",
       caption = "Fonte: TSE")
