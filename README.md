Functions that are utilized across different projects.
```
if(!requireNamespace("pacman", quietly = TRUE)) {
    install.packages("pacman")
    pacman::p_load(RcppSimdJson, tidyverse, tidyfst, httr2, httr, jsonlite, furrr, listviewer, rvest, crayon, emojifont, devtools, arrow, reticulate, pins, yyjsonr, duckplyr, V8, fs)
} else {
    pacman::p_load(RcppSimdJson, tidyverse, tidyfst, httr2, httr, jsonlite, furrr, listviewer, rvest, crayon, emojifont, devtools, arrow, reticulate, pins, yyjsonr, duckplyr, V8, fs)
}

jsengine <- v8()

mypath <- \(x = "") sprintf("%s/%s", getwd(), x)

methods_overwrite()

methods_restore()

pin_write <- \(x, name, type = "parquet", target = "process", versioned = FALSE, ...) {
    if (target == "process") {
        board_path <- board_folder(mypath("data/process"), versioned = versioned)
    } else {
        if (target == "raw") {
            board_path <- board_folder(mypath("data/raw"), versioned = versioned)
        }
    }

    pins::pin_write(
        board_path,
        x = x,
        name = name,
        ...,
        type = type
    )
}

pin_read <- \(name, target = "process", versioned = FALSE, ...) {
    if (target == "process") {
        board_path <- board_folder(mypath("data/process"), versioned = versioned)
    } else {
        if (target == "raw") {
            board_path <- board_folder(mypath("data/raw"), versioned = versioned)
        }
    }

    pins::pin_read(
        board_path,
        name = name,
        ...
    )
}

POST_proxy <- \(url, ...) { # POST function that use proxy by default.
    POST(
        url = url,
        use_proxy(
            url = "http://n890.kdltps.com",
            port = 15818
        ),
        ...
    )
}

GET_proxy <- \(url, ...) { # GET function that use proxy by default.
    GET(
        url = url,
        use_proxy(
            url = "http://n890.kdltps.com",
            port = 15818
        ),
        ...
    )
}

random_useragents_raw <- "https://raw.githubusercontent.com/fake-useragent/fake-useragent/master/src/fake_useragent/data/browsers.json" %>%
    read_html() %>%
    html_text() %>%
    str_extract_all("\\{.+?\\}") %>%
    pluck(1) %>%
    map_dfr(~ fromJSON(.) |> as_tibble_row())

random_useragents <- \() {
    pin_read("user-agents", target = "raw") %>%
        sample_n(1) %>%
        pull("useragent")
}

show_table <- \(data, ...) {
    DT::datatable(
        data,
        extensions = "Buttons",
        options = list(
            autoWidth = TRUE,
            dom = "Blfrtip",
            buttons = list(
                list(
                    extend = "excel",
                    text = "Export to Excel",
                    exportOptions = list(
                        columns = ":visible"
                    )
                )
            ),
            columnDefs = list(list(width = "150px", targets = "_all")),
            # language = list(url = "//cdn.datatables.net/plug-ins/9dcbecd42ad/i18n/Chinese.json"),
            mark = TRUE,
            fixedHeader = TRUE,
            pageLength = 10,
            lengthMenu = list(c(10, 50, -1), c("10", "50", "All"))
        ),
        filter = list(position = "top", clear = FALSE),
        class = "cell-border stripe",
        ...
    )
}

progressbar <- list(
    format = " {cli::pb_rate} {cli::pb_eta} {cli::pb_bar} {cli::pb_current}/{cli::pb_total}",
    clear = FALSE, # 完成后不清除进度条
    width = NULL # 自动宽度适应
)

rate <- rate_backoff(
    pause_base = 2,
    pause_cap = 60,
    pause_min = 1,
    max_times = 5,
    jitter = TRUE
)

robust <- \(f, max_times = 5) {
    possibly(
        insistently(
            f,
            rate = rate_backoff(
                pause_base = 2,
                pause_cap = 60,
                pause_min = 1,
                max_times = max_times,
                jitter = TRUE
            ),
        ),
        otherwise = "error!",
        quiet = FALSE
    )
}

alert <- \(message = "Headers updated!", color = "red", emoji = "rocket") {
    get_color <- get(color, mode = "function", inherits = TRUE)

    get_emoji <- \(x) {
        if (is.na(emojifont::emoji(x))) {
            return("😄")
        } else {
            emojifont::emoji(x)
        }
    }

    cat(
        sprintf(
            "%s %s %s\n",
            get_emoji(emoji),
            bold(
                get_color(sprintf("%s", message))
            ),
            bold(
                green(str_extract(capture.output(now()), '(?<=").+?(?=")'))
            )
        )
    )
}

if (!reticulate::py_available()) {
    reticulate::use_condaenv("pytorch_gpu")
    reticulate::import_builtins()
    reticulate::py_available()
    alert("The Python environment with cuda has been imported into R!", "yellow", "snake")
} else {
    alert("The Python environment with cuda has been imported into R!", "yellow", "snake")
}

# ==============================================================================

dir_tree()

green("All the functions have been loaded successfully!\n") %>%
    bold() %>%
    sprintf("%s %s", emoji(search_emoji("smile"))[2], .) %>%
    cat()
```
