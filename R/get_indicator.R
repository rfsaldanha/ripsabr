#' List available RIPSA indicators
#'
#' @return A tibble with one row per indicator currently registered in the
#'   package metadata.
#' @export
list_indicators <- function() {
  tibble::as_tibble(indicators)
}

#' List categories available for a RIPSA indicator
#'
#' @param code Character scalar. RIPSA indicator code, for example
#'   `"COB.4.01"`.
#'
#' @return A tibble with one row per category available in the indicator source
#'   file. `category_code` and `category_name` are standardized for package
#'   users. `category_source_code` and `category_source_name` contain raw source
#'   values when available. Use `category_id`, `category_code`, or
#'   `category_name` in `get_indicator()`.
#' @export
list_categories <- function(code) {
  code <- rlang::arg_match0(code, indicators$id)
  if (exists("indicator_categories", envir = topenv(), inherits = TRUE)) {
    categories <- get("indicator_categories", envir = topenv(), inherits = TRUE)
    return(tibble::as_tibble(categories[categories$indicator_code == code, , drop = FALSE]))
  }

  categories_from_indicator_metadata(code)
}

#' Download a RIPSA indicator
#'
#' `get_indicator()` downloads the indicator identified by `code` and returns a
#' standardized time series for the requested geographic level.
#'
#' @param code Character scalar. RIPSA indicator code, for example
#'   `"MRB.1.01"`.
#' @param geo Character scalar. Geographic level to return. One of
#'   `"municipality"`, `"state"`, `"region"`, `"health_region"`,
#'   `"macro_region"`, or `"country"`.
#' @param geo_code Optional vector of geographic codes to keep. Codes are
#'   compared as character values.
#' @param category Optional vector of category codes or names to keep. Use
#'   `"total"` for the total/all-categories rows when they are available in the
#'   source file. You can also pass a category name returned by
#'   `list_categories()`, such as
#'   `"Nascidos vivos com 7 ou mais consultas"`. Defaults to `NULL`, keeping
#'   every category present in the source file.
#' @param category_id Optional vector of category ids returned by
#'   `list_categories()`.
#'
#' @details
#' The easiest way to choose categories is to call `list_categories(code)` and
#' use the returned `category_id`, `category_code`, or `category_name`.
#'
#' For files with RIPSA category columns, `category` can receive a full
#' `category_code` returned by this function, such as `"TC:0"`, or a category
#' prefix, such as `"TC"`. Passing a prefix keeps every item under that
#' category.
#'
#' The category prefixes currently found in the RIPSA CKAN indicator files are:
#' `"API"`, `"COR"`, `"cor_raca"`, `"EA"`, `"ESP"`, `"ETI"`, `"EV"`, `"FE"`,
#' `"FER"`, `"fx_etaria"`, `"fx_rdpc"`, `"FXETC1"`, `"FXETC2"`, `"GC"`,
#' `"GIF"`, `"Idade"`, `"IG"`, `"PESSOA1"`, `"sap"`, `"SD"`, `"sexo"`,
#' `"SFE"`, `"SG"`, `"sitdom"`, `"SVA"`, `"TC"`, `"TD"`, `"tipoarea"`,
#' and `"TPC"`.
#'
#' For legacy numerator/denominator files, the source does not expose a fixed
#' category vocabulary. In these files, `category_code` is generated with
#' `make.names()` from each numerator column label after removing the
#' `"Numerador - "` prefix. Use `category = NULL` once to inspect the available
#' `category_code` values for a specific indicator.
#'
#' @return A tibble with standardized columns: `indicator_code`,
#'   `indicator_name`, `theme`, `dimension`, `period`, `date`, `geo_level`,
#'   `geo_code`, `geo_name`, `value`, `unit`, `category_code`, `category`, and
#'   `update_date`. For legacy RIPSA files that expose more than one numerator,
#'   `category_code` and `category` identify the numerator used to calculate
#'   each value.
#' @importFrom rlang .data .env
#' @export
get_indicator <- function(
  code,
  geo = c(
    "municipality",
    "state",
    "region",
    "health_region",
    "macro_region",
    "country"
  ),
  geo_code = NULL,
  category = NULL,
  category_id = NULL
) {
  code <- rlang::arg_match0(code, indicators$id)
  geo <- rlang::arg_match(geo)

  indicator_info <- indicators[indicators$id == code, , drop = FALSE]
  if (is.na(indicator_info$ckan_resource_url)) {
    rlang::abort(
      sprintf(
        "Indicator %s is registered, but its CKAN resource is not available yet.",
        code
      )
    )
  }

  indicator_name <- indicator_info$name[[1]]
  spatial_granularity <- indicator_info$spatial_granularity[[1]]
  time_granularity <- indicator_info$time_granularity[[1]]
  time_start <- format(indicator_info$time_start[[1]])
  time_end <- format(indicator_info$time_end[[1]])
  validate_geo_available(geo, indicator_info)

  if (
    identical(spatial_granularity, "municipality") &&
      geo == "municipality" &&
      is.null(geo_code) &&
      is.null(category) &&
      is.null(category_id)
  ) {
    cli::cli_warn(c(
      "!" = "This request will return every municipality and every category available in the source file.",
      "i" = "Use {.code geo_code} and/or {.code category} to reduce download processing and output size."
    ))
  }

  cli::cli_inform(c(
    "i" = "Preparing RIPSA indicator {.val {code}}: {.strong {indicator_name}}.",
    "i" = paste(
      "Available coverage: spatial {.val {spatial_granularity}},",
      "time {.val {time_granularity}} from {.val {time_start}}",
      "to {.val {time_end}}."
    )
  ))
  category_filter <- resolve_category_filter(NULL, indicator_info, category, category_id)

  cli::cli_inform(c(
    "i" = "Downloading source data from the SUS Open Data portal."
  ))
  raw_data <- read_indicator_data(indicator_info, geo, geo_code, category_filter)

  cli::cli_inform(c(
    "i" = "Standardizing data for geographic level {.val {geo}}."
  ))
  out <- standardize_indicator(raw_data, indicator_info, geo, geo_code, category_filter)
  cli::cli_inform(c(
    "v" = "Returned {.val {nrow(out)}} rows."
  ))

  out
}

