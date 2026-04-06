get_indicator <- function(code) {
  # Isolate indicator metadata
  indi_info <- subset(x = indicators, id == code)

  # Get data
  res <- arrow::read_parquet(
    file = zendown::zen_file(
      deposit_id = indi_info$zenodo_repo,
      file_name = indi_info$parquet_file
    )
  )

  # Return
  return(res)
}
