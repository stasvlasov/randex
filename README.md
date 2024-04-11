[![R-CMD-check](https://github.com/stasvlasov/randex/workflows/R-CMD-check/badge.svg)](https://github.com/stasvlasov/randex/actions)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/stasvlasov/randex)

# About

Calculates the [Rand Index](https://en.wikipedia.org/wiki/Rand_index).
The algorithm for Rand Index estimation specifically meant for large
datasets with many small clusters in which case it is the fastest and
most memory efficient in comparison to procedures from other available
packages (see benchmarking below).

R packages that provide some function/method for calculating Rand index.

| package                                                       | repo                                                  | call                                                                          | version    | comment                           |
|---------------------------------------------------------------|-------------------------------------------------------|-------------------------------------------------------------------------------|------------|-----------------------------------|
| [randex](https://stasvlasov.github.io/randex/)                | [git](https://github.com/stasvlasov/randex)           | randex::rand<sub>index</sub>(a, b)                                            | 0.0.0.9000 | It is this package                |
| [clusteval](https://github.com/ramhiser/clusteval)            | [git](https://github.com/ramhiser/clusteval)          | clusteval::rand(a, b)                                                         | 0.2.1      |                                   |
| [matchFeat](https://github.com/ddegras/matchFeat)             | [cran](https://CRAN.R-project.org/package=matchFeat)  | matchFeat::Rand.index(a, b)                                                   | 1.0        |                                   |
| [fossil](https://matthewvavrek.com/programs-and-code/fossil/) | [cran](https://cran.r-project.org/package=fossil)     | fossil::rand.index(a, b)                                                      | 0.4.0      |                                   |
| [ClustOfVar](https://cran.r-project.org/package=ClustOfVar)   | [cran](https://cran.r-project.org/package=ClustOfVar) | ClustOfVar::rand(a, b, adj = FALSE)                                           | 1.1        |                                   |
| [hecmulti](https://lbelzile.github.io/hecmulti/)              | [git](https://github.com/lbelzile/hecmulti)           | hecmulti::rand(a, b)                                                          | 2023.11.19 | Docs are in French:) Beautiful.   |
| [RFclust.SGE](https://github.com/stela2502/RFclust.SGE)       |                                                       | getMethod(f = RFclust.SGE:::Rand, signature = 'RFclust.SGE')(data.frame(a,b)) | 0.0.0.9000 | Could not get it to work. Broken? |

## Rand index estimation

Rand index measures similarity between two particitionings $X$ and $Y$
(a.k.a., clusterings) of a set of $n$ elements $S$. It can also be seen
as a probability of a random pair of elements from $S$ to be either in a
same subset/cluster in both partitions or to be in different
subsets/clusters in both partitions. It calculates as following:

``` math
Rand Index = \frac {TP + TN} {TP + FP + FN + TN} = 2 \times \frac {TP + TN} {n \times (n-1)}
```

, where:

- $TP$ is the number of **true positives**, i.e., a number of pairs of
  elements in $S$ that are in the **same** subset for both partitionins
  $X$ and $Y$
- $TN$ is the number of **true negatives**, i.e., a number of pairs of
  elements in $S$ that are in **different** subsets for both
  partitionins $X$ and
- $FP$ is the number of false positives, i.e., a number of pairs of
  elements in $S$ that are in **same** subset in $X$ (assuming that $X$
  represents ground thuth parititioning) and are in **different**
  subsets in $Y$
- $FN$ is the number of false negatives, i.e., a number of pairs of
  elements in $S$ that are in **different** subsets in $X$ and are in
  **same** subset in $Y$

The calculation of Rand Index implemented in `randex` package is
slightly different from the straighforward calculation that follows the
the above defitions. Since it is easear to compute disagreements between
paritioning (i.e., $FP$ and $FN$) rather than agreements ($TP$ + $TN$)
we can calculate it as
$Rand Index = 1 - 2 \times \frac {FP + FN} {n \times (n-1)}$.

## References

ClustOfVar- [ClustOfVar: An R Package for the Clustering of Variables \|
Journal of Statistical
Software](https://www.jstatsoft.org/article/view/v050i13)

matchFeat - Degras (2021). Scalable Feature Matching Across Large Data
Collections. <https://arxiv.org/abs/2101.02035> [Scalable Feature
Matching Across Large Data Collections: Journal of Computational and
Graphical Statistics: Vol 32 , No 1 - Get
Access](https://www.tandfonline.com/doi/full/10.1080/10618600.2022.2074429)
[Local search heuristics for multi-index assignment problems with
decomposable costs: Journal of the Operational Research Society: Vol 55
, No 7 - Get
Access](https://www.tandfonline.com/doi/full/10.1057/palgrave.jors.2601723)

fossil-

``` biblatex
@Article{,
  title = {fossil: palaeoecological and palaeogeographical analysis
    tools},
  author = {Matthew J. Vavrek},
  year = {2011},
  journal = {Palaeontologia Electronica},
  volume = {14},
  pages = {1T},
  number = {1},
  note = {R package version 0.4.0},
}
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

| name                                                                            | version | comment                                           |
|---------------------------------------------------------------------------------|---------|---------------------------------------------------|
| [tinytest](https://github.com/markvanderloo/tinytest/blob/master/pkg/README.md) |         | package development (unit testing)                |
| ggplot2                                                                         |         | for visualizing benchmarks                        |
| patchwork                                                                       |         | for combining plots of memory and time benchmarks |

Suggested packages (`Suggests` field in the `DESCRIPTION` file)

# Benchmark

The source code for benchmarking is below. All packages used in this
benchmark can be fully reproduced with Guix package manager. The module
with the packages definitions is below.

## some results (to sto)

\[2024-02-14 Wed\] \## N \<- 22:25 lentgh 3

Evaluating: matchFeat::Rand.index(a, b) call sample result memory
elapsed (sec) \[1,\] "randex::rand<sub>index</sub>(a, b)" 4194304 NA
1682838448 11.607 \[2,\] "matchFeat::Rand.index(a, b)" 4194304 0.9998718
4334704504 8.563 \$call

## Guix module with R packages for Benchmark

``` scheme

(define-module (my packages r)
  #:use-module (gnu packages)
  #:use-module (gnu packages statistics)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build utils)
  #:use-module (guix build-system r)
  #:use-module (guix build-system trivial)
  #:use-module (guix licenses)
  ;; #:use-module (git)
  ;; #:use-module (guix git)
  #:use-module (guix git-download)
  )


;; guix import cran --recursive ClustOfVar

(define-public r-pcamixdata
  (package
    (name "r-pcamixdata")
    (version "3.1")
    (source
     (origin
       (method url-fetch)
       (uri (cran-uri "PCAmixdata" version))
       (sha256
        (base32 "0flrsnbchwk06dmkg3vqykp9n4pqs265szn1r10navp8ki3rrmvh"))))
    (properties `((upstream-name . "PCAmixdata")))
    (build-system r-build-system)
    (native-inputs (list (specification->package "r-knitr")))
    (home-page "https://cran.r-project.org/package=PCAmixdata")
    (synopsis "Multivariate Analysis of Mixed Data")
    (description
     "This package implements principal component analysis, orthogonal rotation and
multiple factor analysis for a mixture of quantitative and qualitative
variables.")
    (license gpl2+)))

(define-public r-clustofvar
  (package
    (name "r-clustofvar")
    (version "1.1")
    (source
     (origin
       (method url-fetch)
       (uri (cran-uri "ClustOfVar" version))
       (sha256
        (base32 "0grhkab7s58ji4cf7cxh7ahd2dxrj8aqfdf3119b40zxkxbwxcr0"))))
    (properties `((upstream-name . "ClustOfVar")))
    (build-system r-build-system)
    (propagated-inputs (list r-pcamixdata))
    (home-page "https://cran.r-project.org/package=ClustOfVar")
    (synopsis "Clustering of Variables")
    (description
     "Cluster analysis of a set of variables.  Variables can be quantitative,
qualitative or a mixture of both.")
    (license gpl2+)))




;; guix import cran --recursive fossil

(define-public r-shapefiles
  (package
    (name "r-shapefiles")
    (version "0.7.2")
    (source
     (origin
       (method url-fetch)
       (uri (cran-uri "shapefiles" version))
       (sha256
        (base32 "03sdcxbah05x0j6cpygx3ivkzrdlz2c0frxi30cinb05q6a41yjb"))))
    (properties `((upstream-name . "shapefiles")))
    (build-system r-build-system)
    (propagated-inputs (list (specification->package "r-foreign")))
    (home-page "https://cran.r-project.org/package=shapefiles")
    (synopsis "Read and Write ESRI Shapefiles")
    (description
     "This package provides functions to read and write ESRI shapefiles.")
    (license (list gpl2+ gpl3+))))

(define-public r-fossil
  (package
    (name "r-fossil")
    (version "0.4.0")
    (source
     (origin
       (method url-fetch)
       (uri (cran-uri "fossil" version))
       (sha256
        (base32 "1hbls9m8yapnfzpv9s850ixakmnan8min1ynk7dqkbpb2px85h1p"))))
    (properties `((upstream-name . "fossil")))
    (build-system r-build-system)
    (propagated-inputs (list
                        (specification->package "r-maps" )
                        r-shapefiles
                        (specification->package "r-sp" )))
    (home-page "http://matthewvavrek.com/programs-and-code/fossil/")
    (synopsis "Palaeoecological and Palaeogeographical Analysis Tools")
    (description
     "This package provides a set of analytical tools useful in analysing ecological
and geographical data sets, both ancient and modern.  The package includes
functions for estimating species richness (Chao 1 and 2, ACE, ICE, Jacknife),
shared species/beta diversity, species area curves and geographic distances and
areas.")
    (license gpl2+)))

;; guix import cran --style=specification --recursive matchFeat
(define-public r-matchfeat
  (package
   (name "r-matchfeat")
   (version "1.0")
   (source
    (origin
     (method url-fetch)
     (uri (cran-uri "matchFeat" version))
     (sha256
      (base32 "0jh484rr71b7887igfslbg7xbr661l9c34d650xd7ajx4gfpn540"))))
   (properties `((upstream-name . "matchFeat")))
   (build-system r-build-system)
   (propagated-inputs (list (specification->package "r-clue")
                            (specification->package "r-foreach")))
   (home-page "https://cran.r-project.org/package=matchFeat")
   (synopsis "One-to-One Feature Matching")
   (description
    "Statistical methods to match feature vectors between multiple datasets in a
one-to-one fashion.  Given a fixed number of classes/distributions, for each
unit, exactly one vector of each class is observed without label.  The goal is
to label the feature vectors using each label exactly once so to produce the
best match across datasets, e.g. by minimizing the variability within classes.
Statistical solutions based on empirical loss functions and probabilistic
modeling are provided.  The Gurobi software and its R interface package are
required for one of the package functions (match.2x()) and can be obtained at
<https://www.gurobi.com/> (free academic license).  For more details, refer to
Degras (2022) <doi:10.1080/10618600.2022.2074429> \"Scalable feature matching for
large data collections\" and Bandelt, Maas, and Spieksma (2004)
<doi:10.1057/palgrave.jors.2601723> \"Local search heuristics for multi-index
assignment problems with decomposable costs\".")
   (license gpl2)))



;; needed for stela2502/RFclust.SGE

;; stas@air ~/dot/sys/my-guix-channel/my/packages$ guix import cran --style=specification --recursive --archive=git https://github.com/sonejilab/FastWilcoxTest >> r.scm

(define-public r-fastwilcoxtest
  (let ((commit "c9ea65dcc41aa5f3403441899f7e558d2a7cbe7d")
        (revision "1"))
    (package
      (name "r-fastwilcoxtest")
      (version (git-version "0.2.0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/sonejilab/FastWilcoxTest")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "0fpblsarxjazmbya3lr304chhc0fwsj6xp7sa5fhi4ryqqw7zrlm"))))
      (properties `((upstream-name . "FastWilcoxTest")))
      (build-system r-build-system)
      (inputs (list (specification->package "r-gsl")))
      (propagated-inputs (list (specification->package "r-matrix")
                               (specification->package "r-metap")
                               (specification->package "r-rcpp")
                               (specification->package "r-rcppeigen")
                               (specification->package "r-rcppprogress")
                               (specification->package "r-reshape2")))
      (home-page "https://github.com/sonejilab/FastWilcoxTest")
      (synopsis
       "Wilcox Ranked Sum Test Implementation using Rcpp; Tests are Applied to a Sparse Matrix")
      (description
       "Re-implementation the the Seurat::@code{FindMarkers}'( test.use == \"wilcox\" )
function but implementing all calculation steps in c++.  Thereby the function is
more than 10 times faster than the Seurat R implementation.  The c++ code was
extracted from the @code{BioQC} @code{BioConductor} package.  It also contains
other fast c++ functions to interact with sparse matrices.")
      (license gpl3))))



;; stas@air ~/dot/sys/my-guix-channel/my/packages$
;; guix import cran --style=specification --recursive --archive=git https://github.com/stela2502/RFclust.SGE >> r.scm

;; guix import: warning: failed to retrieve package information from https://cran.r-project.org/web/packages/FastWilcoxTest/DESCRIPTION: 404 (Not Found)


(define-public r-rfclust-sge
  (let ((commit "ba586d8f0372f7ceb29b75fd3290931856ef64a8")
        (revision "1"))
    (package
      (name "r-rfclust-sge")
      (version (git-version "0.0.0.9000" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/stela2502/RFclust.SGE")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "0hq2rdyxylm5fhbvjpq2dncpvz2m8zfdn787hxpmj10gvv5xr435"))))
      (properties `((upstream-name . "RFclust.SGE")))
      (build-system r-build-system)
      (propagated-inputs (list (specification->package "r-cluster")
                               ;; FastWilcoxTest
                               r-fastwilcoxtest
                               (specification->package "r-hmisc")
                               (specification->package "r-mass")
                               (specification->package "r-matrix")
                               (specification->package "r-ranger")
                               (specification->package "r-survival")))
      (home-page "https://github.com/stela2502/RFclust.SGE")
      (synopsis "Unsupervised clustering using random forest run on SGE")
      (description
       "This package uses the RF clustering method described at https://
labs.genetics.ucla.edu/horvath/RFclustering/RFclustering.htm.  The function is
broken down into separate parts, that can be run on a SGE to reduce analysis
time.")
      (license expat))))




;; guix import cran --style=specification --recursive --archive=git https://github.com/ramhiser/clusteval >> r.scm

(define-public r-clusteval
  (let ((commit "09eae82610a13122d6bfd46480fc4a76eb3c752a")
        (revision "1"))
    (package
      (name "r-clusteval")
      (version (git-version "0.2.1" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/ramhiser/clusteval")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "1591acinzd4mgp8sg9mn0syn1caaxdy3ys99pnpqa5yb0x423y7p"))))
      (properties `((upstream-name . "clusteval")))
      (build-system r-build-system)
      (propagated-inputs (list (specification->package "r-ggplot2")
                               (specification->package "r-mvtnorm")
                               (specification->package "r-rcpp")))
      (home-page "https://github.com/ramhiser/clusteval")
      (synopsis "Evaluation of Clustering Algorithms")
      (description
       "This package provides a suite of tools to evaluate clustering algorithms,
clusterings, and individual clusters.")
      (license expat))))


;; guix import cran --style=specification --recursive --archive=git https://github.com/lbelzile/hecmulti >> r.scm
(define-public r-hecmulti
  (let ((commit "7488f654ae860a1a139bc05b8c263cf7b7fb4517")
        (revision "1"))
    (package
      (name "r-hecmulti")
      (version (git-version "2023.11.19" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/lbelzile/hecmulti")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "1v3yzfjkhhbd253p158d4rglarbv5fx9skr6ya4drx69bdbdr03v"))))
      (properties `((upstream-name . "hecmulti")))
      (build-system r-build-system)
      (arguments
       (list
        #:modules '((guix build r-build-system)
                    (guix build minify-build-system)
                    (guix build utils)
                    (ice-9 match))
        #:imported-modules `(,@%r-build-system-modules (guix build
                                                             minify-build-system))
        #:phases '(modify-phases %standard-phases
                    (add-after 'unpack 'process-javascript
                      (lambda* (#:key inputs #:allow-other-keys)
                        (with-directory-excursion "inst/"
                          (for-each (match-lambda
                                      ((source . target) (minify source
                                                                 #:target
                                                                 target)))
                                    '())))))))
      (propagated-inputs (list (specification->package "r-ggplot2")
                               (specification->package "r-mass")
                               (specification->package "r-patchwork")))
      (native-inputs (list (specification->package "esbuild")
                           (specification->package "r-knitr")))
      (home-page "https://github.com/lbelzile/hecmulti")
      (synopsis "Matériel de cours pour Analyse multidimensionnelle appliquée")
      (description
       "Jeux de données et fonctions pour le cours Analyse multidimensionnelle appliquée
(MATH 60602) à HEC Montréal.")
      (license cc-by-sa4.0))))
```
