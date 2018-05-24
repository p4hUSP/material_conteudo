---
title: "Aula Text Mining"
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

length(textos)
```

### `str_c()`

O `str_c()` nos ajuda a concatenar as strings em uma única. Vamos ver um exemplo concatenando os elementos das posições um e dois do nosso vetor "textos".


```r
str_c(textos[1], textos[2], sep = " para ")
```

Basicamente, colamos "Programacao em R" e "Ciências Sociais" separado por " para ". Simples, não?

### `str_to_lower()`, `str_to_title()`, `str_to_upper()`

Estas funções são bem intuitivas, olha só:


```r
str_to_lower(textos)
```


```r
str_to_title(textos)
```


```r
str_to_upper(textos)
```

### `str_replace()` e `str_replace_all()`

A função `str_replace()` e `str_replace_all()` localizam um padrão e o substituem por algo de seu interesse, por exemplo, queremos substituir todas as letras r dos elementos do nosso vetor por Python.


```r
str_replace(textos, "R", "Python")
```

Ops, parece que o r em caixa baixa é diferente do R em caixa alta! Isso significa que estas funções são case-sensitive, ou seja, precisamos especificar que queremos transformar tanto "r" e "R" em Python.


```r
mud_R <- str_replace(textos, "R", "Python")
mud_r <- str_replace(mud_R, "r", "Python")
mud_r
```

Parece que ainda não deu certo! O elemento "PPythonogramar é legal" ainda tem "r" que não foram substituídos. Para solucionar esse problema nós utilizamos `str_replace_all()` que vai substituir todos os padrões do texto.


```r
mud_R <- str_replace_all(textos, "R", "Python")
mud_r <- str_replace_all(mud_R, "r", "Python")
mud_r
```

### `str_detect()`

O `str_detect()` irá detectar se existe um padrão específico nos seus textos, como por exemplo, vamos detectar em quais elementos aparecem a palavra programar.


```r
str_detect(textos, "Programar")
```

### `str_extract()`

O `str_extract()` extraí um padrão dos elementos do texto.


```r
str_extract(textos, "Programar")
```

## Expressões Regulares (Regex)

Existem formas de sinalizarmos alguns padrões nos textos, como por exemplo, falar que queremos o r em caixa baixa ou o R em caixa alta. Estas formas de sinalizar padrões são chamadas de expressões regulares. No wikipedia a definição de regex é a seguinte,

> "uma forma concisa e flexível de identificar cadeias de caracteres de interesse, como caracteres particulares, palavras ou padrões de caracteres"

Dê uma pausa e leia o material do Curso R sobre expressões regulares: http://material.curso-r.com/stringr/#express%C3%B5es-regulares

Agora que temos uma noção melhor sobre como manipular textos, vamos analisar os discursos da Dilma e Temer!

## Análise dos discurso da Dilma e Temer

Vamos habilitar os pacotes que utilizaremos e abrir os dados com os discursos.

Download [aqui](https://github.com/R4CS/material/tree/master/tu.textmining/data).


```r
library(tidyverse)
library(lubridate)
library(quanteda)
library(wordcloud2)
library(stringr)
library(tidytext)
library(SnowballC)
```


```r
discursos <- read_csv("data/discursos.csv")
```

O banco de dados tem apenas 5 variáveis, com informações sobre a data, o título do discurso, o link para os discursos, quem os proferiu e o seu cunteúdo. Vamos começar fazendo algumas transoformações básicas.


```r
glimpse(discursos)
```

A primeira transformação que faremos vai ser transformar a variável `date` em um objeto interpretado como data e não string, em seguida transformaremos todas as outras variáveis em caixa baixa para termos um padrão nos dados já que como dissemos, as funções para manipulação de texto são _case-sensitive_. Além disso, com a variável data padronizada de forma correta, vamos criar uma segunda variável para extrair apenas o ano do discurso. Por fim, criaremos uma variável que detecta se o discurso foi ou não proferido no palácio do planalto.


```r
discursos <- discursos %>% 
  mutate(date = dmy_hm(date),
         title = str_to_lower(title),
         discourse = str_to_lower(discourse),
         year = year(date),
         palacio_planalto = str_detect(discourse, "(^palácio do planalto)"))
```

Uma primeira pergunta que podemos responder é: Quantos discursos foram proferidos pelos dois presidentes no Palácio do Planalto?


```r
discursos %>% 
  count(palacio_planalto, who) %>% 
  spread(palacio_planalto, n)
