test_that("indicator metadata includes source coverage", {
  out <- list_indicators()

  expect_true(all(
    c(
      "spatial_granularity",
      "time_granularity",
      "time_start",
      "time_end",
      "available_categories",
      "available_category_names"
    ) %in% names(out)
  ))
  expect_s3_class(out$time_start, "Date")
  expect_s3_class(out$time_end, "Date")
  expect_true(any(!is.na(out$available_categories)))
})

test_that("user can discover categories and request a legacy municipality indicator", {
  categories <- list_categories("COB.4.02")
  category_id <- categories$category_id[
    categories$category_code == "nascidos_vivos_de_partos_hospitalares"
  ]
  expect_length(category_id, 1L)

  raw_data <- tibble::tibble(
    Indicador = c("COB.4.02", "COB.4.02"),
    ano = c(2023L, 2024L),
    Municipio = c(130260L, 130260L),
    `Numerador - Nascidos vivos de partos hospitalares` = c(900, 950),
    `Denominador - Nascidos vivos` = c(1000, 1000),
    Multiplicador = c(100, 100)
  )
  testthat::local_mocked_bindings(
    read_indicator_data = function(...) raw_data,
    .package = "ripsabr"
  )

  out <- suppressMessages(
    get_indicator(
      code = "COB.4.02",
      geo = "municipality",
      geo_code = 130260,
      category_id = category_id
    )
  )

  expect_equal(out$geo_code, c("130260", "130260"))
  expect_equal(out$geo_name, c("Manaus", "Manaus"))
  expect_equal(
    unique(out$category_code),
    "nascidos_vivos_de_partos_hospitalares"
  )
  expect_equal(
    unique(out$category),
    "Nascidos vivos de partos hospitalares"
  )
  expect_equal(out$value, c(90, 95))
})

test_that("get_indicator rejects unavailable geography before downloading", {
  testthat::local_mocked_bindings(
    read_indicator_data = function(...) {
      stop("download should not happen")
    },
    .package = "ripsabr"
  )

  expect_error(
    get_indicator(
      code = "COB.4.02",
      geo = "state"
    ),
    "Geographic level 'state' is not available for indicator COB.4.02"
  )
})

test_that("user can request a current indicator by readable category name", {
  raw_data <- tibble::tibble(
    co_anomes = c(202312L, 202312L),
    co_uf = c(13L, 13L),
    no_uf = c("Amazonas", "Amazonas"),
    vl_indicador_calculado_uf = c(10, 20),
    dt_competencia = as.POSIXct(c("2023-12-01", "2023-12-01")),
    dt_atualizacao = as.POSIXct(c("2026-01-26", "2026-01-26")),
    ds_unidade_medida = c("Numero", "Numero"),
    sg_categoria = c("ESP", "ESP"),
    ds_categoria = c("Especialidade", "Especialidade"),
    co_item_categoria = c(0L, 0L),
    ds_item_categoria = c("Médico urologista", "Médico pediatra")
  )
  testthat::local_mocked_bindings(
    read_indicator_data = function(...) raw_data,
    .package = "ripsabr"
  )

  out <- suppressMessages(
    get_indicator(
      code = "COB.1.02",
      geo = "state",
      geo_code = 13,
      category = "Médico pediatra"
    )
  )

  expect_equal(nrow(out), 1L)
  expect_equal(out$geo_name, "Amazonas")
  expect_equal(out$category_code, "especialidade:medico_pediatra")
  expect_equal(out$category, "Especialidade: Médico pediatra")
  expect_equal(out$value, 20)
})

