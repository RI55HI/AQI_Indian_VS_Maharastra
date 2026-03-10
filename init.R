# init.R use this file if ur deploying through vercel or heroku 
my_packages = c("shiny", "tidyverse", "janitor", "sf", "rnaturalearth")
install_if_missing = function(p) {
  if (p %in% rownames(installed.packages()) == FALSE) {
    install.packages(p, dependencies = TRUE)
  }
}
invisible(sapply(my_packages, install_if_missing))

