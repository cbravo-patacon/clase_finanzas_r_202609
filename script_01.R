# ------------------------------------------------------------
# Simulación de retornos diarios de una acción
# ------------------------------------------------------------

# Semilla para reproducibilidad
set.seed(123)

# Parámetros
n_dias <- 252
media <- 0.0005       # 0.05%
desv_est <- 0.015     # 1.5%

# Generar fechas consecutivas desde hoy
fechas <- seq(
  from = Sys.Date(),
  by = "day",
  length.out = n_dias
)

# Simular retornos diarios con distribución normal
retornos <- rnorm(
  n = n_dias,
  mean = media,
  sd = desv_est
)

# Crear data frame
datos <- data.frame(
  fecha = fechas,
  retorno = retornos
)

# Guardar como CSV
write.csv(
  datos,
  file = "retornos.csv",
  row.names = FALSE
)

# Revisar las primeras observaciones
head(datos)

# Confirmación
cat("Archivo 'retornos.csv' creado correctamente.\n")