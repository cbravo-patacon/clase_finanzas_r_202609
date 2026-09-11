library(tidyverse)

set.seed(123)
n_dias <- 252

datos <- tibble(
  fecha = seq(Sys.Date(), by = "day", length.out = n_dias),
  retorno = rnorm(n_dias, mean = 0.0005, sd = 0.015)
)

write_csv(datos, "retorno_02.csv")