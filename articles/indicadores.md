# Tabela de indicadores

Esta página expõe a tabela de indicadores incluída no pacote. Ela é a
mesma base retornada por
[`list_indicators()`](https://rfsaldanha.github.io/ripsabr/reference/list_indicators.md)
e usada internamente por
[`get_indicator()`](https://rfsaldanha.github.io/ripsabr/reference/get_indicator.md).

``` r

library(ripsabr)
```

``` r

indicadores <- list_indicators()

knitr::kable(
  indicadores[
    c(
      "id",
      "theme",
      "dimension",
      "name",
      "spatial_granularity",
      "time_granularity",
      "time_start",
      "time_end"
    )
  ],
  caption = "Indicadores RIPSA disponíveis no ripsabr"
)
```

| id | theme | dimension | name | spatial_granularity | time_granularity | time_start | time_end |
|:---|:---|:---|:---|:---|:---|:---|:---|
| COB.1.01 | Cobertura | Dimensão 1 | Razão de consultas médicas (SUS) na APS por 100 habitantes | municipality, state, region, health_region, macro_region, country | annual | 2018-12-01 | 2024-12-01 |
| COB.1.02 | Cobertura | Dimensão 1 | Razão de consultas médicas (SUS) na Atenção Especializada em Saúde por 100 habitantes | municipality, state, region, health_region, macro_region, country | annual | 2012-12-01 | 2024-12-01 |
| COB.1.03 | Cobertura | Dimensão 1 | Razão de consultas médicas (saúde suplementar) por beneficiários de planos privados de saúde | country | annual | 2015-01-01 | 2024-01-01 |
| COB.2.01 | Cobertura | Dimensão 2 | Taxa de internações hospitalares (SUS) por 100 habitantes | municipality | annual | 2000-01-01 | 2024-01-01 |
| COB.2.02 | Cobertura | Dimensão 2 | Taxa de internações hospitalares em planos privados de saúde | municipality | annual | 2015-01-01 | 2024-01-01 |
| COB.4.01 | Cobertura | Dimensão 4 | Proporção de nascidos vivos segundo o número de consultas de pré-natal | municipality | annual | 2000-01-01 | 2024-01-01 |
| COB.4.02 | Cobertura | Dimensão 4 | Proporção de partos hospitalares | municipality | annual | 2000-01-01 | 2024-01-01 |
| COB.4.03 | Cobertura | Dimensão 4 | Proporção de partos cesáreos | municipality | annual | 2000-01-01 | 2024-01-01 |
| COB.5.01 | Cobertura | Dimensão 5 | Proporção da população coberta por planos privados de assistência à saúde | municipality, state, region, health_region, macro_region, country | annual | 2012-12-01 | 2024-12-01 |
| DEM.1.01 | Demográfico | Dimensão 1 | População residente | municipality, state, region, health_region, macro_region, country | annual | 2012-12-01 | 2024-12-01 |
| DEM.1.02 | Demográfico | Dimensão 1 | Razão de sexo | municipality | annual | 2000-01-01 | 2024-01-01 |
| DEM.1.03 | Demográfico | Dimensão 1 | Taxa de crescimento anual da população | municipality, state, region, health_region, macro_region, country | annual | 2010-12-01 | 2024-12-01 |
| DEM.1.04 | Demográfico | Dimensão 1 | Proporção de menores de 5 anos de idade na população | municipality, state, region, health_region, macro_region, country | annual | 2000-12-01 | 2024-12-01 |
| DEM.1.05 | Demográfico | Dimensão 1 | Proporção de pessoas idosas na população | municipality, state, region, health_region, macro_region, country | annual | 2000-12-01 | 2024-12-01 |
| DEM.1.06 | Demográfico | Dimensão 1 | Índice de envelhecimento | municipality, state, region, health_region, macro_region, country | annual | 2000-12-01 | 2024-12-01 |
| DEM.1.07 | Demográfico | Dimensão 1 | Razão de dependência | municipality, state, region, health_region, macro_region, country | annual | 2000-12-01 | 2024-12-01 |
| DEM.2.01 | Demográfico | Dimensão 2 | Taxas específicas de fecundidade | municipality, state, region, health_region, macro_region, country | annual | 2000-12-01 | 2070-12-01 |
| DEM.2.02 | Demográfico | Dimensão 2 | Taxa de fecundidade total | municipality, state, region, health_region, macro_region, country | annual | 2000-12-01 | 2070-12-01 |
| DEM.2.03 | Demográfico | Dimensão 2 | Taxa bruta de natalidade | municipality, state, region, health_region, macro_region, country | annual | 2000-12-01 | 2070-12-01 |
| DEM.3.01 | Demográfico | Dimensão 3 | Taxas específicas de mortalidade por idade e sexo | municipality, state, region, health_region, macro_region, country | annual | 2000-12-01 | 2070-12-01 |
| DEM.3.02 | Demográfico | Dimensão 3 | Taxa bruta de mortalidade | municipality, state, region, health_region, macro_region, country | annual | 2000-12-01 | 2070-12-01 |
| DEM.3.04 | Demográfico | Dimensão 3 | Esperança de vida ao nascer | municipality, state, region, health_region, macro_region, country | annual | 2000-12-01 | 2070-12-01 |
| DEM.3.05 | Demográfico | Dimensão 3 | Esperança de vida aos 60 anos de idade | municipality, state, region, health_region, macro_region, country | annual | 2000-12-01 | 2070-12-01 |
| DEM.4.01 | Demográfico | Dimensão 4 | Cobertura do Sistema de Informações sobre Nascidos Vivos (Sinasc) | state | annual | 2000-01-01 | 2023-01-01 |
| DEM.4.02 | Demográfico | Dimensão 4 | Cobertura do Sistema de Informação sobre Mortalidade (SIM) | state | annual | 2000-01-01 | 2023-01-01 |
| FRP.7.01 | Fatores de risco e proteção | Dimensão 7 | Proporção de nascidos vivos por idade da parturiente | municipality | annual | 2000-01-01 | 2024-01-01 |
| FRP.7.02 | Fatores de risco e proteção | Dimensão 7 | Proporção de nascidos vivos com baixo peso ao nascer por idade gestacional no momento do parto | municipality | annual | 2000-01-01 | 2024-01-01 |
| FRP.7.03 | Fatores de risco e proteção | Dimensão 7 | Prevalência de nascidos vivos com anomalias congênitas | municipality | annual | 2000-01-01 | 2024-01-01 |
| MRB.1.01 | Morbidade | Dimensão 1 | Incidência de sarampo | municipality, state, region, health_region, macro_region, country | annual | 2012-12-01 | 2024-12-01 |
| MRB.1.02 | Morbidade | Dimensão 1 | Incidência de rubéola | municipality, state, region, health_region, macro_region, country | annual | 2012-12-01 | 2024-12-01 |
| MRB.1.04 | Morbidade | Dimensão 1 | Incidência de difteria | municipality, state, region, health_region, macro_region, country | annual | 2012-12-01 | 2024-12-01 |
| MRB.1.06 | Morbidade | Dimensão 1 | Incidência de tétano neonatal | municipality, state, region, health_region, macro_region, country | annual | 2014-04-01 | 2025-11-01 |
| MRB.1.07 | Morbidade | Dimensão 1 | Incidência de tétano acidental | municipality, state, region, health_region, macro_region, country | annual | 2012-12-01 | 2025-12-01 |
| MRB.1.09 | Morbidade | Dimensão 1 | Incidência de raiva humana | municipality, state, region, health_region, macro_region, country | annual | 2012-12-01 | 2025-12-01 |
| MRB.1.10 | Morbidade | Dimensão 1 | Incidência de cólera | municipality, state, region, health_region, macro_region, country | annual | 2016-12-01 | 2024-12-01 |
| MRB.1.11 | Morbidade | Dimensão 1 | Incidência de síndrome congênita associada à infecção pelo vírus Zika | municipality, state, region, health_region, macro_region, country | annual | 2015-12-01 | 2025-12-01 |
| MRB.1.13 | Morbidade | Dimensão 1 | Incidência de doença meningocócica | municipality, state, region, health_region, macro_region, country | annual | 2012-12-01 | 2025-12-01 |
| MRB.1.14 | Morbidade | Dimensão 1 | Incidência de meningite não meningocócica | municipality, state, region, health_region, macro_region, country | annual | 2012-12-01 | 2025-12-01 |
| MRB.1.15 | Morbidade | Dimensão 1 | Incidência de leptospirose | municipality, state, region, health_region, macro_region, country | annual | 2012-12-01 | 2024-12-01 |
| MRB.1.16 | Morbidade | Dimensão 1 | Incidência de febre maculosa | municipality, state, region, health_region, macro_region, country | annual | 2014-12-01 | 2024-12-01 |
| MRB.1.17 | Morbidade | Dimensão 1 | Incidência de esquistossomose mansoni não grave | municipality, state, region, health_region, macro_region, country | annual | 2012-12-01 | 2023-12-01 |
| MRB.1.18 | Morbidade | Dimensão 1 | Incidência de doença de Chagas aguda | municipality, state, region, health_region, macro_region, country | annual | 2012-12-01 | 2024-12-01 |
| MRB.2.03 | Morbidade | Dimensão 2 | Taxa de Incidência de hepatite B | municipality, state, region, health_region, macro_region, country | annual | 2012-12-01 | 2024-12-01 |
| MRB.2.04 | Morbidade | Dimensão 2 | Taxa de incidência de hepatite C | municipality, state, region, health_region, macro_region, country | annual | 2012-12-01 | 2024-12-01 |
| MRB.2.05 | Morbidade | Dimensão 2 | Taxa de incidência de tuberculose | municipality, state, region, health_region, macro_region, country | annual | 2012-12-01 | 2024-12-01 |
| MRB.2.06 | Morbidade | Dimensão 2 | Taxa de incidência de hanseníase | municipality, state, region, health_region, macro_region, country | annual | 2012-12-01 | 2024-12-01 |
| MRB.2.07 | Morbidade | Dimensão 2 | Taxa de incidência de hanseníase na população menor de 15 anos | municipality, state, region, health_region, macro_region, country | annual | 2012-12-01 | 2024-12-01 |
| MRB.2.09 | Morbidade | Dimensão 2 | Taxa de incidência de leishmaniose visceral | municipality, state, region, health_region, macro_region, country | annual | 2012-12-01 | 2024-12-01 |
| MRB.2.10 | Morbidade | Dimensão 2 | Taxa de incidência de toxoplasmose adquirida durante a gestação | municipality, state, region, health_region, macro_region, country | annual | 2019-12-01 | 2024-12-01 |
| MRB.2.13 | Morbidade | Dimensão 2 | Taxa de incidência de dengue | municipality, state, region, health_region, macro_region, country | annual | 2012-12-01 | 2024-12-01 |
| MRB.2.14 | Morbidade | Dimensão 2 | Taxa de incidência de dengue grave | municipality, state, region, health_region, macro_region, country | annual | 2012-12-01 | 2024-12-01 |
| MRB.2.15 | Morbidade | Dimensão 2 | Taxa de incidência de chikungunya | municipality, state, region, health_region, macro_region, country | annual | 2015-12-01 | 2024-12-01 |
| MRB.4.01 | Morbidade | Dimensão 4 | Taxa de internação hospitalar (SUS) por causas externas | municipality | annual | 2000-01-01 | 2024-01-01 |
| MRB.4.02 | Morbidade | Dimensão 4 | Taxa de internação hospitalar (SUS) por condições sensíveis à atenção primária | municipality | annual | 2000-01-01 | 2024-01-01 |
| MRT.1.01 | Mortalidade | Dimensão 1 | Taxa de mortalidade infantil | state | annual | 2000-01-01 | 2023-01-01 |
| MRT.1.02 | Mortalidade | Dimensão 1 | Taxa de mortalidade neonatal precoce | state | annual | 2000-01-01 | 2023-01-01 |
| MRT.1.03 | Mortalidade | Dimensão 1 | Taxa de mortalidade neonatal tardia | state | annual | 2000-01-01 | 2023-01-01 |
| MRT.1.04 | Mortalidade | Dimensão 1 | Taxa de mortalidade pós-neonatal | state | annual | 2000-01-01 | 2023-01-01 |
| MRT.1.05 | Mortalidade | Dimensão 1 | Taxa de mortalidade em menores de 5 anos | state | annual | 2000-01-01 | 2024-01-01 |
| MRT.2.01 | Mortalidade | Dimensão 2 | Razão de mortalidade materna | state | annual | 2009-01-01 | 2023-01-01 |
| MRT.2.02 | Mortalidade | Dimensão 2 | Mortalidade materna segundo grupos de causas | municipality | annual | 2000-01-01 | 2024-01-01 |
| MRT.3.01 | Mortalidade | Dimensão 3 | Mortalidade proporcional por causas | state | annual | 2000-01-01 | 2024-01-01 |
| MRT.3.02 | Mortalidade | Dimensão 3 | Proporção de óbitos por causas mal definidas | state | annual | 2000-01-01 | 2024-01-01 |
| MRT.4.01 | Mortalidade | Dimensão 4 | Taxa de mortalidade por agressão | state | annual | 2000-01-01 | 2024-01-01 |
| MRT.4.02 | Mortalidade | Dimensão 4 | Taxa de mortalidade por lesão autoprovocada | state | annual | 2000-01-01 | 2024-01-01 |
| MRT.4.03 | Mortalidade | Dimensão 4 | Taxa de mortalidade por lesão de trânsito | state | annual | 2000-01-01 | 2024-01-01 |
| MRT.4.04 | Mortalidade | Dimensão 4 | Taxa de mortalidade por causas acidentais | state | annual | 2000-01-01 | 2024-01-01 |
| MRT.5.01 | Mortalidade | Dimensão 5 | Taxa de mortalidade prematura por DCNT | municipality, state, region, health_region, macro_region, country | annual | 2012-12-01 | 2024-12-01 |
| MRT.5.02 | Mortalidade | Dimensão 5 | Taxa de mortalidade por neoplasias malignas | municipality, state, region, health_region, macro_region, country | annual | 2012-12-01 | 2023-12-01 |
| MRT.5.03 | Mortalidade | Dimensão 5 | Taxa de mortalidade por diabetes mellitus | municipality, state, region, health_region, macro_region, country | annual | 2012-12-01 | 2024-12-01 |
| MRT.5.04 | Mortalidade | Dimensão 5 | Taxa de mortalidade por doenças cardiovasculares | municipality, state, region, health_region, macro_region, country | annual | 2012-12-01 | 2023-12-01 |
| MRT.5.05 | Mortalidade | Dimensão 5 | Taxa de mortalidade por doenças respiratórias crônicas | municipality, state, region, health_region, macro_region, country | annual | 2012-12-01 | 2023-12-01 |
| MRT.5.06 | Mortalidade | Dimensão 5 | Probabilidade de morte prematura por DCNT prioritárias | state | annual | 2000-01-01 | 2024-01-01 |
| MRT.6.01 | Mortalidade | Dimensão 6 | Taxa de mortalidade específica por doenças infecciosas e parasitárias | state | annual | 2000-01-01 | 2024-01-01 |
| REC.1.01 | Recursos | Dimensão 1 | Trabalhadores da saúde por população | municipality | annual | 2008-01-01 | 2024-01-01 |
| REC.2.01 | Recursos | Dimensão 2 | Leitos hospitalares por população | municipality | annual | 2006-01-01 | 2024-01-01 |
| REC.2.03 | Recursos | Dimensão 2 | Equipamentos de imagem por população | municipality | annual | 2007-01-01 | 2023-01-01 |
| REC.3.01 | Recursos | Dimensão 3 | Valor médio de referência por atendimento ambulatorial no Sistema Único de Saúde | municipality | annual | 2008-01-01 | 2025-01-01 |
| REC.3.02 | Recursos | Dimensão 3 | Valor médio de referência por autorização de internação hospitalar | municipality | annual | 2000-01-01 | 2024-01-01 |
| REC.3.03 | Recursos | Dimensão 3 | Gasto em ações e serviços públicos de saúde como percentual do produto interno bruto | municipality | annual | 2002-01-01 | 2023-01-01 |
| REC.3.04 | Recursos | Dimensão 3 | Gasto em ações e serviços públicos de saúde per capita | municipality | annual | 2000-01-01 | 2024-01-01 |
| REC.4.01 | Recursos | Dimensão 4 | Despesa com saúde autorreferida como proporção da renda familiar | country | annual | 2008-01-01 | 2018-01-01 |
| REC.4.02 | Recursos | Dimensão 4 | Despesa com saúde estimada como proporção da renda familiar | country | annual | 2010-01-01 | 2021-01-01 |
| REC.4.03 | Recursos | Dimensão 4 | Gasto nacional com saúde como percentual do produto interno bruto | country | annual | 2010-01-01 | 2021-01-01 |
| REC.4.04 | Recursos | Dimensão 4 | Gasto nacional per capita com saúde | country | annual | 2010-01-01 | 2021-01-01 |
| REC.4.05 | Recursos | Dimensão 4 | Gasto federal com saúde como percentual do produto interno bruto | municipality, state, region, health_region, macro_region, country | annual | 2009-12-01 | 2023-12-01 |
| REC.4.06 | Recursos | Dimensão 4 | Gasto federal com saúde como percentual do gasto federal total | municipality, state, region, health_region, macro_region, country | annual | 2009-12-01 | 2023-12-01 |
| REC.5.01 | Recursos | Dimensão 5 | Gasto público com saneamento básico como percentual do produto interno bruto | country | annual | 2013-01-01 | 2023-01-01 |
| REC.5.02 | Recursos | Dimensão 5 | Gasto federal com saneamento básico como percentual do produto interno bruto | municipality, state, region, health_region, macro_region, country | annual | 2013-12-01 | 2023-12-01 |
| REC.5.03 | Recursos | Dimensão 5 | Gasto federal com saneamento básico como percentual do gasto federal total | municipality, state, region, health_region, macro_region, country | annual | 2013-12-01 | 2023-12-01 |
| REC.6.01 | Recursos | Dimensão 6 | Proporção das importações de bens e serviços de saúde na oferta nacional | country | annual | 2010-01-01 | 2021-01-01 |
| SOC.1.01 | Socioeconômico | Dimensão 1 | Proporção de analfabetismo na população | state, region, country | annual | 2012-12-01 | 2024-12-01 |
| SOC.1.02 | Socioeconômico | Dimensão 1 | Proporção da população sem educação básica | state, region, country | annual | 2012-12-01 | 2024-12-01 |
| SOC.2.01 | Socioeconômico | Dimensão 2 | Proporção de desocupação na população | state, region, country | annual | 2012-12-01 | 2024-12-01 |
| SOC.2.02 | Socioeconômico | Dimensão 2 | Proporção da população com força de trabalho subutilizada | state, region, country | annual | 2012-12-01 | 2024-12-01 |
| SOC.2.03 | Socioeconômico | Dimensão 2 | Proporção da população ocupada sem contribuição para a previdência social | state, region, country | annual | 2012-12-01 | 2024-12-01 |
| SOC.2.04 | Socioeconômico | Dimensão 2 | Proporção de jovens que não estudam e não trabalham | state, region, country | annual | 2016-12-01 | 2024-12-01 |
| SOC.2.05 | Socioeconômico | Dimensão 2 | Proporção da população de 5 a 17 anos de idade em situação de trabalho infantil | state, region, country | annual | 2016-12-01 | 2024-12-01 |
| SOC.3.01 | Socioeconômico | Dimensão 3 | Rendimento domiciliar per capita a preços correntes | state, region, country | annual | 2012-12-01 | 2024-12-01 |
| SOC.3.02 | Socioeconômico | Dimensão 3 | Proporção da população abaixo da linha de pobreza | state, region, country | annual | 2012-12-01 | 2024-12-01 |
| SOC.3.03 | Socioeconômico | Dimensão 3 | Coeficiente de Gini da distribuição da renda domiciliar per capita | state, region, country | annual | 2012-12-01 | 2024-12-01 |
| SOC.3.04 | Socioeconômico | Dimensão 3 | Razão entre a renda total dos 10% mais ricos e a dos 40% mais pobres | state, region, country | annual | 2012-12-01 | 2024-12-01 |
| SOC.3.05 | Socioeconômico | Dimensão 3 | Produto interno bruto per capita | state, region, country | annual | 2010-12-01 | 2022-12-01 |
| SOC.4.01 | Socioeconômico | Dimensão 4 | Proporção da população urbana sem acesso seguro à água | state, region, country | annual | 2016-12-01 | 2024-12-01 |
| SOC.4.02 | Socioeconômico | Dimensão 4 | Proporção da população urbana sem instalações sanitárias adequadas | state, region, country | annual | 2016-12-01 | 2024-12-01 |
| SOC.4.03 | Socioeconômico | Dimensão 4 | Proporção da população sem coleta direta ou indireta de lixo | state, region, country | annual | 2016-12-01 | 2024-12-01 |
| SOC.5.01 | Socioeconômico | Dimensão 5 | Proporção da população em situação de insegurança alimentar moderada ou grave | state, region, country | annual | 2023-12-01 | 2023-12-01 |

Indicadores RIPSA disponíveis no ripsabr {.table}

Para ver as categorias disponíveis em cada indicador, use:

``` r

list_categories("COB.4.01")
```
