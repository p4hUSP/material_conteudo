#Função baseada na puBuild do Curso-R
# Ela cria uma pasta content com os tutoriais. 
# Para dar certo, precisamos que os tutoriais 
# funcionem

rm(list = ls())

create_content <- function(dir = "./tutoriais"){
  tu_dirs <- list.files(".", "^tu\\.") #lista os diretórios dos tutorias
  tu_files <- purrr::map_chr(tu_dirs, list.files, pattern = "\\.Rmd$|\\.md$")   #lista os arquivos dentro dos diretórios
  content_dir <- stringr::str_remove(tu_dirs, "^tu\\.") #cria uma lista com o futuro nome dos diretórios dos tutorias
  for(i in seq_along(content_dir)){
    #Cria o diretório para o tutoria ldentro de ./content
    suppressWarnings(dir.create(sprintf("./content/%s", content_dir[[i]]),recursive = TRUE))
    suppressWarnings(system(sprintf("mkdir ./content/%s/img", content_dir[[i]])))
    system(sprintf("cp -R ./%s/img ./content/%s/img", tu_dirs[[i]], content_dir[[i]]))
    #Testa se o arquivo é um .md ou um .Rmd
    if(stringr::str_detect(tu_files[[i]], "\\.md$")){
      create_md(tu_dirs[[i]], tu_files[[i]], content_dir[[i]])
    } else if(stringr::str_detect(tu_files[[i]], "\\.Rmd$")){
      create_Rmd(tu_dirs[[i]], tu_files[[i]], content_dir[[i]])
    }
  }
}

#Transforma o .md em um index.md
create_md <- function(dir, file, content_dir){
  system(sprintf("cp ./%s/%s ./content/%s/index.md", dir, file, content_dir))
}

#cria um .md a partir de um .Rmd
create_Rmd <- function(dir, file, dir_file){
  ezknitr::ezknit(file,
                  wd      = stringr::str_c(getwd(),"/", dir),
                  out_dir = stringr::str_c("../content/", dir_file),
                  fig_dir = "figures",
                  keep_html = FALSE)
  system(sprintf("mv ./content/%s/%s.md ./content/%s/index.md", dir_file, dir_file, dir_file))
}

create_content()
