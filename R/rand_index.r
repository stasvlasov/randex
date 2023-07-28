##' Computes Rand index. 
##' @param a particion 1 as vector
##' @param b partition 2 as vector
##' @return Rand index that ranges from 0 to 1 
##' 
##' @export 
rand_index <- function(a, b) {
    stopifnot(length(a) == length(b))
    n_pairs <- choose(length(a), 2)
    message("    rand_index -- factoring")
    a <- factor(a, exclude = NULL) |> as.numeric()
    b <- factor(b, exclude = NULL) |> as.numeric()
    message("    rand_index -- tabbing")
    dt <- data.table::data.table(a = a, b = b)[
                        , n_a := .N, by = a
                      ][
                        , n_b := .N, by = b
                      ][
                        , n_a_b := .N, by = .(a, b)
                      ]
    ## sum pairs between 'agreement' intersect clusters and 'disagreement'
    message("    rand_index -- combn A")
    a_comb <-
        unique(
            dt[n_a > 1 ,.(a, b, n_a, n_a_b)]
        )[
          , .(comb = (n_a - n_a_b) * n_a_b), by = a
        ] |>
        _$comb |>
        sum(na.rm = TRUE)
    message("    rand_index -- combn B")
    b_comb <-
        unique(
            dt[n_b > 1 ,.(a, b, n_b, n_a_b)]
        )[
          , .(comb = (n_b - n_a_b) * n_a_b), by = b
        ] |>
        _$comb |>
        sum(na.rm = TRUE)
    ## in formula 'c + d as the number of disagreements'
    n_disagreements <- (a_comb + b_comb) / 2  # was conting pairs twice
    return(1 - (n_disagreements / n_pairs))
}
