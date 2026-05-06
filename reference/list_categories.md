# List categories available for a RIPSA indicator

List categories available for a RIPSA indicator

## Usage

``` r
list_categories(code)
```

## Arguments

- code:

  Character scalar. RIPSA indicator code, for example `"COB.4.01"`.

## Value

A tibble with one row per category available in the indicator source
file. `category_code` and `category_name` are standardized for package
users. `category_source_code` and `category_source_name` contain raw
source values when available. Use `category_id`, `category_code`, or
`category_name` in
[`get_indicator()`](https://rfsaldanha.github.io/ripsabr/reference/get_indicator.md).
