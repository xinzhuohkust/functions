```
pacman::p_load(tidyverse, tidyfst, httr2, httr, jsonlite, furrr, listviewer, rvest, crayon, emojifont, devtools, arrow, reticulate, pins, yyjsonr, duckplyr, V8, fs)

jsengine <- v8()

mypath <- \(x = "") sprintf("%s/%s", getwd(), x)

methods_overwrite()

pin_write <- \(x, name, type = "parquet", target = "process", ...) {
    
    if(target == "process") {
        board_path <- board_folder(mypath("data/process"))
    } else {
        if(target == "raw") {
            board_path <- board_folder(mypath("data/raw"))
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

pin_read <- \(name, target = "process", ...) {

    if (target == "process") {
        board_path <- board_folder(mypath("data/process"))
    } else {
        if (target == "raw") {
            board_path <- board_folder(mypath("data/raw"))
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
            port = 15818,
            username = "t18683899043273",
            password = "jxpiwy74"
        ),
        ...
    )
}

GET_proxy <- \(url, ...) { # GET function that use proxy by default.
    GET(
        url = url,
        use_proxy(
            url = "http://n890.kdltps.com",
            port = 15818,
            username = "t18683899043273",
            password = "jxpiwy74"
        ),
        ...
    )
}

random_useragents <- \() {
    "https://raw.githubusercontent.com/fake-useragent/fake-useragent/master/src/fake_useragent/data/browsers.json" %>%
        read_html() %>%
        html_text() %>%
        str_extract_all("\\{.+?\\}") %>%
        pluck(1) %>%
        map_dfr(~ fromJSON(.) |> as_tibble_row()) %>%
        sample_n(size = 1) %>%
        pull(useragent)
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

robust <- \(f) {
    possibly(
        insistently(
            f,
            rate = rate
        ),
        otherwise = "error!",
        quiet = FALSE
    )
}

alert <- \(message = "Headers updated!") {
    cat(
        sprintf(
            "%s %s %s\n",
            "🚀",
            bold(
                red(sprintf("%s", message))
            ),
            bold(
                green(str_extract(capture.output(now()), '(?<=").+?(?=")'))
            )
        )
    )
}
```