validate_geo_available <- function(geo, indicator_info) {
  available <- split_metadata_values(indicator_info$spatial_granularity[[1]], ",")
  if (length(available) == 0 || geo %in% available) {
    return(invisible(TRUE))
  }

  rlang::abort(
    sprintf(
      "Geographic level '%s' is not available for indicator %s. Available levels: %s.",
      geo,
      indicator_info$id[[1]],
      paste(available, collapse = ", ")
    )
  )
}

read_indicator_data <- function(
  indicator_info,
  geo = NULL,
  geo_code = NULL,
  category_filter = NULL
) {
  download_url <- ckan_download_url(indicator_info)
  zip_file <- tempfile(fileext = ".zip")
  on.exit(unlink(zip_file), add = TRUE)

  utils::download.file(download_url, zip_file, mode = "wb", quiet = TRUE)
  csv_files <- utils::unzip(zip_file, list = TRUE)
  csv_size <- csv_files$Length[grepl("\\.csv$", csv_files$Name, ignore.case = TRUE)]
  csv_files <- csv_files$Name[grepl("\\.csv$", csv_files$Name, ignore.case = TRUE)]
  if (length(csv_files) != 1) {
    rlang::abort("The CKAN download must contain exactly one CSV file.")
  }

  cli::cli_inform(c(
    "i" = "Reading source CSV ({.val {format_file_size(csv_size)}} uncompressed)."
  ))
  header <- readr::read_csv(
    unz(zip_file, csv_files),
    n_max = 0,
    show_col_types = FALSE
  )
  cols <- indicator_read_columns(names(header), geo, category_filter)

  readr::read_csv(
    unz(zip_file, csv_files),
    col_select = dplyr::all_of(cols),
    show_col_types = FALSE
  )
}

read_indicator_category_data <- function(indicator_info) {
  download_url <- ckan_download_url(indicator_info)
  zip_file <- tempfile(fileext = ".zip")
  on.exit(unlink(zip_file), add = TRUE)

  utils::download.file(download_url, zip_file, mode = "wb", quiet = TRUE)
  csv_files <- utils::unzip(zip_file, list = TRUE)
  csv_files <- csv_files$Name[grepl("\\.csv$", csv_files$Name, ignore.case = TRUE)]
  if (length(csv_files) != 1) {
    rlang::abort("The CKAN download must contain exactly one CSV file.")
  }

  header <- readr::read_csv(
    unz(zip_file, csv_files),
    n_max = 0,
    show_col_types = FALSE
  )
  category_cols <- intersect(
    c("sg_categoria", "ds_categoria", "co_item_categoria", "ds_item_categoria"),
    names(header)
  )

  if (!"co_anomes" %in% names(header) || length(category_cols) == 0) {
    return(header)
  }

  readr::read_csv(
    unz(zip_file, csv_files),
    col_select = dplyr::all_of(c("co_anomes", category_cols)),
    show_col_types = FALSE
  )
}

