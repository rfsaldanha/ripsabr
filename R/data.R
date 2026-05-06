#' Metadados dos indicadores RIPSA
#'
#' Tabela com os indicadores RIPSA atualmente registrados no pacote.
#'
#' @format Uma tibble com as colunas:
#' \describe{
#'   \item{id}{Código RIPSA do indicador.}
#'   \item{theme}{Tema do indicador.}
#'   \item{dimension}{Dimensão do indicador.}
#'   \item{name}{Nome do indicador.}
#'   \item{ckan_package}{Identificador do pacote CKAN.}
#'   \item{ckan_resource}{Identificador do recurso CKAN.}
#'   \item{ckan_resource_url}{URL da página do recurso CKAN.}
#'   \item{download_url}{URL atual para baixar o arquivo CSV compactado do recurso CKAN.}
#'   \item{spatial_granularity}{Níveis geográficos disponíveis no arquivo de origem, separados por vírgula.}
#'   \item{time_granularity}{Granularidade temporal inferida a partir do arquivo de origem.}
#'   \item{time_start}{Primeira data disponível no arquivo de origem.}
#'   \item{time_end}{Última data disponível no arquivo de origem.}
#'   \item{available_categories}{Códigos padronizados das categorias disponíveis, separados por vírgula.}
#'   \item{available_category_names}{Nomes padronizados das categorias disponíveis, separados por barra vertical.}
#' }
"indicators"

#' Metadados das categorias dos indicadores RIPSA
#'
#' Tabela com metadados padronizados de categorias para cada indicador RIPSA.
#'
#' @format Uma tibble com as colunas:
#' \describe{
#'   \item{indicator_code}{Código RIPSA do indicador.}
#'   \item{category_id}{Identificador sequencial da categoria dentro de cada indicador.}
#'   \item{category_code}{Código padronizado da categoria para uso em `get_indicator()`.}
#'   \item{category_name}{Nome padronizado da categoria.}
#'   \item{category_source_code}{Código bruto da categoria no arquivo de origem, quando disponível.}
#'   \item{category_source_name}{Nome bruto da categoria no arquivo de origem, quando disponível.}
#' }
"indicator_categories"

utils::globalVariables(c("indicators", "indicator_categories"))
