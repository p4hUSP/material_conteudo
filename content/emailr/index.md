---
title: "Enviando E-Mails pelo R"
date: "2018-04-05"
---

Nesse breve tutorial, vamos aprender a utilizar o R para enviar e-mails.


```r
#Essa função testa
if(!require(gmailr)) install.packages("gmailr")
```


```r
library(tidyverse)

mtcars %>% 
  ggplot(mapping = aes(x = gear)) + 
  geom_bar()
```

![plot of chunk unnamed-chunk-2](figures//unnamed-chunk-2-1.png)


