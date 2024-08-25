pacman::p_load(tidyverse, RcppSimdJson, pacman, rvest, jsonlite, tictoc, tidyfst)

safe_json <- \(x) {
    tryCatch(
        RcppSimdJson::parse(),
        error = function(e) {
            fromJSON(x)
        }
    )
}

progressbar <- list(
    format = " {cli::pb_rate} {cli::pb_eta} {cli::pb_bar} {cli::pb_current}/{cli::pb_total}",
    clear = FALSE, 
    width = NULL
)
