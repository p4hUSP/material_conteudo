Web Scraping de páginas HTML
----------------------------

No tutorial anterior aprendemos como podemos extrair informações por
meio de APIs. Mas muitas vezes queremos obter dados de páginas da
internet, que por sua vez não se encontram em estruturas necessariamente
destinadas a tal processo. Assim, como podemos obter apenas as
informações que nos interessam quando o conteúdo está “espalhado” pela
página? Utilizaremos, a estrutura do código HTML da própria página para
selecionar apenas o que desejamos e construir a partir disso os data
frames.

Nosso objetivo nessa atividade será capturar uma única página usando a
estrutura do código HTML da página. Já sabemos que, uma vez resolvida a
captura de uma página, podemos usar “loop” para capturar quantas
quisermos, desde que tenha uma estrutura semelhante.

Antes disso, porém, precisamos falar um pouco sobre XML e HTML.

XML e HTML
----------

XML significa “Extensive Markup Language”. Ou seja, é uma linguagem – e,
portanto, tem sintaxe – e é uma linguagem com marcação. Marcação, neste
caso, significa que todo o conteúdo de um documento XML está dentro de
“marcas”, também conhecidas como “tags”. É uma linguagem extremamente
útil para transporte de dados – por exemplo, a Câmara dos Deputados
utiliza XML em seu Web Service para disponibilizar dados abertos.

Por exemplo, se quisermos organizar a informação sobre um indivíduo que
assumiu diversos postos públicos, poderíamos organizar a informação da
seguinte maneira:

    <politicos>
      <politico>
        <id> 33333 </id>
        <nome> Fulano Deputado da Silva </nome>
        <data_nascimento> 3/3/66 </data_nascimento>
        <sexo> Masculino </sexo>
        <cargos>
          <cargo> 
            <cargo> prefeito </cargo> 
            <partido> PAN </partido>
            <ano_ini> 2005 </ano_ini>
            <ano_fim> 2008 </ano_fim>
          </cargo>
          <cargo> 
            <cargo> deputado federal </cargo> 
            <partido> PAN </partido>
            <ano_ini> 2003 </ano_ini>
            <ano_fim> 2004 </ano_fim>
           </cargo>
           <cargo> 
            <cargo> deputado estadual </cargo> 
            <partido> PAN </partido>
            <ano_ini> 1998 </ano_ini>
            <ano_fim> 2002 </ano_fim>
           </cargo>
          </cargos>
      </politicos>
    </politicos>

### Tags, nodes, atributos, valores e conteúdo na linguagem XML

Todas as informações em um documento XML estão dispostas em "tags" (id,
nome, etc são as tags do nosso exemplo). Um documento XML é um conjunto
de "tags" que contém hierarquia. Um conjunto de "tags" hierarquicamente
organizado é chamado de "node". Por exemplo, no arquivo XML da Câmara
dos Deputados apresentado acima, cada tag político contêm diversas
outras "tags" e formam "nodes", ou seja, pedaços do arquivo XML.

Em geral, as "tags" vem em pares: uma de abertura e outra de fechamento.
O que as diferencia é a barra invertida presente na tag de fechamento.
Entre as "tags" de abertura e fechamento vemos o conteúdo da tag, que
pode, inclusive, ser outras "tags". Veja os exemplos abaixo:

    <minha_tag> Este é o conteúdo da tag </minha_tag>
    <tag_pai>
      <tag_filha>
      </tag_filha>
    </tag_pai>
    <tag_pai> Conteúdo da tag Pai
      <tag_filha> Conteúdo da tag Filha
      </tag_filha>
    </tag_pai>

Identação (espaços) nos ajudam a ver a hierarquia entre as tags, mas não
é obrigatória. Também as quebras de linha são opcionais.

Além do conteúdo e do nome da tag, é extremamente comum encontrarmos
"atributos" nas tags em bancos de dados e, sobretudo, em códigos HTML.
Atributos ajudam a especificar a tag, ou seja, identificam qual é o seu
uso ou carregam quaisquer outras informações referentes. Voltando ao
exemplo fictício acima, poderíamos transformar a informação do cargo,
que hoje é uma tag cargo dentro de outra tag cargo (horrível, não?) em
atributo.

