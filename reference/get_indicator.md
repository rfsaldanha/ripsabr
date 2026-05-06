# Download a RIPSA indicator

`get_indicator()` downloads the indicator identified by `code` and
returns a standardized time series for the requested geographic level.

## Usage

``` r
get_indicator(
  code,
  geo = c("municipality", "state", "region", "health_region", "macro_region", "country"),
  geo_code = NULL,
  category = NULL,
  category_id = NULL
)
```

## Arguments

- code:

  Character scalar. RIPSA indicator code, for example `"MRB.1.01"`.

- geo:

  Character scalar. Geographic level to return. One of `"municipality"`,
  `"state"`, `"region"`, `"health_region"`, `"macro_region"`, or
  `"country"`.

- geo_code:

  Optional vector of geographic codes to keep. Codes are compared as
  character values.

- category:

  Optional vector of category codes or names to keep. Use `"total"` for
  the total/all-categories rows when they are available in the source
  file. You can also pass a category name returned by
  [`list_categories()`](https://rfsaldanha.github.io/ripsabr/reference/list_categories.md),
  such as `"Nascidos vivos com 7 ou mais consultas"`. Defaults to
  `NULL`, keeping every category present in the source file.

- category_id:

  Optional vector of category ids returned by
  [`list_categories()`](https://rfsaldanha.github.io/ripsabr/reference/list_categories.md).

## Value

A tibble with standardized columns: `indicator_code`, `indicator_name`,
`theme`, `dimension`, `period`, `date`, `geo_level`, `geo_code`,
`geo_name`, `value`, `unit`, `category_code`, `category`, and
`update_date`. For legacy RIPSA files that expose more than one
numerator, `category_code` and `category` identify the numerator used to
calculate each value.

## Details

The easiest way to choose categories is to call `list_categories(code)`
and use the returned `category_id`, `category_code`, or `category_name`.

For files with RIPSA category columns, `category` can receive a full
`category_code` returned by this function, such as `"TC:0"`, or a
category prefix, such as `"TC"`. Passing a prefix keeps every item under
that category.

The category prefixes currently found in the RIPSA CKAN indicator files
are: `"API"`, `"COR"`, `"cor_raca"`, `"EA"`, `"ESP"`, `"ETI"`, `"EV"`,
`"FE"`, `"FER"`, `"fx_etaria"`, `"fx_rdpc"`, `"FXETC1"`, `"FXETC2"`,
`"GC"`, `"GIF"`, `"Idade"`, `"IG"`, `"PESSOA1"`, `"sap"`, `"SD"`,
`"sexo"`, `"SFE"`, `"SG"`, `"sitdom"`, `"SVA"`, `"TC"`, `"TD"`,
`"tipoarea"`, and `"TPC"`.

For legacy numerator/denominator files, the source does not expose a
fixed category vocabulary. In these files, `category_code` is generated
with [`make.names()`](https://rdrr.io/r/base/make.names.html) from each
numerator column label after removing the `"Numerador - "` prefix. Use
`category = NULL` once to inspect the available `category_code` values
for a specific indicator.
