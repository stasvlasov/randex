##' Computes Rand index
##'
##' Should be relatively fast and memory efficient. See `rand_index_benchmark`
##' 
##' @param a particion 1 as vector
##' @param b partition 2 as vector
##' @param verbose Whether to print logs messages
##' @return Rand index that ranges from 0 to 1 
##' @import data.table
##' @export 
rand_index <- function(a, b, verbose = FALSE) {
    ## Some basic checks
    stopifnot(
        "rand_index: a and b should be the same length" =
            length(a) == length(b)
      , "rand_index: a should be a vector of either strings or numbers" =
            class(a) %in% c("numeric", "integer", "character"))
    if(verbose) message("    rand_index -- factoring A and B (on common levels)")
    factor_levels <- unique(c(a,b))
    a <- factor(a, exclude = NULL, labels = factor_levels) |> as.numeric()
    b <- factor(b, exclude = NULL, labels = factor_levels) |> as.numeric()
    if(verbose) message("    rand_index -- tabulating A and B clusters")
    dt <-
        data.table(a = a, b = b)[
          , n_a := .N, by = a
        ][
          , n_b := .N, by = b
        ][
          , n_a_b := .N, by = .(a, b)
        ]
    ## sum pairs between 'agreement' intersect clusters and 'disagreement'
    if(verbose) message("    rand_index -- combn A")
    a_comb <-
        unique(dt[n_a > 1, .(a, b, n_a, n_a_b)])[
          , .(comb = (n_a - n_a_b) * n_a_b), by = a
        ] |> _$comb |>
        as.numeric() |>
        sum(na.rm = TRUE)
    if(verbose) message("    rand_index -- combn B")
    b_comb <-
        unique(dt[n_b > 1, .(a, b, n_b, n_a_b)])[
          , .(comb = (n_b - n_a_b) * n_a_b), by = b
        ] |> _$comb |>
        as.numeric() |>
        sum(na.rm = TRUE)
    if(verbose) message("    rand_index -- calcutating Rand")
    ## in formula 'c + d as the number of disagreements'
    n_disagreements <- (a_comb + b_comb) / 2  # correction for conting pairs twice
    n_pairs <- choose(length(a), 2)
    return(1 - (n_disagreements / n_pairs))
}