test_that("user can request total category with the simple total alias", {
  raw_data <- tibble::tibble(
    co_anomes = c(202312L, 202412L),
    co_uf = c(13L, 13L),
    no_uf = c("Amazonas", "Amazonas"),
    vl_indicador_calculado_uf = c(5, 7),
    dt_competencia = as.POSIXct(c("2023-12-01", "2024-12-01")),
    dt_atualizacao = as.POSIXct(c("2026-01-26", "2026-01-26")),
    ds_unidade_medida = c("Numero", "Numero"),
    sg_categoria = c("TC", "TC"),
    ds_categoria = c("Todas as categorias", "Todas as categorias")
  )
  testthat::local_mocked_bindings(
    read_indicator_data = function(...) raw_data,
    .package = "ripsabr"
  )

  out <- suppressMessages(
    get_indicator(
      code = "MRB.1.01",
      geo = "state",
      geo_code = 13,
      category = "total"
    )
  )

  expect_equal(out$category_code, c("total", "total"))
  expect_equal(out$category, c("Total", "Total"))
  expect_equal(out$value, c(5, 7))
})

test_that("list_categories returns an empty category table for uncategorized indicators", {
  out <- list_categories("COB.1.03")

  expect_named(
    out,
    c(
      "indicator_code",
      "category_id",
      "category_code",
      "category_name",
      "category_source_code",
      "category_source_name"
    )
  )
  expect_equal(nrow(out), 0L)
})

test_that("current indicator column selection reads only requested geography columns", {
  cols <- ripsabr:::indicator_read_columns(
    c(
      "co_anomes",
      "dt_competencia",
      "dt_atualizacao",
      "ds_unidade_medida",
      "sg_categoria",
      "ds_categoria",
      "co_uf",
      "no_uf",
      "co_ibge",
      "no_municipio",
      "vl_indicador_calculado_uf",
      "vl_indicador_calculado_mun"
    ),
    geo = "state"
  )

  expect_true(all(c("co_uf", "no_uf", "vl_indicador_calculado_uf") %in% cols))
  expect_false("co_ibge" %in% cols)
  expect_false("vl_indicador_calculado_mun" %in% cols)
})

test_that("legacy indicator column selection keeps only selected numerator", {
  category_filter <- tibble::tibble(
    category_code = "other_cases",
    category_name = "Other cases"
  )
  cols <- ripsabr:::indicator_read_columns(
    c(
      "Ano",
      "Municipio",
      "Numerador - Cases",
      "Numerador - Other cases",
      "Denominador - Population",
      "Multiplicador"
    ),
    geo = "municipality",
    category_filter = category_filter
  )

  expect_true("Numerador - Other cases" %in% cols)
  expect_false("Numerador - Cases" %in% cols)
})

test_that("indicator_categories returns user-facing ids and names", {
  raw_data <- tibble::tibble(
    co_anomes = c(202312L, 202312L),
    dt_competencia = as.POSIXct(c("2023-12-01", "2023-12-01")),
    sg_categoria = c("ESP", "ESP"),
    ds_categoria = c("Especialidade", "Especialidade"),
    co_item_categoria = c(0L, 0L),
    ds_item_categoria = c("Médico urologista", "Médico pediatra")
  )
  indicator_info <- indicators[indicators$id == "COB.1.02", , drop = FALSE]

  out <- ripsabr:::build_indicator_categories(raw_data, indicator_info)

  expect_named(
    out,
    c(
      "category_id",
      "category_code",
      "category_name",
      "category_source_code",
      "category_source_name"
    )
  )
  expect_equal(out$category_id, c(1L, 2L))
  expect_equal(
    out$category_code,
    c("especialidade:medico_pediatra", "especialidade:medico_urologista")
  )
  expect_equal(
    out$category_name,
    c("Especialidade: Médico pediatra", "Especialidade: Médico urologista")
  )
  expect_equal(out$category_source_code, c("ESP:0", "ESP:0"))
})

