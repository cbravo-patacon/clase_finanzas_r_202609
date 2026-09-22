library(tidyverse)

# ============================================================================
# SECCIÓN 1: GENERACIÓN DE DATOS SIMULADOS DE RETORNOS BURSÁTILES
# ============================================================================

# 1. Configuración de parámetros iniciales
# set.seed() asegura reproducibilidad: genera los mismos números aleatorios cada vez
set.seed(42)

# Parámetros del análisis
n_dias <- 252  # Número estándar de días de negociación en un año bursátil
tickers <- c("AAPL", "GOOGL", "MSFT")  # Tres grandes tecnológicas para análisis comparativo

# Generar fechas hábiles consecutivas (excluyendo fines de semana)
# seq() crea una secuencia: desde hace 365 días hasta hoy
fechas <- seq(from = Sys.Date() - 365, by = "day", length.out = 365)
# wday() retorna el día de la semana (1=domingo, 7=sábado); eliminamos ambos
fechas_hábiles <- fechas[!lubridate::wday(fechas) %in% c(1, 7)][1:n_dias]

# 2. Creación del dataset simulado con distribución normal
# expand_grid() crea todas las combinaciones de fechas y tickers (252 * 3 = 756 filas)
datos_simulados <- expand_grid(
  fecha = fechas_hábiles,
  ticker = tickers
) |>
  mutate(
    # rnorm() genera retornos normalmente distribuidos
    # mean = 0.0005 (0.05% retorno diario promedio)
    # sd = 0.015 (1.5% desviación estándar = volatilidad realista)
    retorno = rnorm(n(), mean = 0.0005, sd = 0.015)
  ) |>
  arrange(fecha, ticker)  # Ordenar por fecha y ticker para claridad

# 3. Exportar datos simulados a CSV para persistencia
write_csv(datos_simulados, "retornos_3_acciones.csv")

# Verificación: mostrar las primeras 6 filas del dataset generado
print(head(datos_simulados))
# Confirmación con mensaje informativo sobre el archivo creado
cat("Archivo 'retornos_3_acciones.csv' guardado exitosamente con", nrow(datos_simulados), "filas.\n")

# ============================================================================
# SECCIÓN 2: ANÁLISIS, VISUALIZACIÓN Y ESTADÍSTICA DE RETORNOS
# ============================================================================

# 1. Cargar los datos desde el archivo CSV generado en la sección anterior
datos <- read_csv("retornos_3_acciones.csv")

# 2. Calcular retornos acumulativos por acción (ticker)
# Este paso es crítico en finanzas: transforma retornos diarios en rendimiento total acumulado
datos_acumulados <- datos |>
  group_by(ticker) |>  # Procesar cada acción por separado
  arrange(fecha) |>     # Asegurar orden cronológico (importante para cumprod)
  mutate(
    # cumprod(1 + retorno) calcula el producto acumulado de los factores de crecimiento
    # Al restar 1, obtenemos el retorno acumulado porcentual desde el inicio
    # Fórmula financiera: Rendimiento = (1 + r₁) × (1 + r₂) × ... × (1 + rₙ) - 1
    retorno_acumulado = cumprod(1 + retorno) - 1
  ) |>
  ungroup()  # Eliminar agrupación para operaciones posteriores

# 3. Generar gráfico comparativo de líneas con ggplot2
# Este gráfico permite visualizar cuál acción tuvo mejor desempeño durante el período
grafico_comparativo <- ggplot(datos_acumulados, aes(x = fecha, y = retorno_acumulado, color = ticker)) +
  geom_line(linewidth = 1) +  # Líneas con grosor 1pt para cada acción
  scale_y_continuous(labels = scales::percent) +  # Convertir eje Y a formato porcentaje
  labs(
    title = "Evolución del Retorno Acumulado (1 Año)",
    subtitle = "Comparativa entre AAPL, GOOGL y MSFT",
    x = "Fecha",
    y = "Retorno Acumulado (%)",
    color = "Acción"
  ) +
  theme_minimal()  # Tema limpio sin elementos innecesarios

# Mostrar el gráfico en el panel PLOTS de RStudio/Positron
print(grafico_comparativo)

# Exportar gráfico como imagen PNG (8" ancho × 5" alto) para reportes/presentaciones
ggsave("retorno_acumulado_comparativo.png", plot = grafico_comparativo, width = 8, height = 5)