```

Podemos notar que ambos presidentes costumam discursar fora do palácio do planalto! Isso é interessante rs.

Pois bem, vamos ao que interessa!

Para este tutorial, utilizaremos dois pacotes principais: 

- `quanteda`

- `tidytext`

Apesar de não serem os pacotes mais _"mainstream"_, eles permitem fazer o que o pacote `tm` faz, análises mais robustas com o próprio pacote. Apesar disso, o conceito que percorre estas bibliotecas é muito semelhantes, sobretudo, no `quanteda`, temos três tipos básicos de objetos:

1. Corpus

2. Tokens

3. Document-feature matrix (DFM)


Falaremos melhor deles mais a diante, porém antes de avançarmos é bom termos na cabeça como funciona a preparação de um texto para a sua análise.

### Preparação do texto

A limpeza do texto, ou até mesmo chamada de "pré-processamento" é um conjunto de práticas voltadas para remover ou alterar partes dos textos que prejudicariam a análise final, como por exemplo, se o texto tiver muitas palavras "tipo", ele vai influênciar na analise das outras palavras, mesmo que ela não tenha sentido nenhum para o que estamos tratando. Se você ainda não se convenceu, pare para pensar quando um colega vai apresentar um trabalho e fica falando "tipo" toda hora!

Podemos nos perguntar: Existe uma limpeza correta? Não! Tudo depende do interesse do pesquisador, como por exemplo, se você está trabalhando com valores em textos, talvez não seja interessante para você removê-los. 

Porém, é bom saber que apesar de não ter uma limpeza melhor do que as outras, elas podem influênciar na análise de estatísticas mais robustas ou até mesmo a frequência das palavras. Se você ficou curiosa(o) para saber mais sobre isso acesse este artigo [aqui](http://www.nyu.edu/projects/spirling/documents/preprocessing.pdf).

Nós vamos seguir a limpeza proposta (ou pelo menos parecida) pelo artigo acima , inclundo uma limpeza número 0A e 0B, muito mais relacionada com as condições dos nossos dados. Dentre estas limpezas temos:

0A. Remover "não discursos"

0B. Filtrar apenas em casos dos quais a linguagem é português

1. Pontuação

2. Números

3. Stemming

4. Remover Stopwords

Algumas destas limpezas como a 0A e a 0B vão ser realizadas utilizando os próprios verbos do `dplyr` e do `stringr`. Para realização dos outros passos iremos introduzir os conceitos de objetos no `quanteda`.

#### 0A. Remover "não discursos"

Prestem atenção no resultado do código abaixo,


```r
discursos %>% top_n(n = 5, discourse) %>% select(discourse)
```

Muitos deles começam com uma localidade, seguidos de uma sequência de espaços para então chegar no discurso. Além disso, os textos se encerram com um texto escrito "ouça na integra...". Estas coisas não fazem parte do texto, logo precisaremos removê-los!

Não se preocupe caso não entenda de primeira, "regex" é algo que pegamos o costume com o tempo!

Obs: Iremos aproveitar para remover frases como "bom dia", "boa tarde" e "boa noite"


```r
discursos <- discursos %>% mutate(discursos_limpos = str_replace_all(discourse, 
                                                                     "(ouça a íntegra.*).*|\\n|(desenvolvido com o cms).*|(plone)|(bom dia)|(boa noite)|(boa tarde)", "") %>% str_trim())
discursos <- discursos %>% mutate(discursos_limpos = str_replace_all(discursos_limpos, ".*[0-9]\\s{4,}", ""))
```

#### 0B. Filtrar apenas em casos dos quais a linguagem é português

Alguns discursos na nossa base estão em inglês, o que dificulta a análise de texto. Para isso precisamos identificar os idiomas dos textos e assim, filtrar os casos em português. Existe um pacote para isso que chama `textcat`.


```r
#install.packages("textcat")
library(textcat)
```

Após instalar, basta identificarmos o idioma utilizando a função `textcat()` e filtrar o nosso caso de interesse.


```r
discursos <- discursos %>% 
  mutate(idioma = textcat(discursos_limpos)) %>% 
  filter(idioma == "portuguese")
