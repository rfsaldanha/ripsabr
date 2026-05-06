# Metadados dos indicadores RIPSA

Tabela com os indicadores RIPSA atualmente registrados no pacote.

## Usage

``` r
indicators
```

## Format

Uma tibble com as colunas:

- id:

  Código RIPSA do indicador.

- theme:

  Tema do indicador.

- dimension:

  Dimensão do indicador.

- name:

  Nome do indicador.

- ckan_package:

  Identificador do pacote CKAN.

- ckan_resource:

  Identificador do recurso CKAN.

- ckan_resource_url:

  URL da página do recurso CKAN.

- download_url:

  URL atual para baixar o arquivo CSV compactado do recurso CKAN.

- spatial_granularity:

  Níveis geográficos disponíveis no arquivo de origem, separados por
  vírgula.

- time_granularity:

  Granularidade temporal inferida a partir do arquivo de origem.

- time_start:

  Primeira data disponível no arquivo de origem.

- time_end:

  Última data disponível no arquivo de origem.

- available_categories:

  Códigos padronizados das categorias disponíveis, separados por
  vírgula.

- available_category_names:

  Nomes padronizados das categorias disponíveis, separados por barra
  vertical.
