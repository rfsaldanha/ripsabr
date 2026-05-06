# Exemplos de uso

Este artigo mostra fluxos comuns para consultar indicadores da RIPSA com
o `ripsabr`. Os exemplos estão organizados para começar pela descoberta
dos indicadores e avançar para filtros por território e categoria.

``` r

library(ripsabr)
library(dplyr)
```

## Listar indicadores disponíveis

Use
[`list_indicators()`](https://rfsaldanha.github.io/ripsabr/reference/list_indicators.md)
para consultar o catálogo incluído no pacote.

``` r

indicadores <- list_indicators()

indicadores |>
  select(
    id,
    theme,
    dimension,
    name,
    spatial_granularity,
    time_start,
    time_end
  )
```

Para procurar indicadores por texto, filtre a coluna `name`.

``` r

indicadores |>
  filter(grepl("sarampo", name, ignore.case = TRUE)) |>
  select(id, theme, name, spatial_granularity, time_start, time_end)
```

## Consultar categorias

Alguns indicadores possuem estratos como sexo, faixa etária, raça/cor ou
uma categoria total. Antes de baixar os dados, consulte
[`list_categories()`](https://rfsaldanha.github.io/ripsabr/reference/list_categories.md).

``` r

list_categories("COB.4.01")
```

As colunas mais úteis são `category_id`, `category_code` e
`category_name`. Qualquer uma delas pode ser usada para filtrar
[`get_indicator()`](https://rfsaldanha.github.io/ripsabr/reference/get_indicator.md).

## Baixar indicador estadual

O exemplo abaixo baixa a incidência de sarampo no Amazonas, mantendo
apenas a categoria total.

``` r

sarampo_am <- get_indicator(
  code = "MRB.1.01",
  geo = "state",
  geo_code = 13,
  category = "total"
)

sarampo_am
```

## Baixar indicador municipal

Para municípios, informe o código IBGE de seis dígitos. O exemplo usa
Manaus (`130260`).

``` r

prenatal_manaus <- get_indicator(
  code = "COB.4.01",
  geo = "municipality",
  geo_code = 130260,
  category = "nascidos_vivos_com_7_ou_mais_consultas"
)

prenatal_manaus |>
  select(period, geo_name, value, unit, category)
```

## Filtrar por nome de categoria

Quando o nome aparece em
[`list_categories()`](https://rfsaldanha.github.io/ripsabr/reference/list_categories.md),
ele também pode ser informado de forma legível.

``` r

consultas_pediatria_am <- get_indicator(
  code = "COB.1.02",
  geo = "state",
  geo_code = 13,
  category = "Médico pediatra"
)

consultas_pediatria_am |>
  select(period, geo_name, value, category)
```

## Usar `category_id`

O uso de `category_id` evita ambiguidades quando um indicador tem muitos
estratos.

``` r

categorias <- list_categories("COB.4.02")

id_partos_hospitalares <- categorias$category_id[
  categorias$category_code == "nascidos_vivos_de_partos_hospitalares"
]

partos_manaus <- get_indicator(
  code = "COB.4.02",
  geo = "municipality",
  geo_code = 130260,
  category_id = id_partos_hospitalares
)

partos_manaus |>
  select(period, geo_name, value, category)
```

## Consultar indicador nacional

Para indicadores disponíveis apenas no nível nacional, use
`geo = "country"`.

``` r

pib_br <- get_indicator(
  code = "SOC.3.05",
  geo = "country",
  category = "total"
)

pib_br |>
  select(period, geo_name, value, unit)
```

## Trabalhar com a saída

A saída de
[`get_indicator()`](https://rfsaldanha.github.io/ripsabr/reference/get_indicator.md)
é uma tibble. Isso permite encadear filtros, agregações e gráficos com
ferramentas usuais do R.

``` r

sarampo_am |>
  filter(!is.na(value)) |>
  summarise(
    primeiro_periodo = min(period),
    ultimo_periodo = max(period),
    maior_valor = max(value)
  )
```
