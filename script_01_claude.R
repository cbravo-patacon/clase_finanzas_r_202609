# Cargar tidyverse.
# En este caso lo usamos principalmente para tibble() y write_csv().
library(tidyverse)

# Fijar una semilla para que los números aleatorios generados
# sean los mismos cada vez que ejecutemos el código.
set.seed(123)

# Definir la cantidad de días a simular.
# 252 corresponde aproximadamente a un año bursátil.
n_dias <- 252

# Definir el retorno promedio diario.
# 0.0005 equivale a 0.05%.
media <- 0.0005

# Definir la desviación estándar de los retornos diarios.
# 0.015 equivale a 1.5%.
desv_std <- 0.015

# Crear una tabla con las fechas y los retornos simulados.
datos <- tibble(

  # Generar 252 fechas consecutivas comenzando desde la fecha actual.
  fecha = seq(
    Sys.Date(),
    by = "day",
    length.out = n_dias
  ),

  # Simular 252 retornos diarios utilizando una distribución normal.
  # La distribución tiene media de 0.05% y desviación estándar de 1.5%.
  retorno = rnorm(
    n_dias,
    mean = media,
    sd = desv_std
  )

)

# Guardar la tabla creada en un archivo CSV.
# El archivo se guardará en el directorio de trabajo actual de R.
write_csv(datos, "retorno_02.csv")