# RIPSA indicator metadata

A dataset with the RIPSA indicators currently registered in the package.

## Usage

``` r
indicators
```

## Format

A tibble with columns:

- id:

  RIPSA indicator code.

- theme:

  Indicator theme.

- dimension:

  Indicator dimension.

- name:

  Indicator name.

- ckan_package:

  CKAN package slug.

- ckan_resource:

  CKAN resource id.

- ckan_resource_url:

  CKAN resource page URL.

- download_url:

  Current CSV zip download URL exposed by the CKAN resource.

- spatial_granularity:

  Comma-separated geographic levels available in the source file.

- time_granularity:

  Temporal granularity inferred from the source file.

- time_start:

  First date available in the source file.

- time_end:

  Last date available in the source file.

- available_categories:

  Comma-separated standardized category codes available in the source
  file.

- available_category_names:

  Pipe-separated standardized category labels available in the source
  file.