Em vez de:

    <politicos>
      <politico>
        <id> 33333 </id>
        <nome> Fulano Deputado da Silva </nome>
        <data_nascimento> 3/3/66 </data_nascimento>
        <sexo> Masculino </sexo>
        <cargos>
          <cargo> 
            <cargo> prefeito </cargo> 
            <partido> PAN </partido>
            <ano_ini> 2005 </ano_ini>
            <ano_fim> 2008 </ano_fim>
          </cargo>
          <cargo> 
            <cargo> deputado federal </cargo> 
            <partido> PAN </partido>
            <ano_ini> 2003 </ano_ini>
            <ano_fim> 2004 </ano_fim>
           </cargo>
           <cargo> 
            <cargo> deputado estadual </cargo> 
            <partido> PRONA </partido>
            <ano_ini> 1998 </ano_ini>
            <ano_fim> 2002 </ano_fim>
           </cargo>
          </cargos>
      </politicos>
    </politicos>

Teríamos:

    <politicos>
      <politico>
        <id> 33333 </id>
        <nome> Fulano Deputado da Silva </nome>
        <data_nascimento> 3/3/66 </data_nascimento>
        <sexo> Masculino </sexo>
        <cargos>
          <cargo tipo = 'prefeito'>
            <partido> PAN </partido>
            <ano_ini> 2005 </ano_ini>
            <ano_fim> 2008 </ano_fim>
          </cargo>
          <cargo tipo = 'deputado federal'>
            <partido> PAN </partido>
            <ano_ini> 2003 </ano_ini>
            <ano_fim> 2004 </ano_fim>
           </cargo>
          <cargo tipo = 'deputado estadual'>
            <partido> PRONA </partido>
            <ano_ini> 1998 </ano_ini>
            <ano_fim> 2002 </ano_fim>
           </cargo>
          </cargos>
      </politicos>
    </politicos>

### Caminhos no XML e no HTML

O fato de haver hierarquia nos códigos XML e HTML nos permite construir
"caminhos", como se fossem caminhos de pastas em um computador, dentro
do código.

Por exemplo, o caminho das "tags" que contém a informação "nome" em
nosso exemplo fictício é:

`/politicos/politico/nome`.

O caminho das "tags" que contém a informação "partido" em nosso exemplo
fictício, por sua vez, é:

`/politicos/politico/cargos/cargo/partido`.

Seguindo tal caminho chegamos às três "tags" que contém a informação
desejada.

Simples, não? Mas há um problema: o que fazer quando chegamos a 3
informações diferentes (o indivíduo em nosso exemplo foi eleito duas
vezes pelo PAN e uma pelo PRONA)? Há duas alternativas: a primeira,
ficamos com as 3 informações armazenadas em um vetor, pois as 3
informações interessam. Isso ocorrerá com frequência.

Mas se quisermos apenas uma das informações, por exemplo, a de quando o
indivíduo foi eleito deputado estadual? Podemos usar os atributos e os
valores dos atributos das tag para construir o caminho. Neste caso,
teríamos como caminho:

`/politicos/politico/cargos/cargo[@tipo = 'deputado estadual']/partido`

Guarde bem este exemplo: ele será nosso modelo quando tentarmos capturar
páginas.

Vamos supor que queremos poupar nosso trabalho e sabemos que as únicas
"tags" com nome "partido" no nosso documento são aquelas que nos
interessam (isso nunca é verdade em um documento HTML). Podemos
simplificar nosso caminho de forma a identificar "todas as 'tags' '',
não importa em qual nível hierárquico do documento". Neste caso, basta
usar duas barras:

`//partido`

Ou "todas as tags 'partido' que sejam descendentes de 'politico', não
importa em qual nível hierárquico do documento":

`/politicos/politico//partido`

Ou ainda "todas as tags 'partido' que sejam descendentes de quaisquer
tag 'politico', não importa em qual nível hierarquíco do documento para
qualquer uma das duas":

`//politico//partido`

Ou "todas as 'tags' filhas de qualquer 'tag' 'cargo'" (usa-se um
asterisco para indicar 'todas'):

`//cargo/*`

Observe o potencial dos "caminhos" para a captura de dados: podemos
localizar em qualquer documento XML ou HTML uma informação usando a
própria estrutura do documento. Não precisamos organizar o documento
todo, basta extrair cirurgicamente o que queremos -- o que é a regra na
raspagem de páginas de internet.

Atividade
---------

Temos um grande problema para resolver. Após uma longa semana de
seminários, fichamentos e provas, temos um final de semana inteiro para
maratornar uma série. Mas eis a questão: o que assistir? Como somos
cientistas de dados, vamos nos basear nos dados disponibilizados na
internet. O site Metacritic compila críticas de criticos reconhecidos e
de diversas publicações, além disso, também computa as críticas dos
usuários, todas elas em forma de score (pontuação). Os scores vão de 0 a
99 no Metascore (de críticos TOP e publicações) e 0 a 10 (de usuários).

