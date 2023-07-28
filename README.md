[![R-CMD-check](https://github.com/stasvlasov/randex/workflows/R-CMD-check/badge.svg)](https://github.com/stasvlasov/randex/actions)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/stasvlasov/randex)

# Description

Calculates the [Rand Index](https://en.wikipedia.org/wiki/Rand_index).
Specifically tuned for large datasets with many small clusters.

# Benchmarking

``` r
a <-
    lapply(1:10^4, \(i) {
        set.seed(111 + i)
        sample(letters, 3)
    }) |>
    sapply(paste, collapse = "") |>
    as.factor() |>
    as.numeric()


b <-
    lapply(1:10^4, \(i) {
        set.seed(222 + i)
        sample(letters, 3)
    }) |>
    sapply(paste, collapse = "") |>
    as.factor() |>
    as.numeric()

c('randex::rand_index'
, 'matchFeat::Rand.index'
, 'fossil::rand.index'
  ## , 'ClustOfVar::rand'
  ## , 'stela2502/RFclust.SGE::Rand'
  ## , 'ramhiser/clusteval::rand'
  ## , 'lbelzile/hecmulti::rand'
  ) |> lapply(
           \(func) {
               ## ns <- sub("::.*$", "", func)
               ## func <- sub("^.*::", "", func)
               Rprof(memory.profiling = TRUE)
               ## val <- do.call(getFromNamespace(func, ns), list(a, b))
               val <- eval(str2expression(paste0(func, "(a, b)")))
               Rprof(NULL)
               prof <- summaryRprof(memory = "both")
               prof_mem <- prof$by.self[paste0('"', func, '"'), "mem.total"][[1]]
               prof_time <- prof$by.total[paste0('"', func, '"'), "total.time"]
               list(func = func
                  , val = val
                  , mem = paste(prof_mem, 'Mb')
                  , time = paste(prof_time, 's'))
           }) |>
    do.call(rbind, args = _)


##      func                    val       mem         time    
## [1,] "rand_index"            0.9998728 "3 Mb"     "0.36 s"
## [2,] "matchFeat::Rand.index" 0.9998728 "840 Mb"    "0.96 s"
## [3,] "fossil::rand.index"    0.9998728 "7393.2 Mb" "4.62 s"
```

# Installation

``` r
devtools::install_github("stasvlasov/randex")
```

# Dependencies

| name                            | version | comment                                   |
|---------------------------------|---------|-------------------------------------------|
| [R](https://www.r-project.org/) | 4.2.0   | minimum R version to enable native piping |

Hard dependencies (`Depends` field in `DESCRIPTION` file)

| name                                                   | version | comment                                                   |
|--------------------------------------------------------|---------|-----------------------------------------------------------|
| [data.table](https://rdatatable.gitlab.io/data.table/) |         | fast data.frames, used as main input and output data type |

Required packages (`Imports` field in the `DESCRIPTION` file)