```

#### Pausa para conceitos

Como mencionamos acima, o quanteda tem três tipos de objetos.


```r
knitr::include_graphics("img/fluxo_text_minging.png")
```

O primeiro deles, é o __Corpus__, que nada mais é do que uma coleção de documentos.


```r
corpus <- corpus(discursos$discourse)
```

Porém, lembre-se que estamos lidando tanto com discursos da Dilma quanto discursos do Temer, logo precisamos definir no nosso corpus qual discurso pertence a quem e em qual ano.


```r
quem_ano <- discursos %>% select(who, year)
docvars(corpus, c("who", "year")) <- quem_ano

summary(corpus)
```

Agora que temos um corpus, podemos transformá-los em __tokens__, que de forma bem rude, são as palavras de cada documento. Vamos também aproveitar para fazer algumas limpezas no nosso corpus, que seriam a remoção da pontuação e dos números.


```r
token <- tokens(corpus, 
       include_docvars = T,
       remove_numbers = T, 
       remove_punct = T)

head(token, n = 2)
```

Aora que temos os tokens, remover as stopwords. Stemming nada mais é que um método para obter a raiz das palavras! Ele serve para que palavras com mesmo significado, ou significados diferentes sejam interpretadas como as mesmas, como por exemplo, livro e livreiro tem como raiz livr. Se procurarmos pela internet podemos ver a seguinte definição.

No caso das Stopwords está definição pode nos ajudar:

> Stop words (ou palavras de parada – tradução livre) são palavras que podem ser consideradas irrelevantes para o conjunto de resultados a ser exibido em uma busca realizada em uma search engine. Exemplos: as, e, os, de, para, com, sem, foi.

Sendo assim, para realizar o stemming e retirar os stopwords utilizamos:


```r
sw <- stopwords(language = "pt")
token <- tokens_remove(token, c(sw, "é"))
token <- tokens_wordstem(token, language = "portuguese")
```

Vamos finalmente transformar nossos tokens em DFM (Document Feature Matrix), também chamado de DTM (Document-Term Matrix). o DFM é uma matriz em que as linhas são os documentos, que no nosso caso são os discursos, e as colunas são os termos (palavras), o valor contido dentro das células indicam o quão frequente os termos são nos documentos.

A tabela abaixo é um exemplo de um DFM:

|... |casa|janela|porta|
|----|----|------|-----|
|Doc1|2   |5     |0    |
|Doc2|4   |0     |0    |
|Doc3|0   |0     |1    |

Dizemos que a matriz é esparsa quando ela possui uma grande quantidade de zeros e em algumas análises isso pode ser um problema!


```r
dfm_discursos <- dfm(token)

ndoc(dfm_discursos) # Numero de discursos
nfeat(dfm_discursos) # Numero de palavras
sparsity(dfm_discursos) # % da matriz esparsa (% de zeros)
```

Vamos finalmente para as análises

- Frequência das palavras


```r
freq <- textstat_frequency(dfm_discursos, groups = docvars(dfm_discursos, "who"))
freq
```


```r
# Grafico da dilma
freq %>% 
  filter(group == "Dilma") %>% 
  arrange(desc(frequency)) %>% 
  slice(1:20) %>% 
ggplot(aes(x = reorder(feature, frequency), y = frequency)) +
    geom_point() + 
    coord_flip() +
    labs(x = NULL, y = "Frequency")
```


```r
# Grafico do Temer
freq %>% 
  filter(group == "Temer") %>% 
  arrange(desc(frequency)) %>% 
  slice(1:20) %>% 
ggplot(aes(x = reorder(feature, frequency), y = frequency)) +
    geom_point() + 
    coord_flip() +
    labs(x = NULL, y = "Frequency")
```

- Nuvem de palavras


```r
# Nuvem de palavra dos dois presidentes
wordcloud2(freq)
```


```r
# Nuvem da dilma
freq %>% 
  filter(group == "Dilma") %>% 
  arrange(desc(frequency)) %>% 
  slice(1:200) %>% 
  wordcloud2()
```


```r
# Nuvem da Temer
freq %>% 
  filter(group == "Temer") %>% 
  arrange(desc(frequency)) %>% 
  slice(1:200) %>% 
  wordcloud2()
```

Observe os parâmetros da função wordcloud2, podemos mudar uma infinidade de coisas como por exemplo a cor de fundo e o tamanho da fonte


```r
# Nuvem da Temer
freq %>% 
  filter(group == "Temer") %>% 
  arrange(desc(frequency)) %>% 
  slice(1:200) %>% 
  wordcloud2(backgroundColor = "gray", size = 0.3)
```



