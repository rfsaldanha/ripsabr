# RIPSA indicator category metadata

A dataset with standardized category metadata for each RIPSA indicator.

## Usage

``` r
indicator_categories
```

## Format

A tibble with columns:

- indicator_code:

  RIPSA indicator code.

- category_id:

  Sequential category id within each indicator.

- category_code:

  Standardized category code for use in
  [`get_indicator()`](https://rfsaldanha.github.io/ripsabr/reference/get_indicator.md).

- category_name:

  Standardized category label.

- category_source_code:

  Raw source category code when available.

- category_source_name:

  Raw source category label when available.