test_that("standardize_indicator returns a state time series", {
  raw_data <- tibble::tibble(
    co_anomes = c(202312L, 202312L, 202412L),
    co_ibge = c(130260L, 130356L, 130260L),
    no_municipio = c("Manaus", "Rio Preto da Eva", "Manaus"),
    co_uf = c(13L, 13L, 13L),
    no_uf = c("Amazonas", "Amazonas", "Amazonas"),
    vl_indicador_calculado_uf = c(10, 10, 12),
    vl_indicador_calculado_br = c(100, 100, 120),
    dt_competencia = as.POSIXct(c("2023-12-01", "2023-12-01", "2024-12-01")),
    dt_atualizacao = as.POSIXct(c("2026-01-26", "2026-01-26", "2026-01-26")),
    ds_unidade_medida = c("Numero", "Numero", "Numero"),
    sg_categoria = c("TC", "TC", "TC"),
    ds_categoria = c("Todas as categorias", "Todas as categorias", "Todas as categorias")
  )
  indicator_info <- indicators[indicators$id == "MRB.1.01", , drop = FALSE]

  out <- ripsabr:::standardize_indicator(
    raw_data,
    indicator_info,
    geo = "state",
    geo_code = 13,
    category = "TC"
  )

  expect_s3_class(out, "tbl_df")
  expect_named(
    out,
    c(
      "indicator_code",
      "indicator_name",
      "theme",
      "dimension",
      "period",
      "date",
      "geo_level",
      "geo_code",
      "geo_name",
      "value",
      "unit",
      "category_code",
      "category",
      "update_date"
    )
  )
  expect_true(all(out$indicator_code == "MRB.1.01"))
  expect_true(all(out$geo_level == "state"))
  expect_true(all(out$geo_code == "13"))
  expect_true(all(out$category_code == "total"))
  expect_equal(nrow(out), length(unique(out$period)))
})

test_that("standardize_indicator filters duplicated category codes by category name", {
  raw_data <- tibble::tibble(
    co_anomes = c(202312L, 202312L),
    co_uf = c(13L, 13L),
    no_uf = c("Amazonas", "Amazonas"),
    vl_indicador_calculado_uf = c(10, 20),
    dt_competencia = as.POSIXct(c("2023-12-01", "2023-12-01")),
    dt_atualizacao = as.POSIXct(c("2026-01-26", "2026-01-26")),
    ds_unidade_medida = c("Numero", "Numero"),
    sg_categoria = c("ESP", "ESP"),
    ds_categoria = c("Especialidade", "Especialidade"),
    co_item_categoria = c(0L, 0L),
    ds_item_categoria = c("Médico urologista", "Médico pediatra")
  )
  indicator_info <- indicators[indicators$id == "COB.1.02", , drop = FALSE]

  category_filter <- ripsabr:::resolve_category_filter(
    raw_data,
    indicator_info,
    category = "Médico pediatra"
  )
  out <- ripsabr:::standardize_indicator(
    raw_data,
    indicator_info,
    geo = "state",
    category_filter = category_filter
  )

  expect_equal(nrow(out), 1L)
  expect_equal(out$category, "Especialidade: Médico pediatra")
  expect_equal(out$value, 20)
})

test_that("standardize_indicator returns a country time series", {
  raw_data <- tibble::tibble(
    co_anomes = c(202312L, 202312L, 202412L),
    vl_indicador_calculado_br = c(100, 100, 120),
    dt_competencia = as.POSIXct(c("2023-12-01", "2023-12-01", "2024-12-01")),
    dt_atualizacao = as.POSIXct(c("2026-01-26", "2026-01-26", "2026-01-26")),
    ds_unidade_medida = c("Numero", "Numero", "Numero"),
    sg_categoria = c("TC", "TC", "TC"),
    ds_categoria = c("Todas as categorias", "Todas as categorias", "Todas as categorias")
  )
  indicator_info <- indicators[indicators$id == "MRB.1.01", , drop = FALSE]

  out <- ripsabr:::standardize_indicator(
    raw_data,
    indicator_info,
    geo = "country",
    category = "TC"
  )

  expect_true(all(out$geo_level == "country"))
  expect_true(all(out$geo_code == "BR"))
  expect_true(all(out$geo_name == "Brasil"))
  expect_equal(nrow(out), length(unique(out$period)))
})

