df <- readr::read_csv(
  file = "../RIPSA 2026/dados/Morbidade/ripsa008mb.csv.zip",
  col_types = "iidicccicciccidddddd??ccccc"
)

arrow::write_parquet(x = df, sink = "data-raw/parquet/ripsa008mb.parquet")
