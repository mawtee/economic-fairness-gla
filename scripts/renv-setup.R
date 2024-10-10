library(renv)
renv::init()
renv::install(
  "munichrocker/DatawRappr"
)
renv::snapshot()
renv::restore()