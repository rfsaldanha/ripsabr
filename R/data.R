#' RIPSA indicator metadata
#'
#' A dataset with the RIPSA indicators currently registered in the package.
#'
#' @format A tibble with columns:
#' \describe{
#'   \item{id}{RIPSA indicator code.}
#'   \item{theme}{Indicator theme.}
#'   \item{dimension}{Indicator dimension.}
#'   \item{name}{Indicator name.}
#'   \item{ckan_package}{CKAN package slug.}
#'   \item{ckan_resource}{CKAN resource id.}
#'   \item{ckan_resource_url}{CKAN resource page URL.}
#'   \item{download_url}{Current CSV zip download URL exposed by the CKAN resource.}
#'   \item{spatial_granularity}{Comma-separated geographic levels available in the source file.}
#'   \item{time_granularity}{Temporal granularity inferred from the source file.}
#'   \item{time_start}{First date available in the source file.}
#'   \item{time_end}{Last date available in the source file.}
#'   \item{available_categories}{Comma-separated standardized category codes available in the source file.}
#'   \item{available_category_names}{Pipe-separated standardized category labels available in the source file.}
#' }
"indicators"

#' RIPSA indicator category metadata
#'
#' A dataset with standardized category metadata for each RIPSA indicator.
#'
#' @format A tibble with columns:
#' \describe{
#'   \item{indicator_code}{RIPSA indicator code.}
#'   \item{category_id}{Sequential category id within each indicator.}
#'   \item{category_code}{Standardized category code for use in `get_indicator()`.}
#'   \item{category_name}{Standardized category label.}
#'   \item{category_source_code}{Raw source category code when available.}
#'   \item{category_source_name}{Raw source category label when available.}
#' }
"indicator_categories"

utils::globalVariables(c("indicators", "indicator_categories"))
