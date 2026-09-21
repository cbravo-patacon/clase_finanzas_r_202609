# Fijar semilla para reproducibilidad
set.seed(123)

# Número de observaciones
n <- 252

# Parámetros de los retornos
media <- 0.0005   # 0.05%
desv_std <- 0.015 # 1.5%

# Simular retornos diarios
retornos <- rnorm(
  n = n,
  mean = media,
  sd = desv_std
)

# Generar fechas consecutivas desde hoy
fechas <- seq(
  from = Sys.Date(),
  by = "day",
  length.out = n
)

# Crear data frame
datos <- data.frame(
  fecha = fechas,
  retorno = retornos
)

# Guardar archivo CSV
write.csv(
  datos,
  "retornos.csv",
  row.names = FALSE
)

# Mostrar primeras observaciones
head(datos)