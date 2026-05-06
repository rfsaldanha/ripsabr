# ripsabr

Pacote R para recuperacao de indicadores da RIPSA como tibbles
padronizadas.

Fontes principais:

- Fichas de Qualificacao dos Indicadores:
  <https://www.ripsa.org.br/fichasidb>
- Dados abertos do SUS com bases RIPSA:
  <https://dadosabertos.saude.gov.br/dataset?q=ripsa>

Os dados sao baixados diretamente dos recursos CKAN do Portal de Dados
Abertos do SUS. O pacote nao depende de arquivos locais de indicadores
nem de Zenodo.

## Uso

``` r

library(ripsabr)

list_indicators()

list_categories("MRB.1.01")

sarampo_am <- get_indicator(
  code = "MRB.1.01",
  geo = "state",
  geo_code = 13,
  category = "total"
)
```

[`list_indicators()`](https://rfsaldanha.github.io/ripsabr/reference/list_indicators.md)
inclui a cobertura disponível em cada arquivo de origem:

- `spatial_granularity`
- `time_granularity`
- `time_start`, `time_end`
- `available_categories`, `available_category_names`

[`get_indicator()`](https://rfsaldanha.github.io/ripsabr/reference/get_indicator.md)
retorna uma tibble com colunas consistentes para qualquer nivel
geografico:

- `indicator_code`, `indicator_name`, `theme`, `dimension`
- `period`, `date`
- `geo_level`, `geo_code`, `geo_name`
- `value`, `unit`
- `category_code`, `category`
- `update_date`

Use
[`list_categories()`](https://rfsaldanha.github.io/ripsabr/reference/list_categories.md)
para consultar categorias disponíveis e filtre com `category_id`,
`category_code` ou `category_name`:

``` r

list_categories("COB.4.01")

prenatal <- get_indicator(
  code = "COB.4.01",
  geo_code = 130260,
  category = "nascidos_vivos_com_7_ou_mais_consultas"
)
```

O padrao `category = NULL` mantem todas as categorias existentes no
arquivo de origem.
