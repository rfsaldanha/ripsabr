# Metadados das categorias dos indicadores RIPSA

Tabela com metadados padronizados de categorias para cada indicador
RIPSA.

## Usage

``` r
indicator_categories
```

## Format

Uma tibble com as colunas:

- indicator_code:

  Código RIPSA do indicador.

- category_id:

  Identificador sequencial da categoria dentro de cada indicador.

- category_code:

  Código padronizado da categoria para uso em
  [`get_indicator()`](https://rfsaldanha.github.io/ripsabr/reference/get_indicator.md).

- category_name:

  Nome padronizado da categoria.

- category_source_code:

  Código bruto da categoria no arquivo de origem, quando disponível.

- category_source_name:

  Nome bruto da categoria no arquivo de origem, quando disponível.