format_file_size <- function(bytes) {
  if (length(bytes) != 1 || is.na(bytes)) {
    return(NA_character_)
  }

  units <- c("B", "KB", "MB", "GB")
  unit <- 1L
  size <- bytes
  while (size >= 1024 && unit < length(units)) {
    size <- size / 1024
    unit <- unit + 1L
  }

  sprintf("%.1f %s", size, units[[unit]])
}

ckan_download_url <- function(resource) {
  if (is.data.frame(resource)) {
    resource_url <- resource$ckan_resource_url[[1]]
    fallback_url <- resource$download_url[[1]]
  } else {
    resource_url <- resource
    fallback_url <- NA_character_
  }

  if (!is.null(fallback_url) && !is.na(fallback_url) && nzchar(fallback_url)) {
    return(fallback_url)
  }

  resource_page <- paste(
    readLines(resource_url, warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )
  next_data <- regmatches(
    resource_page,
    regexpr(
      "<script id=\"__NEXT_DATA__\" type=\"application/json\">.*?</script>",
      resource_page,
      perl = TRUE
    )
  )
  if (length(next_data) != 1 || next_data == "") {
    rlang::abort("Could not find CKAN resource metadata on the resource page.")
  }

  next_data <- sub(
    "^<script id=\"__NEXT_DATA__\" type=\"application/json\">",
    "",
    next_data
  )
  next_data <- sub("</script>$", "", next_data)
  metadata <- jsonlite::fromJSON(next_data, simplifyVector = FALSE)
  download_url <- metadata$props$pageProps$url

  if (is.null(download_url) || !nzchar(download_url)) {
    download_url <- fallback_url
  }

  if (is.null(download_url) || is.na(download_url) || !nzchar(download_url)) {
    rlang::abort("Could not find a download URL in the CKAN resource metadata.")
  }

  download_url
}

indicator_read_columns <- function(names, geo = NULL, category_filter = NULL) {
  if (!"co_anomes" %in% names) {
    return(legacy_read_columns(names, geo, category_filter))
  }

  if (is.null(geo)) {
    geo <- "municipality"
  }
  spec <- geography_spec(geo)
  cols <- c(
    "co_anomes",
    "dt_competencia",
    "dt_atualizacao",
    "ds_unidade_medida",
    "sg_categoria",
    "ds_categoria",
    "co_item_categoria",
    "ds_item_categoria",
    spec$value
  )
  if (!is.null(spec$code)) {
    cols <- c(cols, spec$code, spec$name)
  }

  unique(intersect(cols, names))
}

legacy_read_columns <- function(names, geo = NULL, category_filter = NULL) {
  year_col <- first_existing_col_from_names(names, c("Ano", "ano"))
  denominator_col <- first_existing_col_from_names(names, c(
    grep("^Denominador", names, value = TRUE),
    grep("^Demoninador", names, value = TRUE)
  ))
  multiplier_col <- first_existing_col_from_names(names, c("Multiplicador", "Fator"))
  numerator_cols <- grep("^Numerador", names, value = TRUE)

  if (!is.null(category_filter) && length(numerator_cols) > 0) {
    categories <- legacy_indicator_categories_from_names(names)
    keep <- category_pair_matches(
      categories$category_code,
      categories$category_name,
      category_filter
    )
    numerator_cols <- numerator_cols[keep]
  }

  geo_cols <- character()
  if (is.null(geo) || geo == "municipality") {
    geo_cols <- c(geo_cols, first_existing_col_from_names(names, c("Municipio", "Munic\u00edpio")))
  }
  if (is.null(geo) || geo == "state") {
    geo_cols <- c(geo_cols, first_existing_col_from_names(names, c("UF", "uf")))
  }

  cols <- unique(c(year_col, geo_cols, numerator_cols, denominator_col, multiplier_col))
  cols[!is.na(cols)]
}

first_existing_col_from_names <- function(names, candidates) {
  candidates <- candidates[!is.na(candidates)]
  hit <- candidates[candidates %in% names]
  if (length(hit) == 0) {
    return(NA_character_)
  }

  hit[[1]]
}

standardize_indicator <- function(
  data,
  indicator_info,
  geo,
  geo_code = NULL,
  category_filter = NULL
) {
  if (!is.null(category_filter) && !is.data.frame(category_filter)) {
    category_filter <- resolve_category_filter(
      data,
      indicator_info,
      category = category_filter
    )
  }

  if (!"co_anomes" %in% names(data)) {
    return(
      standardize_legacy_indicator(data, indicator_info, geo, geo_code, category_filter)
    )
  }

  spec <- geography_spec(geo)
  required_cols <- c(
    "co_anomes",
    spec$value,
    "dt_competencia",
    "dt_atualizacao",
    "ds_unidade_medida",
    "sg_categoria",
    "ds_categoria"
  )
  if (!is.null(spec$code)) {
    required_cols <- c(required_cols, spec$code, spec$name)
  }
  missing_cols <- setdiff(required_cols, names(data))
  if (length(missing_cols) > 0) {
    rlang::abort(
      paste(
        "The indicator data is missing required columns:",
        paste(missing_cols, collapse = ", ")
      )
    )
  }

  category_info <- source_category(data)
  keep <- rep(TRUE, nrow(data))
  if (!is.null(spec$code) && !is.null(geo_code)) {
    keep <- keep & as.character(data[[spec$code]]) %in% as.character(geo_code)
  }
  if (!is.null(category_filter)) {
    keep <- keep & category_pair_matches(
      category_info$code,
      category_info$name,
      category_filter
    )
  }
  data <- data[keep, , drop = FALSE]
  category_info$code <- category_info$code[keep]
  category_info$name <- category_info$name[keep]

  if (is.null(spec$code)) {
    out <- dplyr::transmute(
      data,
      indicator_code = indicator_info$id,
      indicator_name = indicator_info$name,
      theme = indicator_info$theme,
      dimension = indicator_info$dimension,
      period = .data$co_anomes,
      date = as.Date(.data$dt_competencia),
      geo_level = spec$level,
      geo_code = "BR",
      geo_name = "Brasil",
      value = .data[[spec$value]],
      unit = .data$ds_unidade_medida,
      category_code = .env$category_info$code,
      category = .env$category_info$name,
      update_date = as.Date(.data$dt_atualizacao)
    )
  } else {
    out <- dplyr::transmute(
      data,
      indicator_code = indicator_info$id,
      indicator_name = indicator_info$name,
      theme = indicator_info$theme,
      dimension = indicator_info$dimension,
      period = .data$co_anomes,
      date = as.Date(.data$dt_competencia),
      geo_level = spec$level,
      geo_code = as.character(.data[[spec$code]]),
      geo_name = as.character(.data[[spec$name]]),
      value = .data[[spec$value]],
      unit = .data$ds_unidade_medida,
      category_code = .env$category_info$code,
      category = .env$category_info$name,
      update_date = as.Date(.data$dt_atualizacao)
    )
  }

  dplyr::arrange(
    dplyr::distinct(tibble::as_tibble(out)),
    .data$geo_code,
    .data$category_code,
    .data$period
  )
}

source_category <- function(data) {
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

  list(
    code = standardized$code,
    name = standardized$name,
    source_code = source_code,
    source_name = source_name
  )
}

build_indicator_categories <- function(data, indicator_info) {
  if (is.null(data)) {
    return(categories_from_indicator_metadata(indicator_info$id[[1]]))
  }

  if (!"co_anomes" %in% names(data)) {
    return(legacy_indicator_categories(data, indicator_info))
  }

  if (!all(c("sg_categoria", "ds_categoria") %in% names(data))) {
    return(empty_indicator_categories())
  }

  category_info <- source_category(data)
  out <- unique(
    data.frame(
      category_code = category_info$code,
      category_name = category_info$name,
      category_source_code = category_info$source_code,
      category_source_name = category_info$source_name,
      stringsAsFactors = FALSE
    )
  )
  out <- out[order(out$category_code, out$category_name), , drop = FALSE]
  out$category_id <- seq_len(nrow(out))

  tibble::as_tibble(
    out[c(
      "category_id",
      "category_code",
      "category_name",
      "category_source_code",
      "category_source_name"
    )]
  )
}

empty_indicator_categories <- function() {
  tibble::tibble(
    category_id = integer(),
    category_code = character(),
    category_name = character(),
    category_source_code = character(),
    category_source_name = character()
  )
}

legacy_indicator_categories <- function(data, indicator_info) {
  legacy_indicator_categories_from_names(names(data))
}

legacy_indicator_categories_from_names <- function(names) {
  numerator_cols <- grep("^Numerador", names, value = TRUE)
  category_source_name <- clean_legacy_category(numerator_cols)
  category_source_code <- make.names(category_source_name)
  standardized <- standardize_category(category_source_code, category_source_name)

  tibble::tibble(
    category_id = seq_along(numerator_cols),
    category_code = standardized$code,
    category_name = standardized$name,
    category_source_code = category_source_code,
    category_source_name = category_source_name
  )
}

categories_from_indicator_metadata <- function(code) {
  if (exists("indicator_categories", envir = topenv(), inherits = TRUE)) {
    categories <- get("indicator_categories", envir = topenv(), inherits = TRUE)
    return(tibble::as_tibble(categories[categories$indicator_code == code, , drop = FALSE]))
  }

  indicator_info <- indicators[indicators$id == code, , drop = FALSE]
  codes <- split_metadata_values(indicator_info$available_categories[[1]], ",")
  names <- split_metadata_values(indicator_info$available_category_names[[1]], "|", fixed = TRUE)
  n <- max(length(codes), length(names))
  if (n == 0) {
    out <- empty_indicator_categories()
    out$indicator_code <- character()
    return(out[c(
      "indicator_code",
      "category_id",
      "category_code",
      "category_name",
      "category_source_code",
      "category_source_name"
    )])
  }

  tibble::tibble(
    indicator_code = code,
    category_id = seq_len(n),
    category_code = rep_len(codes, n),
    category_name = rep_len(names, n),
    category_source_code = NA_character_,
    category_source_name = NA_character_
  )
}

split_metadata_values <- function(x, split, fixed = FALSE) {
  if (length(x) != 1 || is.na(x) || !nzchar(x)) {
    return(character())
  }

  trimws(strsplit(x, split, fixed = fixed)[[1]])
}

resolve_category_filter <- function(data, indicator_info, category = NULL, category_id = NULL) {
  if (is.null(category) && is.null(category_id)) {
    return(NULL)
  }

  categories <- build_indicator_categories(data, indicator_info)
  keep <- rep(FALSE, nrow(categories))

  if (!is.null(category_id)) {
    unknown_ids <- setdiff(as.integer(category_id), categories$category_id)
    if (length(unknown_ids) > 0) {
      rlang::abort(
        sprintf(
          "Unknown category_id for indicator %s: %s.",
          indicator_info$id[[1]],
          paste(unknown_ids, collapse = ", ")
        )
      )
    }
    keep <- keep | categories$category_id %in% as.integer(category_id)
  }

  if (!is.null(category)) {
    category <- normalize_category_alias(category)
    keep <- keep | category_matches(categories$category_code, category)
    keep <- keep | category_name_matches(categories$category_name, category)
    keep <- keep | category_matches(categories$category_source_code, category)
    keep <- keep | category_name_matches(categories$category_source_name, category)
  }

  out <- categories[keep, c("category_code", "category_name"), drop = FALSE]
  if (nrow(out) == 0) {
    rlang::abort(
      paste(
        sprintf("No category matched indicator %s.", indicator_info$id[[1]]),
        "Use list_categories() to inspect valid category_id and category_name values."
      )
    )
  }

  out
}

normalize_category_alias <- function(category) {
  category <- as.character(category)
  category[tolower(category) %in% c("total", "all", "todos", "todas", "tc", "tc:0")] <- "total"
  category[tolower(category) %in% c("female", "feminino", "mulher", "mulheres")] <- "Feminino"
  category[tolower(category) %in% c("male", "masculino", "homem", "homens")] <- "Masculino"
  category
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
  x <- gsub("\\bNone\\b", "N\u00e3o informado", x)
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
  x <- gsub("[\u00e1\u00e0\u00e2\u00e3\u00e4\u00c1\u00c0\u00c2\u00c3\u00c4]", "a", x)
  x <- gsub("[\u00e9\u00e8\u00ea\u00eb\u00c9\u00c8\u00ca\u00cb]", "e", x)
  x <- gsub("[\u00ed\u00ec\u00ee\u00ef\u00cd\u00cc\u00ce\u00cf]", "i", x)
  x <- gsub("[\u00f3\u00f2\u00f4\u00f5\u00f6\u00d3\u00d2\u00d4\u00d5\u00d6]", "o", x)
  x <- gsub("[\u00fa\u00f9\u00fb\u00fc\u00da\u00d9\u00db\u00dc]", "u", x)
  x <- gsub("[\u00e7\u00c7]", "c", x)
  x <- gsub("[\u00f1\u00d1]", "n", x)
  x
}

standardize_legacy_indicator <- function(
  data,
  indicator_info,
  geo,
  geo_code = NULL,
  category_filter = NULL
) {
  year_col <- first_existing_col(data, c("Ano", "ano"))
  if (is.na(year_col)) {
    rlang::abort("The indicator data does not have a year column.")
  }

  numerator_cols <- grep("^Numerador", names(data), value = TRUE)
  denominator_col <- first_existing_col(data, c(
    grep("^Denominador", names(data), value = TRUE),
    grep("^Demoninador", names(data), value = TRUE)
  ))
  multiplier_col <- first_existing_col(data, c("Multiplicador", "Fator"))

  if (length(numerator_cols) == 0 || is.na(denominator_col) || is.na(multiplier_col)) {
    rlang::abort(
      "Legacy RIPSA files must have numerator, denominator, and multiplier columns."
    )
  }

  geo_info <- legacy_geography(data, geo)
  if (!is.null(geo_code)) {
    keep <- geo_info$code %in% as.character(geo_code)
    data <- data[keep, , drop = FALSE]
    geo_info$code <- geo_info$code[keep]
    geo_info$name <- geo_info$name[keep]
  }
  legacy_categories <- legacy_indicator_categories(data, indicator_info)
  if (!is.null(category_filter)) {
    keep_category <- category_pair_matches(
      legacy_categories$category_code,
      legacy_categories$category_name,
      category_filter
    )
    numerator_cols <- numerator_cols[keep_category]
    legacy_categories <- legacy_categories[keep_category, , drop = FALSE]
  }
  denominator <- suppressWarnings(as.numeric(data[[denominator_col]]))
  multiplier <- suppressWarnings(as.numeric(data[[multiplier_col]]))

  out <- lapply(seq_along(numerator_cols), function(i) {
    numerator_col <- numerator_cols[[i]]
    numerator <- suppressWarnings(as.numeric(data[[numerator_col]]))
    value <- numerator / denominator * multiplier
    value[is.nan(value)] <- NA_real_

    tibble::tibble(
      indicator_code = indicator_info$id,
      indicator_name = indicator_info$name,
      theme = indicator_info$theme,
      dimension = indicator_info$dimension,
      period = as.integer(data[[year_col]]),
      date = as.Date(paste0(as.integer(data[[year_col]]), "-01-01")),
      geo_level = geo_info$level,
      geo_code = geo_info$code,
      geo_name = geo_info$name,
      value = value,
      unit = NA_character_,
      category_code = legacy_categories$category_code[[i]],
      category = legacy_categories$category_name[[i]],
      update_date = as.Date(NA)
    )
  })
  out <- dplyr::bind_rows(out)

  dplyr::arrange(
    dplyr::distinct(out),
    .data$geo_code,
    .data$category_code,
    .data$period
  )
}

legacy_geography <- function(data, geo) {
  municipality_col <- first_existing_col(data, c("Municipio", "Munic\u00edpio"))
  state_col <- first_existing_col(data, c("UF", "uf"))

  if (geo == "municipality" && !is.na(municipality_col)) {
    code <- format_geo_code(data[[municipality_col]])
    return(
      list(
        level = "municipality",
        code = code,
        name = municipality_name(code)
      )
    )
  }

  if (geo == "state" && !is.na(state_col)) {
    code <- format_geo_code(data[[state_col]])
    return(list(level = "state", code = code, name = code))
  }

  if (geo == "country" && is.na(municipality_col) && is.na(state_col)) {
    return(
      list(
        level = "country",
        code = rep("BR", nrow(data)),
        name = rep("Brasil", nrow(data))
      )
    )
  }

  rlang::abort(
    sprintf(
      "Geographic level '%s' is not available for this indicator source file.",
      geo
    )
  )
}

format_geo_code <- function(x) {
  if (is.numeric(x)) {
    return(format(x, scientific = FALSE, trim = TRUE))
  }

  as.character(x)
}

municipality_name <- function(code) {
  code <- as.character(code)
  names <- code

  aggregate_state <- grepl("^[0-9]{2}0000$", code)
  if (any(aggregate_state)) {
    state_names <- state_name_lookup()
    state_code <- substr(code[aggregate_state], 1, 2)
    matched_state <- state_names[state_code]
    has_state <- !is.na(matched_state)
    names[which(aggregate_state)[has_state]] <- paste0(
      matched_state[has_state],
      " (munic\u00edpio n\u00e3o especificado)"
    )
  }

  if (!exists("municipalities", envir = topenv(), inherits = TRUE)) {
    return(label_unmatched_municipalities(code, names))
  }

  lookup <- get("municipalities", envir = topenv(), inherits = TRUE)
  matched <- match(code, lookup$code_municipality)
  has_match <- !is.na(matched)
  names[has_match] <- lookup$name_municipality[matched[has_match]]

  label_unmatched_municipalities(code, names)
}

label_unmatched_municipalities <- function(code, names) {
  unmatched <- names == code
  names[unmatched] <- paste0("Munic\u00edpio n\u00e3o identificado (", code[unmatched], ")")

  names
}

state_name_lookup <- function() {
  c(
    "11" = "Rond\u00f4nia",
    "12" = "Acre",
    "13" = "Amazonas",
    "14" = "Roraima",
    "15" = "Par\u00e1",
    "16" = "Amap\u00e1",
    "17" = "Tocantins",
    "21" = "Maranh\u00e3o",
    "22" = "Piau\u00ed",
    "23" = "Cear\u00e1",
    "24" = "Rio Grande do Norte",
    "25" = "Para\u00edba",
    "26" = "Pernambuco",
    "27" = "Alagoas",
    "28" = "Sergipe",
    "29" = "Bahia",
    "31" = "Minas Gerais",
    "32" = "Esp\u00edrito Santo",
    "33" = "Rio de Janeiro",
    "35" = "S\u00e3o Paulo",
    "41" = "Paran\u00e1",
    "42" = "Santa Catarina",
    "43" = "Rio Grande do Sul",
    "50" = "Mato Grosso do Sul",
    "51" = "Mato Grosso",
    "52" = "Goi\u00e1s",
    "53" = "Distrito Federal"
  )
}

first_existing_col <- function(data, candidates) {
  candidates <- candidates[!is.na(candidates)]
  hit <- candidates[candidates %in% names(data)]
  if (length(hit) == 0) {
    return(NA_character_)
  }
  hit[[1]]
}

clean_legacy_category <- function(x) {
  x <- sub("^Numerador\\s*-\\s*", "", x)
  trimws(x)
}

category_matches <- function(category_code, category) {
  category <- as.character(category)
  category_code %in% category |
    sub(":.*$", "", category_code) %in% category
}

category_name_matches <- function(category_name, category) {
  category <- tolower(as.character(category))
  category_name <- tolower(as.character(category_name))
  short_name <- sub("^.*:\\s*", "", category_name)

  category_name %in% category | short_name %in% category
}

category_pair_matches <- function(category_code, category_name, category_filter) {
  paste(category_code, category_name, sep = "\r") %in%
    paste(category_filter$category_code, category_filter$category_name, sep = "\r")
}

geography_spec <- function(geo) {
  switch(
    geo,
    municipality = list(
      level = "municipality",
      code = "co_ibge",
      name = "no_municipio",
      value = "vl_indicador_calculado_mun"
    ),
    state = list(
      level = "state",
      code = "co_uf",
      name = "no_uf",
      value = "vl_indicador_calculado_uf"
    ),
    region = list(
      level = "region",
      code = "co_regiao_brasil",
      name = "no_regiao_brasil",
      value = "vl_indicador_calculado_reg"
    ),
    health_region = list(
      level = "health_region",
      code = "co_regiao_saude",
      name = "no_regiao_saude",
      value = "vl_indicador_calculado_rs"
    ),
    macro_region = list(
      level = "macro_region",
      code = "co_macro",
      name = "no_macro",
      value = "vl_indicador_calculado_ms"
    ),
    country = list(
      level = "country",
      code = NULL,
      name = NULL,
      value = "vl_indicador_calculado_br"
    )
  )
}
