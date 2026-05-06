ripsa_packages <- c(
  "ripsa-demografico",
  "ripsa-socioeconomico",
  "ripsa-mortalidade",
  "ripsa-morbidade",
  "ripsa-recursos",
  "ripsa-cobertura",
  "ripsa-fatores-de-risco-e-protecao"
)

portal_url <- "https://dadosabertos.saude.gov.br"

geography_specs <- list(
  municipality = c("co_ibge", "no_municipio", "vl_indicador_calculado_mun"),
  state = c("co_uf", "no_uf", "vl_indicador_calculado_uf"),
  region = c("co_regiao_brasil", "no_regiao_brasil", "vl_indicador_calculado_reg"),
  health_region = c("co_regiao_saude", "no_regiao_saude", "vl_indicador_calculado_rs"),
  macro_region = c("co_macro", "no_macro", "vl_indicador_calculado_ms"),
  country = "vl_indicador_calculado_br"
)

extract_next_data <- function(url) {
  page <- paste(readLines(url, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  next_data <- regmatches(
    page,
    regexpr(
      "<script id=\"__NEXT_DATA__\" type=\"application/json\">.*?</script>",
      page,
      perl = TRUE
    )
  )

  if (length(next_data) != 1 || next_data == "") {
    stop("Could not find Next.js metadata in: ", url, call. = FALSE)
  }

  next_data <- sub(
    "^<script id=\"__NEXT_DATA__\" type=\"application/json\">",
    "",
    next_data
  )
  next_data <- sub("</script>$", "", next_data)
  jsonlite::fromJSON(next_data, simplifyVector = FALSE)
}

indicator_coverage <- function(download_url) {
  zip_file <- tempfile(fileext = ".zip")
  on.exit(unlink(zip_file), add = TRUE)

  utils::download.file(download_url, zip_file, mode = "wb", quiet = TRUE)
  csv_files <- utils::unzip(zip_file, list = TRUE)
  csv_files <- csv_files$Name[grepl("\\.csv$", csv_files$Name, ignore.case = TRUE)]

  if (length(csv_files) != 1) {
    stop("The CKAN download must contain exactly one CSV file.", call. = FALSE)
  }

  csv_file <- csv_files[[1]]
  header <- readr::read_csv(
    unz(zip_file, csv_file),
    n_max = 0,
    show_col_types = FALSE
  )
  names <- names(header)

  if ("co_anomes" %in% names) {
    coverage_from_current_file(zip_file, csv_file, names)
  } else {
    coverage_from_legacy_file(zip_file, csv_file, names)
  }
}

coverage_from_current_file <- function(zip_file, csv_file, names) {
  category_cols <- intersect(
    c(
      "sg_categoria",
      "ds_categoria",
      "co_item_categoria",
      "ds_item_categoria"
    ),
    names
  )
  data <- readr::read_csv(
    unz(zip_file, csv_file),
    col_select = dplyr::all_of(c("co_anomes", category_cols)),
    show_col_types = FALSE
  )

  period <- suppressWarnings(as.integer(data$co_anomes))
  dates <- period_to_date(period)
  categories <- current_categories(data)
  available_levels <- names(geography_specs)[vapply(
    geography_specs,
    function(cols) all(cols %in% names),
    logical(1)
  )]

  data.frame(
    spatial_granularity = paste(available_levels, collapse = ", "),
    time_granularity = infer_time_granularity(period),
    time_start = min(dates, na.rm = TRUE),
    time_end = max(dates, na.rm = TRUE),
    available_categories = categories$code,
    available_category_names = categories$name,
    stringsAsFactors = FALSE
  )
}

current_categories <- function(data) {
  if (!all(c("sg_categoria", "ds_categoria") %in% names(data))) {
    return(empty_categories())
  }

  source_code <- as.character(data$sg_categoria)
  source_name <- as.character(data$ds_categoria)

  if (all(c("co_item_categoria", "ds_item_categoria") %in% names(data))) {
    raw_item_code <- data$co_item_categoria
    item_code <- as.character(raw_item_code)
    item_name <- as.character(data$ds_item_categoria)
    has_item <- !is.na(raw_item_code) & nzchar(item_code)

    source_code[has_item] <- paste(source_code[has_item], item_code[has_item], sep = ":")
    source_name[has_item] <- paste(source_name[has_item], item_name[has_item], sep = ": ")
  }

  standardized <- standardize_category(source_code, source_name)
  codes <- sort(unique(standardized$code))
  names <- sort(unique(standardized$name))

  data.frame(
    code = paste(codes, collapse = ", "),
    name = paste(names, collapse = " | "),
    stringsAsFactors = FALSE
  )
}

period_to_date <- function(period) {
  year <- period %/% 100
  month <- period %% 100
  valid <- !is.na(period) & year >= 1000 & month >= 1 & month <= 12

  out <- rep(as.Date(NA), length(period))
  out[valid] <- as.Date(sprintf("%04d-%02d-01", year[valid], month[valid]))
  out
}

coverage_from_legacy_file <- function(zip_file, csv_file, names) {
  year_col <- first_existing_col(names, c("Ano", "ano"))
  if (is.na(year_col)) {
    return(empty_coverage())
  }

  data <- readr::read_csv(
    unz(zip_file, csv_file),
    col_select = dplyr::all_of(year_col),
    show_col_types = FALSE
  )
  years <- suppressWarnings(as.integer(data[[year_col]]))
  categories <- legacy_categories(names)

  levels <- character()
  if (!is.na(first_existing_col(names, c("Municipio", "Município")))) {
    levels <- c(levels, "municipality")
  }
  if (!is.na(first_existing_col(names, c("UF", "uf")))) {
    levels <- c(levels, "state")
  }
  if (length(levels) == 0) {
    levels <- "country"
  }

  data.frame(
    spatial_granularity = paste(levels, collapse = ", "),
    time_granularity = "annual",
    time_start = as.Date(paste0(min(years, na.rm = TRUE), "-01-01")),
    time_end = as.Date(paste0(max(years, na.rm = TRUE), "-01-01")),
    available_categories = categories$code,
    available_category_names = categories$name,
    stringsAsFactors = FALSE
  )
}

legacy_categories <- function(names) {
  numerator_cols <- grep("^Numerador", names, value = TRUE)
  if (length(numerator_cols) == 0) {
    return(empty_categories())
  }

  labels <- clean_legacy_category(numerator_cols)
  source_codes <- make.names(labels)
  standardized <- standardize_category(source_codes, labels)
  categories <- unique(data.frame(
    code = standardized$code,
    name = standardized$name
  ))
  categories <- categories[order(categories$code), , drop = FALSE]

  data.frame(
    code = paste(categories$code, collapse = ", "),
    name = paste(categories$name, collapse = " | "),
    stringsAsFactors = FALSE
  )
}

clean_legacy_category <- function(x) {
  x <- sub("^Numerador\\s*-\\s*", "", x)
  trimws(x)
}

standardize_category <- function(source_code, source_name) {
  parsed <- parse_category_name(source_name)
  group <- parsed$group
  item <- clean_category_label(parsed$item)

  is_total <- grepl("^todas? as categorias$", tolower(group)) |
    grepl("^todas? as categorias$", tolower(item)) |
    grepl("^total$", tolower(item))
  code <- ifelse(
    is_total,
    "total",
    paste(category_slug(group), category_slug(item), sep = ":")
  )
  name <- ifelse(is_total, "Total", paste(group, item, sep = ": "))

  missing_group <- is.na(group) | !nzchar(group)
  code[missing_group & !is_total] <- category_slug(item[missing_group & !is_total])
  name[missing_group & !is_total] <- item[missing_group & !is_total]

  data.frame(code = code, name = name, stringsAsFactors = FALSE)
}

parse_category_name <- function(x) {
  x <- as.character(x)
  has_group <- grepl(":", x, fixed = TRUE)
  group <- rep(NA_character_, length(x))
  item <- x

  group[has_group] <- trimws(sub(":.*$", "", x[has_group]))
  item[has_group] <- trimws(sub("^[^:]+:\\s*", "", x[has_group]))

  list(group = group, item = item)
}

clean_category_label <- function(x) {
  x <- trimws(as.character(x))
  x <- gsub("\\bc/", "com ", x)
  x <- gsub("([0-9]+)\\+", "\\1 ou mais", x)
  x <- gsub("\\bNone\\b", "Não informado", x)
  x <- gsub("\\s+", " ", x)
  x
}

category_slug <- function(x) {
  x <- remove_accents(as.character(x))
  x <- tolower(x)
  x <- gsub("\\+", "_plus", x)
  x <- gsub("[^a-z0-9]+", "_", x)
  x <- gsub("^_+|_+$", "", x)
  is_empty <- is.na(x) | !nzchar(x)
  x[is_empty] <- NA_character_
  x
}

remove_accents <- function(x) {
  x <- gsub("[áàâãäÁÀÂÃÄ]", "a", x)
  x <- gsub("[éèêëÉÈÊË]", "e", x)
  x <- gsub("[íìîïÍÌÎÏ]", "i", x)
  x <- gsub("[óòôõöÓÒÔÕÖ]", "o", x)
  x <- gsub("[úùûüÚÙÛÜ]", "u", x)
  x <- gsub("[çÇ]", "c", x)
  x <- gsub("[ñÑ]", "n", x)
  x
}

empty_coverage <- function() {
  data.frame(
    spatial_granularity = NA_character_,
    time_granularity = NA_character_,
    time_start = as.Date(NA),
    time_end = as.Date(NA),
    available_categories = NA_character_,
    available_category_names = NA_character_,
    stringsAsFactors = FALSE
  )
}

empty_categories <- function() {
  data.frame(
    code = NA_character_,
    name = NA_character_,
    stringsAsFactors = FALSE
  )
}

split_metadata_values <- function(x, split, fixed = FALSE) {
  if (length(x) != 1 || is.na(x) || !nzchar(x)) {
    return(character())
  }

  trimws(strsplit(x, split, fixed = fixed)[[1]])
}

first_existing_col <- function(names, candidates) {
  hit <- candidates[candidates %in% names]
  if (length(hit) == 0) {
    return(NA_character_)
  }

  hit[[1]]
}

infer_time_granularity <- function(period) {
  period <- period[!is.na(period)]
  if (length(period) == 0) {
    return(NA_character_)
  }

  year <- period %/% 100
  month <- period %% 100
  if (!all(year >= 1000 & month >= 1 & month <= 12)) {
    return("period")
  }

  months_by_year <- tapply(month, year, function(x) length(unique(x)))
  if (any(months_by_year > 1)) {
    return("monthly")
  }

  "annual"
}

indicator_rows <- lapply(ripsa_packages, function(package) {
  package_url <- paste0(portal_url, "/dataset/", package)
  page_props <- extract_next_data(package_url)$props$pageProps
  resources <- page_props$resources
  resources <- resources[vapply(
    resources,
    function(resource) identical(resource$format, "CSV"),
    logical(1)
  )]

  theme <- sub("^\\[RIPSA\\] ", "", page_props$title)

  rows <- lapply(resources, function(resource) {
    code <- sub(" - .*", "", resource$name)
    name <- sub("^[^-]+ - ", "", resource$name)
    code_parts <- strsplit(code, ".", fixed = TRUE)[[1]]
    dimension <- if (length(code_parts) >= 2) {
      paste("Dimensão", code_parts[[2]])
    } else {
      NA_character_
    }

    row <- data.frame(
      id = code,
      theme = theme,
      dimension = dimension,
      name = name,
      ckan_package = page_props$name,
      ckan_resource = resource$id,
      ckan_resource_url = paste0(package_url, "/resource/", resource$id),
      download_url = resource$url,
      stringsAsFactors = FALSE
    )

    cbind(row, indicator_coverage(resource$url))
  })

  do.call(rbind, rows)
})

indicators <- do.call(rbind, indicator_rows)
indicators <- indicators[order(indicators$theme, indicators$id), ]
row.names(indicators) <- NULL

indicator_categories <- do.call(
  rbind,
  lapply(seq_len(nrow(indicators)), function(i) {
    codes <- split_metadata_values(indicators$available_categories[[i]], ",")
    names <- split_metadata_values(
      indicators$available_category_names[[i]],
      "|",
      fixed = TRUE
    )
    n <- max(length(codes), length(names))
    if (n == 0) {
      return(NULL)
    }

    data.frame(
      indicator_code = indicators$id[[i]],
      category_id = seq_len(n),
      category_code = rep_len(codes, n),
      category_name = rep_len(names, n),
      category_source_code = NA_character_,
      category_source_name = NA_character_,
      stringsAsFactors = FALSE
    )
  })
)
row.names(indicator_categories) <- NULL

readr::write_csv(indicators, "data-raw/indicators.csv")
readr::write_csv(indicator_categories, "data-raw/indicator_categories.csv")
usethis::use_data(indicators, overwrite = TRUE)
usethis::use_data(indicator_categories, overwrite = TRUE)