test_that("ckan_download_url extracts the current resource download URL", {
  resource_page <- tempfile(fileext = ".html")
  writeLines(
    paste0(
      '<script id="__NEXT_DATA__" type="application/json">',
      '{"props":{"pageProps":{"url":"https://example.org/ripsa.csv.zip"}}}',
      "</script>"
    ),
    resource_page
  )

  expect_equal(
    ripsabr:::ckan_download_url(resource_page),
    "https://example.org/ripsa.csv.zip"
  )
})

test_that("standardize_indicator handles legacy numerator denominator files", {
  raw_data <- tibble::tibble(
    Indicador = c("Example", "Example"),
    Ano = c(2023L, 2024L),
    UF = c("AM", "AM"),
    `Numerador - Cases` = c(10, 12),
    `Denominador - Population` = c(1000, 1000),
    Multiplicador = c(100000, 100000)
  )
  indicator_info <- indicators[indicators$id == "SOC.1.01", , drop = FALSE]

  out <- ripsabr:::standardize_indicator(
    raw_data,
    indicator_info,
    geo = "state",
    geo_code = "AM"
  )

  expect_s3_class(out, "tbl_df")
  expect_equal(out$geo_code, c("AM", "AM"))
  expect_equal(out$value, c(1000, 1200))
  expect_equal(out$category, c("Cases", "Cases"))
})

test_that("standardize_indicator resolves legacy municipality names", {
  raw_data <- tibble::tibble(
    Indicador = c("Example"),
    Ano = c(2024L),
    Municipio = c(130260L),
    `Numerador - Cases` = c(10),
    `Denominador - Population` = c(1000),
    Multiplicador = c(100000)
  )
  indicator_info <- indicators[indicators$id == "COB.4.02", , drop = FALSE]

  out <- ripsabr:::standardize_indicator(
    raw_data,
    indicator_info,
    geo = "municipality",
    geo_code = 130260
  )

  expect_equal(out$geo_code, "130260")
  expect_equal(out$geo_name, "Manaus")
})

test_that("legacy municipality fallback labels aggregate and unknown codes", {
  expect_equal(
    ripsabr:::municipality_name(c("130000", "431453")),
    c(
      "Amazonas (município não especificado)",
      "Município não identificado (431453)"
    )
  )
  expect_equal(ripsabr:::format_geo_code(500000), "500000")
})

test_that("standardize_indicator accepts legacy category names", {
  raw_data <- tibble::tibble(
    Indicador = c("Example", "Example"),
    Ano = c(2023L, 2024L),
    UF = c("AM", "AM"),
    `Numerador - Cases` = c(10, 12),
    `Numerador - Other cases` = c(20, 22),
    `Denominador - Population` = c(1000, 1000),
    Multiplicador = c(100000, 100000)
  )
  indicator_info <- indicators[indicators$id == "SOC.1.01", , drop = FALSE]

  categories <- ripsabr:::build_indicator_categories(raw_data, indicator_info)
  expect_equal(categories$category_name, c("Cases", "Other cases"))

  category_filter <- ripsabr:::resolve_category_filter(
    raw_data,
    indicator_info,
    category_id = 2
  )
  out <- ripsabr:::standardize_indicator(
    raw_data,
    indicator_info,
    geo = "state",
    geo_code = "AM",
    category_filter = category_filter
  )

  expect_equal(unique(out$category), "Other cases")
  expect_equal(out$value, c(2000, 2200))
})

test_that("category matching accepts aggregate category prefixes", {
  expect_true(all(ripsabr:::category_matches(c("TC", "TC:0"), "TC")))
  expect_false(ripsabr:::category_matches("sexo:0", "TC"))
})