O que iremos fazer é utilizar as duas métricas para fazer uma seleção
das séries ou programas de TV mais bem avaliados.

### Primeiro passo - Estudar a estrutura

No site, acessamos a página
<https://www.metacritic.com/browse/tv/score/metascore/all/filtered?sort=desc>
para verificar as séries mais bem avaliadas. Essa página exibe uma lista
paginada dos programas de tv por ordem de avaliação.

Para cumprir nosso objetivo precisamos obter as seguintes informações da
lista: 1) O título do programa de TV; 2) O Metascore; 3) O Userscore e o
4) Link (caso queirámos obter mais informações).

Para obter essas informações precisamos entender como o código HTML
desta página está estruturada. No navegador, podemos usar a ferramenta
"Inspecionar elemento" para verificar o código HTML de cada elemento ou
node. Essa ferramenta pode ser acessada clicando com o botão direito do
mouse e selecionando a opção "Inspecionar" (o acesso à ferramenta pode
variar de navegador para navegador).

Fazendo isso em um título qualquer, verificamos que o título se encontra
contido dentro de uma tag `<a>`. Mas para elaborar um caminho que pegue
apenas as tags `<a>` de títulos, precisamos ser mais específicos com
nosso caminho. Ao passar o mouse nas tags exteriores a do título,
podemos perceber que uma tag especial envolve todos os elementos que
contêm as informações dos programas de TV. Essa é a tag
`<div class="product_wrap">`. Se fizessémos alguns testes, poderíamos
verificar que essa tag é comum a todos os itens da lista e exclusivos a
eles. Isso é muito importante, pois assim pegamos todos os itens e
apenas os itens que precisamos.

Desse modo, temos um caminho para pegar os nodes de programas de TV:
`//div[@class='product_wrap']`. Lembrando que `[@class='product_wrap']`
determina que apenas nodes com o atributo `class` com o valor igual a
'product\_wrap' serão capturados.

Vamos trabalhar apenas com esse caminho e ao longo da atividade vamos
elaborar outros caminhos a partir desse node para obter cada informação.

### Segundo Passo - Obter os nodes

Para essa atividade vamos usar dois pacotes:

    library("tidyverse")
    library("rvest")

Como fizemos no tutorial anterior, vamos acessar a página. Porém, desta
vez, usaremos o `rvest` para isso. Vamos armazenar o endereço da página
em uma variável:

    url <- "https://www.metacritic.com/browse/tv/score/metascore/all/filtered?view=condensed&sort=desc"

Para obter a página pelo `rvest`, usamos a função `read_html()`:

    pagina <- read_html(url)

No `rvest`, obtemos os nodes pela função `html_nodes()`:

    nodes_shows <- html_nodes(pagina, xpath = "//div[@class='product_wrap']")

NOTE que usamos o parâmetro `xpath` para especificar o caminho dos nodes
que queremos. Para essa função, também existe o parâmetro `css` que é
uma alternativa para o `xpath`.

Assim, se executarmos os códigos anteriores obteríamos uma lista com
todos os nodes de programas de TV. Mas não é isso que queremos. Então
precisamos ver a estrutura mais uma vez e verificar como esta
estruturados esses nodes para obter cada informação.

### Passo 3 - Obtendo os demais caminhos

Vamos primeiro obter um caminho para extrair os títulos. Voltando na
ferramenta "Inspecionar Elemento" do navegador, podemos verificar que o
título está contido dentro de uma tag `<a>`, que esta, por sua vez, está
contida em uma tag `<div class="basic_stat product_title">`. Podemos,
então, elaborar o seguinte caminho a partir do node que capturamos:
`//div[@class='basic_stat product_title']/a`. Lembre-se que estamos
trabalhando a partir do node `<div class="product_wrap">`. O código fica
assim:

    nodes_link <- html_nodes(nodes_shows, xpath = "//div[@class='basic_stat product_title']/a") 

NOTE que passamos a variável `nodes_shows` que criamos anteriormente
como parâmetro. Nessa nova variável, podemos obter tanto o título quanto
o link do programa de TV.

Para obter o conteúdo de texto contido na tag use a função
`html_text()`. Desse modo:

     titulos <- html_text(nodes_link)

Agora é sua vez.

### Exercícios

1.  Através da ferramenta "Inspecionar Elemento" verifique caminhos
    possíveis para obter o Metascore e o User Score.
2.  Use a função `html_nodes()` para capturar as informações e
    armazena-as em um objeto.
3.  Insira as informações obtidas em um data frame.
4.  Crie uma terceira métrica com o Metascore e o User Score.
5.  Exiba uma lista com os Top 5 programas de TV pela métrica criada no
    item anterior.
