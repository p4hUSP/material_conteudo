#Função baseada na puBuild do Curso-R
# Ela cria uma pasta content com os tutoriais. 
# Para dar certo, precisamos que os tutoriais 
# funcionem

rm(list = ls())

create_content <- function(dir = "./tutoriais"){
  system("rm -Rf ./content") #Exclui a pasta de content
  file <- list.files("./tutoriais/")
  dir_file <- stringr::str_remove(file, "\\.md$|\\.Rmd$")
  for(i in seq_along(file)){
    suppressWarnings(dir.create(sprintf("./content/%s", dir_file[[i]]),
                                recursive = TRUE))
    if(stringr::str_detect(file[[i]], "\\.md$")){
      create_md(dir_file[[i]])
    } else if(stringr::str_detect(file[[i]], "\\.Rmd$")){
      create_Rmd(file[[i]], dir_file[[i]])
    }
  }
}

create_md <- function(dir_file){
  system(sprintf("cp ./tutoriais/%s.md ./content/%s/index.md", dir_file, dir_file))
}

create_Rmd <- function(file, dir_file){
  ezknitr::ezknit(stringr::str_c("./tutoriais/", file),
                  out_dir = stringr::str_c("./content/", dir_file),
                  fig_dir = "figures",
                  keep_html = FALSE)
  system(sprintf("mv ./content/%s/%s.md ./content/%s/index.md", dir_file, dir_file, dir_file))
}

create_content()
