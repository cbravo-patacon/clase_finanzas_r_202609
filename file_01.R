#install.packages("dplyr")
#install.packages("rlang")

library(dplyr)

mtcars
?mtcars

mtcars |> summarize(avg = mean(mpg))

