# Liste as categorias disponíveis para um indicador RIPSA

Liste as categorias disponíveis para um indicador RIPSA

## Usage

``` r
list_categories(code)
```

## Arguments

- code:

  Escalar de texto. Código RIPSA do indicador, por exemplo `"COB.4.01"`.

## Value

Uma tibble com uma linha por categoria disponível no arquivo de origem
do indicador. `category_code` e `category_name` são padronizados para
uso no pacote. `category_source_code` e `category_source_name` contêm os
valores brutos da fonte quando disponíveis. Use `category_id`,
`category_code` ou `category_name` em
[`get_indicator()`](https://rfsaldanha.github.io/ripsabr/reference/get_indicator.md).
