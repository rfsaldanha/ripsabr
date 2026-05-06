# ripsabr

O `ripsabr` facilita o acesso aos indicadores da Rede Interagencial de
Informações para a Saúde (RIPSA) no R. O pacote baixa os arquivos publicados no
Portal de Dados Abertos do SUS e retorna os resultados como tibbles
padronizadas, com colunas consistentes para código do indicador, período,
território, valor e categoria.

## Fontes

- Fichas de Qualificação dos Indicadores: <https://www.ripsa.org.br/fichasidb>
- Bases RIPSA no Portal de Dados Abertos do SUS:
  <https://dadosabertos.saude.gov.br/dataset?q=ripsa>

Os dados são baixados diretamente dos recursos CKAN do portal. O pacote não
depende de arquivos locais de indicadores nem de repositórios externos como
Zenodo.

## Instalação

```r
# install.packages("pak")
pak::pak("rfsaldanha/ripsabr")
```

## Uso

Comece listando os indicadores disponíveis:

```r
library(ripsabr)

indicadores <- list_indicators()
indicadores
```

A tabela de indicadores inclui o tema, a dimensão, o nome, a cobertura
geográfica, a cobertura temporal e as categorias disponíveis em cada arquivo de
origem.

Consulte as categorias de um indicador antes de filtrar a chamada:

```r
list_categories("COB.4.01")
```

Baixe um indicador para uma unidade federativa:

```r
sarampo_am <- get_indicator(
  code = "MRB.1.01",
  geo = "state",
  geo_code = 13,
  category = "total"
)

sarampo_am
```

Filtre por município e por categoria:

```r
prenatal_manaus <- get_indicator(
  code = "COB.4.01",
  geo = "municipality",
  geo_code = 130260,
  category = "nascidos_vivos_com_7_ou_mais_consultas"
)
```

Também é possível usar nomes legíveis de categoria quando eles aparecem em
`list_categories()`:

```r
consultas_pediatria_am <- get_indicator(
  code = "COB.1.02",
  geo = "state",
  geo_code = 13,
  category = "Médico pediatra"
)
```

Para indicadores com categorias, o padrão `category = NULL` mantém todas as
categorias presentes no arquivo de origem. Em arquivos municipais grandes, use
`geo_code`, `category` ou `category_id` para reduzir o volume baixado e tratado.

## Resultado

`get_indicator()` retorna uma tibble com as seguintes colunas:

- `indicator_code`, `indicator_name`, `theme`, `dimension`
- `period`, `date`
- `geo_level`, `geo_code`, `geo_name`
- `value`, `unit`
- `category_code`, `category`
- `update_date`

## Exemplos rápidos

Indicador nacional:

```r
pib_br <- get_indicator(
  code = "SOC.3.05",
  geo = "country",
  category = "total"
)
```

Indicador estadual com categoria total:

```r
sarampo_am <- get_indicator(
  code = "MRB.1.01",
  geo = "state",
  geo_code = 13,
  category = "total"
)
```

Indicador municipal com `category_id`:

```r
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
```
