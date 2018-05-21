---
title: "Aula Text Mining"
output: html_notebook
---

# Análise de texto no R

A quantidade de informações geradas atualmente são incríveis e consequentemente a forma como eles estão estruturados pode variar muito, entre elas, o casos dos textos.

Análise de texto não é algo relativamente novo, podemos notar isso em _papers_ e livros sobre análise de discurso ou conteúdo. Ocorre que o poder computacional foi capaz de trazer análises ainda mais escaláveis do que se fazia antes e com uma força quantitativa muito mais robusta.

No __R__ existem muitos pacotes para lidar com textos, que vão desde contar frequência de palavras até rodar modelos estatísticos. Vamos tentar percorrar estes tópicos utilizando como bases os discursos da Dilma e do Temer.

Estes discursos foram obtidos utilizando webscraping e seu código está disponível [aqui](https://github.com/ngiachetta/OficinaCIS-USP/blob/master/WebScraping.Rmd). Não recomedo baixá-los novamente, vai demorar uma eternidade!

## Revisando estrutura de dados: strings

Ao longo das aulas vimos como podemos guardar variáveis tipo texto no R. Estes objetos devem sempre estar entre aspas, sejam as aspas simples `''` ou duplas `""`.


```r
c("Oi", "Tudo", "bem")
```

```
## [1] "Oi"   "Tudo" "bem"
```

Estes tipos de objetos podem ser manipulados assim como tantos outros objetos, porém não podemos, por exemplo, fazer a média de `c("Oi", "Tchau")`. Uma das principais função para manipulação de texto no __R__ é o __stringr__ criado por Hadley Wickham. Vamos ver como ele funciona!

## __stringr__

A maior parte das funções do __stringr__ tem como prefixo `str_`, como por exemplo, `str_replace()`, `str_detect()` ou `str_extract()` e para habilitar ela para uso fazemos,


```r
# install.packages("stringr")
library(stringr)
```

Vamos usar o seguinte vetor como exemplo:


```r
textos <- c("Programacao em R", "Ciências Sociais", "Sociologia", "Programar é legal", "HaDlEy WiCkHaM", "R")
```

### `str_lenght()`

O `str_lenght()` serve para verificarmos o número de caracteres das palavras. Note que ele é diferente da função `length()` que apenas conta a quantidade de elementos no vetor.


```r
str_length(textos)
```

```
## [1] 16 16 10 17 14  1
```

```r
length(textos)
```

```
## [1] 6
```

### `str_c()`

O `str_c()` nos ajuda a concatenar as strings em uma única. Vamos ver um exemplo concatenando os elementos das posições um e dois do nosso vetor "textos".


```r
str_c(textos[1], textos[2], sep = " para ")
```

```
## [1] "Programacao em R para Ciências Sociais"
```

Basicamente, colamos "Programacao em R" e "Ciências Sociais" separado por " para ". Simples, não?

### `str_to_lower()`, `str_to_title()`, `str_to_upper()`

Estas funções são bem intuitivas, olha só:


```r
str_to_lower(textos)
```

```
## [1] "programacao em r"  "ciências sociais"  "sociologia"       
## [4] "programar é legal" "hadley wickham"    "r"
```


```r
str_to_title(textos)
```

```
## [1] "Programacao Em R"  "Ciências Sociais"  "Sociologia"       
## [4] "Programar É Legal" "Hadley Wickham"    "R"
```


```r
str_to_upper(textos)
```

```
## [1] "PROGRAMACAO EM R"  "CIÊNCIAS SOCIAIS"  "SOCIOLOGIA"       
## [4] "PROGRAMAR É LEGAL" "HADLEY WICKHAM"    "R"
```

### `str_replace()` e `str_replace_all()`

A função `str_replace()` e `str_replace_all()` localizam um padrão e o substituem por algo de seu interesse, por exemplo, queremos substituir todas as letras r dos elementos do nosso vetor por Python.


```r
str_replace(textos, "R", "Python")
```

```
## [1] "Programacao em Python" "Ciências Sociais"      "Sociologia"           
## [4] "Programar é legal"     "HaDlEy WiCkHaM"        "Python"
```

Ops, parece que o r em caixa baixa é diferente do R em caixa alta! Isso significa que estas funções são case-sensitive, ou seja, precisamos especificar que queremos transformar tanto "r" e "R" em Python.


```r
mud_R <- str_replace(textos, "R", "Python")
mud_r <- str_replace(mud_R, "r", "Python")
mud_r
```

```
## [1] "PPythonogramacao em Python" "Ciências Sociais"          
## [3] "Sociologia"                 "PPythonogramar é legal"    
## [5] "HaDlEy WiCkHaM"             "Python"
```

Parece que ainda não deu certo! O elemento "PPythonogramar é legal" ainda tem "r" que não foram substituídos. Para solucionar esse problema nós utilizamos `str_replace_all()` que vai substituir todos os padrões do texto.


```r
mud_R <- str_replace_all(textos, "R", "Python")
mud_r <- str_replace_all(mud_R, "r", "Python")
mud_r
```

```
## [1] "PPythonogPythonamacao em Python"  "Ciências Sociais"                
## [3] "Sociologia"                       "PPythonogPythonamaPython é legal"
## [5] "HaDlEy WiCkHaM"                   "Python"
```

### `str_detect()`

O `str_detect()` irá detectar se existe um padrão específico nos seus textos, como por exemplo, vamos detectar em quais elementos aparecem a palavra programar.


```r
str_detect(textos, "Programar")
```

```
## [1] FALSE FALSE FALSE  TRUE FALSE FALSE
```

### `str_extract()`

O `str_extract()` extraí um padrão dos elementos do texto.


```r
str_extract(textos, "Programar")
```

```
## [1] NA          NA          NA          "Programar" NA          NA
```

## Expressões Regulares (Regex)

Existem formas de sinalizarmos alguns padrões nos textos, como por exemplo, falar que queremos o r em caixa baixa ou o R em caixa alta. Estas formas de sinalizar padrões são chamadas de expressões regulares. No wikipedia a definição de regex é a seguinte,

> "uma forma concisa e flexível de identificar cadeias de caracteres de interesse, como caracteres particulares, palavras ou padrões de caracteres"

Dê uma pausa e leia o material do Curso R sobre expressões regulares: http://material.curso-r.com/stringr/#express%C3%B5es-regulares

Agora que temos uma noção melhor sobre como manipular textos, vamos analisar os discursos da Dilma e Temer!

## Análise dos discurso da Dilma e Temer

Vamos habilitar os pacotes que utilizaremos e abrir os dados com os discursos.


```r
library(tidyverse)
library(quanteda)
```

```
## Error in library(quanteda): there is no package called 'quanteda'
```

```r
library(wordcloud2)
```

```
## Error in library(wordcloud2): there is no package called 'wordcloud2'
```

```r
library(stringr)
library(tidytext)
```

```
## Error in library(tidytext): there is no package called 'tidytext'
```

```r
library(SnowballC)
```

```
## Error in library(SnowballC): there is no package called 'SnowballC'
```


```r
discursos <- read_csv("data/discursos.csv")
```

```
## Parsed with column specification:
## cols(
##   date = col_character(),
##   title = col_character(),
##   discourse = col_character(),
##   link_discourse = col_character(),
##   who = col_character()
## )
```

O banco de dados tem apenas 5 variáveis, com informações sobre a data, o título do discurso, o link para os discursos, quem os proferiu e o seu cunteúdo. Vamos começar fazendo algumas transoformações básicas.


```r
glimpse(discursos)
```

```
## Observations: 1,140
## Variables: 5
## $ date           <chr> "12/05/2016 14h22", "10/05/2016 20h47", "09/05/...
## $ title          <chr> "Declaração à imprensa da Presidenta da Repúbli...
## $ discourse      <chr> "Bom dia. Bom dia senhores e senhoras jornalist...
## $ link_discourse <chr> "http://www2.planalto.gov.br/acompanhe-o-planal...
## $ who            <chr> "Dilma", "Dilma", "Dilma", "Dilma", "Dilma", "D...
```

A primeira transformação que faremos vai ser transformar a variável `date` em um objeto interpretado como data e não string, em seguida transformaremos todas as outras variáveis em caixa baixa para termos um padrão nos dados já que como dissemos, as funções para manipulação de texto são _case-sensitive_. Por fim, criaremos uma variável que detecta se o discurso foi ou não proferido no palácio do planalto.


```r
discursos <- discursos %>% 
  mutate(date = dmy_hm(date),
         title = str_to_lower(title),
         discourse = str_to_lower(discourse),
         palacio_planalto = str_detect(discourse, "(^palácio do planalto)"))
```

```
## Error in mutate_impl(.data, dots): Evaluation error: could not find function "dmy_hm".
```

Uma primeira pergunta que podemos responder é: Quantos discursos foram proferidos pelos dois presidentes no Palácio do Planalto?


```r
discursos %>% 
  count(palacio_planalto, who) %>% 
  spread(palacio_planalto, n)
```

```
## Error in grouped_df_impl(data, unname(vars), drop): Column `palacio_planalto` is unknown
```

Podemos notar que ambos presidentes costumam discursar fora do palácio do planalto! Isso é interessante rs.