# 4. Calcular matriz de correlación entre los retornos diarios de los 3 activos
# La correlación mide cómo se mueven juntos los activos (valor entre -1 y 1)
tabla_correlacion <- datos |>
  # Transforma de formato largo a ancho: cada ticker en su propia columna
  pivot_wider(names_from = ticker, values_from = retorno) |>
  select(-fecha) |>  # Eliminar columna de fecha (no es numérica)
  cor(use = "complete.obs")  # Calcular matriz de correlación (ignora valores faltantes)

# Imprimir la matriz de correlación con 4 decimales de precisión
cat("\n--- Matriz de Correlación de Retornos Diarios ---\n")
cat("Valores cercanos a 1: activos se mueven juntos (correlación positiva)\n")
cat("Valores cercanos a 0: movimientos independientes\n")
cat("Valores cercanos a -1: activos se mueven en direcciones opuestas\n\n")
print(round(tabla_correlacion, 4))

# 5. Generar gráfico de retornos diarios (sin acumular)
# Este gráfico muestra la volatilidad día a día, útil para análisis de riesgo
grafico_retornos_diarios <- ggplot(datos, aes(x = fecha, y = retorno, color = ticker)) +
  geom_line(linewidth = 0.7) +  # Líneas más delgadas para volatilidad diaria
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50", alpha = 0.5) +  # Línea de referencia
  scale_y_continuous(labels = scales::percent) +  # Formato porcentaje en eje Y
  labs(
    title = "Retornos Diarios (Sin Acumular) - Volatilidad de Corto Plazo",
    subtitle = "Variaciones día a día de AAPL, GOOGL y MSFT",
    x = "Fecha",
    y = "Retorno Diario (%)",
    color = "Acción"
  ) +
  theme_minimal() +
  theme(
    panel.grid.major = element_line(color = "gray90"),  # Grid más visible
    plot.title = element_text(size = 12, face = "bold")
  )

# Mostrar el gráfico en el panel PLOTS
print(grafico_retornos_diarios)

# Exportar como PNG para reportes
ggsave("retornos_diarios.png", plot = grafico_retornos_diarios, width = 10, height = 6)

cat("\n✓ Gráfico de retornos diarios guardado como 'retornos_diarios.png'\n")


# ============================================================================
# RESUMEN DEL FLUJO DE ANÁLISIS
# ============================================================================

# PASO 1: Generación de datos sintéticos
# → Creamos historial de un año bursátil (252 días hábiles) para 3 acciones (AAPL, GOOGL, MSFT)
# → Los retornos diarios siguen una distribución normal realista con volatilidad del 1.5%

# PASO 2: Transformación de datos
# → Importamos la data guardada en CSV
# → Transformamos retornos diarios en rendimiento acumulativo porcentual por empresa
# → Esto permite visualizar cuál acción tuvo mejor desempeño a lo largo del año

# PASO 3: Visualización comparativa
# → Construimos gráfico de líneas que muestra la evolución de cada acción
# → Facilita identificar tendencias y momentos de divergencia entre activos
# → Exportamos como PNG para reportes y presentaciones

# PASO 4: Análisis de correlación
# → Calculamos matriz de correlación entre los retornos diarios
# → Valores altos (cercanos a 1) indican que los activos se mueven juntos
# → Importante para diversificación: activos poco correlacionados ofrecen mejor protección

# ============================================================================
# REFLEXIÓN: DESARROLLO ASISTIDO POR IA EN FINANZAS
# ============================================================================

# El desarrollo de scripts en R asistido por IA reduce significativamente la fricción operativa:
#
# VENTAJAS:
# • Genera sintaxis rápida y confiable para librerías complejas (tidyverse, ggplot2)
# • Optimiza el flujo de trabajo, permitiendo enfoque en análisis financiero real
# • Acelera prototipado y experimentación con diferentes enfoques
#
# LIMITACIONES CRÍTICAS:
# • La IA genera código que parece correcto pero puede contener errores sutiles
# • Los resultados numéricos DEBEN ser validados contra fuentes independientes
# • No reemplaza la comprensión financiera y estadística del usuario
#
# RECOMENDACIÓN:
# → La supervisión humana es FUNDAMENTAL en análisis financiero
# → Siempre verificar: ¿tienen sentido los números? ¿coinciden con teoría?
# → En un entorno de producción, agregar tests automatizados y auditoría de resultados