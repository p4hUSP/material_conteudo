files <- list.files("tutoriais/")

for(i in files){
  dir_name <- stringr::str_remove_all(i, ".md|.Rmd")
  system(sprintf("mkdir tu.%s", dir_name))
  system(sprintf("cp ./tutoriais/%s ./tu.%s/", i, dir_name))
}




