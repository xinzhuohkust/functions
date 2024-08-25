pacman::p_load(tidyverse, RcppSimdJson, pacman, rvest, jsonlite)

safe_json <- \(x) {
    tryCatch(
        RcppSimdJson::parse(),
        error = function(e) {
            fromJSON(x)
        }
    )
}