##' Benchmark time and memory performance of various calculations of Rand index
##' 
##' @param return_plot Type of plot to return
##' @param calls Benchmark calls that calculate Rand index for set 'a' and 'b', e.g., 'randex::rand_index(a, b)'
##' @param N Integer vector of sizes for clustered sets. Sizes should be in increasing order.
##' @param string_space Character space for cluster names (all ascii letters by default)
##' @param string_length Length of clusted names. Kind of a proxy for number of possible clusters.
##' @param mem_max Stop benchmarking if last result took more than specified number of bites of RAM (30Gb default)
##' @param time_max Stop benchmarking if last result took longer than specified number of seconds (5 minutes default)
##' @param return_data Do not visualize results. Just return benchmarks data for saving.
##' @param rds_file Use this as data for visualizing previously calculated benchmarks obtained from `randex_benchmark(..., return_data = TRUE)`
##' @param profmem_type Type of memory profiling. "allocation" type uses `utils::Rprofmem()` (for which R should be compiled with '--enable-memory-profiling' option). "snapshot" memory profiling type uses `utils::Rprof(prof, memory.profiling = TRUE)`. See more details here - https://cran.r-project.org/web/packages/profmem/vignettes/profmem.html
##' @param highlight_call Call from `call` to be highlighted
##' 
##' @return Plot or data
##' 
##' @export 
rand_index_benchmark <- function(return_plot = c("combined", "memory", "time")[1]
                               , calls =
                                     c("randex::rand_index(a, b)", "clusteval::rand(a, b)", "matchFeat::Rand.index(a, b)", 
                                     "fossil::rand.index(a, b)", "ClustOfVar::rand(a, b, adj =  FALSE)", 
                                     "hecmulti::rand(a, b)")
                               , N = 2^(10:25)
                               , string_space = letters
                               , string_length = 4
                               , mem_max = 30 * (2^10)^3
                               , time_max = 5 * 60
                               , return_data = FALSE
                               , rds_file = NULL
                               , profmem_type = c("allocation", "snapshot")[1]
                               , highlight_call = "randex::rand_index(a, b)"
                             ) {
    ## check args and optional dependencies
    if(!return_data) {
        if(!requireNamespace("ggplot2", quietly = TRUE)) {
            stop("  randex_benchmark -- 'ggplot2' package should be installed.")
        } else if(return_plot == "combined" && !requireNamespace("patchwork", quietly = TRUE)) {
            stop("  randex_benchmark -- 'patchwork' package should be installed for combined plots.")
        }
    }
    ## load or calculate benchmarks
    if(is.character(rds_file)) {
        benchmarks  <- readRDS(rds_file)
    } else {
        ## check profmem
        if(profmem_type == "allocation" &&
           !capabilities("profmem")) {
            stop("  randex_benchmark -- to use `utils::Rprofmem()` for memory profile R should be compiled with '--enable-memory-profiling' option. Otherwise use `profmem_type = 'snapshot'`")
        }
        ## check packages
        for(cal in calls) {
            cal_pack <- sub("::.*$", "", cal)
            if(!requireNamespace(cal_pack, quietly = TRUE)) {
                stop("  randex_benchmark -- ", cal_pack, " package should be installed for benchmarking.")
            }
        }
        benchmarks  <- list()
        for (n in N) {
            ## define two random sets (a and b) of strings
            a <-
                lapply(1:n, \(i) {
                    set.seed(i)
                    sample(string_space, string_length)
                }) |>
                sapply(paste, collapse = "")
            b <-
                lapply(1:n, \(i) {
                    set.seed(n + i)
                    sample(string_space, string_length)
                }) |>
                sapply(paste, collapse = "")
            ## factorize sets
            lev_ab <- levels(factor(c(a, b)))
            a <- factor(a, levels = lev_ab) |>
                as.numeric()
            b <- factor(b, levels = lev_ab) |>
                as.numeric()
            ## calc rand indexes conditional on last results
            j <- match(n, N)
            benchmarks[[j]] <- 
                ## benchmark calls
                calls |>
                lapply(\(cal) {
                    should_calc <- if (j > 1) {
                                       res <- benchmarks[[j-1]]
                                       res <- res[match(cal, res[, "call"]), ]
                                       res_mem <- res["bites"]
                                       res_time <- res["secs"]
                                       !is.na(res_mem) &&
                                           ## do not calc rand if last results took more than 30Gb of ram (default)
                                           (res_mem < mem_max) &&
                                           (!is.na(res_time)) &&
                                           ## do not calc if takes longer than 5 minutes (default)
                                           (res_time < time_max)
                                   } else {
                                       TRUE
                                   }
                    if(should_calc) {
                        message("Evaluating: ", cal)
                        ## init profiling
                        prof <- tempfile()
                        if(profmem_type == "allocation") {
                            utils::Rprofmem(prof)
                        } else if(profmem_type == "snapshot") {
                            utils::Rprof(prof, memory.profiling = TRUE)
                        }
                        ## calculate Rand index
                        ## -----
                        time <- system.time(
                            val <- try(eval(str2expression(cal)))
                        )
                        ## -----
                        ## kill profiling
                        if(profmem_type == "allocation") {
                            utils::Rprofmem(NULL)
                            mem <-
                                readLines(prof) |>
                                strsplit(split = " :", fixed = TRUE) |>
                                sapply(base::`[`, 1) |>
                                sapply(as.numeric) |>
                                sum(na.rm = TRUE)
                            mem_hu <- mem |>
                                utils:::format.object_size("auto")
                        } else if(profmem_type == "snapshot") {
                            utils::Rprof(NULL)
                            mem <-
                                utils::summaryRprof(prof, memory = "stats") |>
                                _$by.self |>
                                base::`[`(paste0('"', cal, '"'), "mem.total") |>
                                base::`[[`(1)
                        }
                        ## delete tmp file
                        unlink(prof)
                        time <- time[["elapsed"]]
                        names(time) <- NULL
                        if(!inherits(val, "try-error")) {
                            data.frame("call" = cal
                                     , "N" = n
                                     , "val" = val
                                     , "bites" = mem
                                     , "secs" = time)
                        } else {
                            message("Call failed: ", cal)
                            data.frame("call" = cal
                                     , "N" = n
                                     , "val" = NA
                                     , "bites" = NA
                                     , "secs" = NA)
                        }
                    } else {
                        message("Skipping: ", cal)
                        data.frame("call" = cal
                                 , "N" = n
                                 , "val" = NA
                                 , "bites" = NA
                                 , "secs" = NA)
                    }
                }) |>
                do.call(rbind, args = _)
            message(benchmarks[[j]])
        }
    }
    ## visualize or just return results
          if(return_data) {
              return(benchmarks)
          } else {
              benchmarks <- do.call(rbind, benchmarks)
              ## highlight the line
              benchmarks$line <- ifelse(benchmarks$call == highlight_call, 0.1, 0.05)
              ## use 'x' if the value of Rand index is not correct (i.e., Rand > 1)
              benchmarks$shape_correct_value <- as.integer(ifelse(is.na(benchmarks$val) | benchmarks$val > 1, 4, 16))
              benchmarks$call <- sub("::.*$", "", benchmarks$call)
              ## plot memory
              if(return_plot != "time") {
                  plot_mem <- ggplot2::ggplot(
                                           data = benchmarks
                                         , ggplot2::aes(x = N
                                                      , y = bites
                                                      , group = call
                                                      , color = call)) +
                      ggplot2::geom_point(size = 3, ggplot2::aes(shape = shape_correct_value)) +
                      ## ggplot2::scale_shape_manual(values = ifelse(is.na(benchmarks$val) | benchmarks$val > 1, 4, 1)) +
                      ggplot2::scale_shape_identity() + 
                      ggplot2::geom_line(ggplot2::aes(size = call)) +
                      ggplot2::scale_size_manual(values = `names<-`(ifelse(benchmarks$call == "randex::rand_index(a, b)", 1, 0.5), benchmarks$call)) + #
                      ggplot2::scale_x_continuous(trans = "log10"
                                                , labels = scales::trans_format("log10", scales::math_format(10^.x))) + 
                      ggplot2::scale_y_continuous(trans = "log2"
                                                , labels = scales::label_bytes(units = "auto_binary")
                                                , n.breaks = 10) + 
                      ggplot2::annotation_logticks(sides = "b", alpha = 0.5)
                  if(return_plot == "memory") return(plot_mem)
              }
              ## plot time
              if(return_plot != "memory") {
                  plot_time <- ggplot2::ggplot(
                                            data = benchmarks
                                          , ggplot2::aes(x = N
                                                       , y = secs / 60
                                                       , group = call
                                                       , color = call)) +
                      ggplot2::geom_point(ggplot2::aes(size = call)) + 
                      ggplot2::geom_line(ggplot2::aes(size = call)) +
                      ggplot2::scale_size_manual(values = `names<-`(ifelse(benchmarks$call == "randex::rand_index(a, b)", 1, 0.5), benchmarks$call)) + 
                      ggplot2::scale_x_continuous(trans = "log10"
                                                , labels = scales::trans_format("log10", scales::math_format(10^.x))) + 
                      ggplot2::scale_y_continuous(labels = scales::label_timespan(unit = "mins")) + 
                      ggplot2::annotation_logticks(sides = "b", alpha = 0.5)
                  if(return_plot == "time") return(plot_time)
              }
              if(return_plot == "combined") {
                  patchwork::wrap_plots(plot_mem, plot_time, guides = 'collect')
              }
          }
}
