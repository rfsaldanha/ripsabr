## code to prepare `indicators` dataset goes here

indicators <- readr::read_csv(
  file = "data-raw/indicators.csv",
  col_types = "ccccic"
)

usethis::use_data(indicators, overwrite = TRUE)
