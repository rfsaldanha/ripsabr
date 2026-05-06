# Baixe um indicador RIPSA

`get_indicator()` baixa o indicador identificado por `code` e retorna
uma série temporal padronizada para o nível geográfico solicitado.

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

  Escalar de texto. Código RIPSA do indicador, por exemplo `"MRB.1.01"`.

- geo:

  Escalar de texto. Nível geográfico a retornar. Um de `"municipality"`,
  `"state"`, `"region"`, `"health_region"`, `"macro_region"` ou
  `"country"`.

- geo_code:

  Vetor opcional de códigos geográficos a manter. Os códigos são
  comparados como texto.

- category:

  Vetor opcional de códigos ou nomes de categorias a manter. Use
  `"total"` para linhas de total/todas as categorias quando elas
  existirem no arquivo de origem. Também é possível passar um nome
  retornado por
  [`list_categories()`](https://rfsaldanha.github.io/ripsabr/reference/list_categories.md),
  como `"Nascidos vivos com 7 ou mais consultas"`. O padrão é `NULL`,
  mantendo todas as categorias presentes no arquivo de origem.

- category_id:

  Vetor opcional de identificadores de categoria retornados por
  [`list_categories()`](https://rfsaldanha.github.io/ripsabr/reference/list_categories.md).

## Value

Uma tibble com colunas padronizadas: `indicator_code`, `indicator_name`,
`theme`, `dimension`, `period`, `date`, `geo_level`, `geo_code`,
`geo_name`, `value`, `unit`, `category_code`, `category` e
`update_date`. Em arquivos legados da RIPSA com mais de um numerador,
`category_code` e `category` identificam o numerador usado para calcular
cada valor.

## Details

A forma mais simples de escolher categorias é chamar
`list_categories(code)` e usar `category_id`, `category_code` ou
`category_name`.

Em arquivos com colunas de categoria da RIPSA, `category` pode receber
um `category_code` completo retornado por esta função, como `"TC:0"`, ou
um prefixo de categoria, como `"TC"`. Ao passar um prefixo, todos os
itens daquela categoria são mantidos.

Os prefixos de categoria atualmente encontrados nos arquivos CKAN da
RIPSA são: `"API"`, `"COR"`, `"cor_raca"`, `"EA"`, `"ESP"`, `"ETI"`,
`"EV"`, `"FE"`, `"FER"`, `"fx_etaria"`, `"fx_rdpc"`, `"FXETC1"`,
`"FXETC2"`, `"GC"`, `"GIF"`, `"Idade"`, `"IG"`, `"PESSOA1"`, `"sap"`,
`"SD"`, `"sexo"`, `"SFE"`, `"SG"`, `"sitdom"`, `"SVA"`, `"TC"`, `"TD"`,
`"tipoarea"`, e `"TPC"`.

Em arquivos legados com numerador e denominador, a fonte não expõe um
vocabulário fixo de categorias. Nesses arquivos, `category_code` é
gerado com [`make.names()`](https://rdrr.io/r/base/make.names.html) a
partir do rótulo de cada coluna de numerador, após remover o prefixo
`"Numerador - "`. Use `category = NULL` uma vez para inspecionar os
valores de `category_code` disponíveis para um indicador específico.
