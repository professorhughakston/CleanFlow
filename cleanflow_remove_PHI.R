# Grok 4.6 Build April 2026
# 20260926.0 File Creation Date: 2026-09-26
# Read the CleanFlow trial workbook, snake_case the column names,
# shorten LastName / FirstName, and write an .xlsx.
#
#   Last name  -> first three letters (hyphens and apostrophes are not letters)
#   First name -> first letter, no period
#   Smith / John            -> Smi / J
#   Hyphenated-Lastname / Karen  -> Hyp / K
#
# Follow-up date columns stay character. Some cells are words
# (Lost, Moved, Extracted, Deceased), not dates. Real dates in those
# columns are written as YYYY-MM-DD. completion_date is a Date.
# The padded text cell "8/15/2023" is normalized to 2023-08-15.
#
# .xlsx rather than .xls: writing the old BIFF format from R needs
# Java or Perl. Excel opens this file directly.
#
#
# RStudio: edit the two paths if the workbook is not in the working
# directory, then source this file. The coded data frame is `cleanflow`.
# Terminal:
# Rscript cleanflow-remove-PHI.R "CleanFlow Trial raw-censored.xls"

input_path <- "~/Desktop/Sonendo Academic Journal Article/Analysis/CleanFlow-Trial-raw-censored.xls"
output_path <- "~/Desktop/R/CleanFlow/CleanFlow-Trial-PHI-Removed.xlsx"

args <- commandArgs(trailingOnly = TRUE)
if (length(args) >= 1L) {
    input_path <- args[[1L]]
}
if (length(args) >= 2L) {
    output_path <- args[[2L]]
}

column_names <- c(
    "RegressionIndex" = "regression_index",
    "TrialNumber" = "trial_number",
    "LastName" = "last_name",
    "FirstName" = "first_name",
    "TDONumber" = "tdo_number",
    "Subject Number" = "subject_number",
    "CompletionDate" = "completion_date",
    "ThreeMonthDate" = "three_month_date",
    "SixMonthDate" = "six_month_date",
    "TwelveMonthDate" = "twelve_month_date",
    "TwentyFourMonthDate" = "twenty_four_month_date",
    "ToothNumber" = "tooth_number",
    "ToothType" = "tooth_type",
    "PulpalDiagnosis" = "pulpal_diagnosis",
    "PeriapicalDiagnosis" = "periapical_diagnosis",
    "OverallFindingPreop" = "overall_finding_preop",
    "RootOnePreop" = "root_one_preop",
    "RootTwoPreop" = "root_two_preop",
    "RootThreePreop" = "root_three_preop",
    "OverallFinding3mo" = "overall_finding_3mo",
    "RootOne3mo" = "root_one_3mo",
    "RootTwo3mo" = "root_two_3mo",
    "RootThree3mo" = "root_three_3mo",
    "OverallFinding6mo" = "overall_finding_6mo",
    "RootOne6mo" = "root_one_6mo",
    "RootTwo6mo" = "root_two_6mo",
    "RootThree6mo" = "root_three_6mo",
    "OverallFinding12mo" = "overall_finding_12mo",
    "RootOne12mo" = "root_one_12mo",
    "RootTwo12mo" = "root_two_12mo",
    "RootThree12mo" = "root_three_12mo",
    "OverallFinding24mo" = "overall_finding_24mo",
    "RootOne24mo" = "root_one_24mo",
    "RootTwo24mo" = "root_two_24mo",
    "RootThree24mo" = "root_three_24mo",
    "Imputation" = "imputation"
)

integer_columns <- c("regression_index", "tdo_number", "tooth_number")
date_columns <- "completion_date"
followup_columns <- c(
    "three_month_date",
    "six_month_date",
    "twelve_month_date",
    "twenty_four_month_date"
)
followup_words <- c("Lost", "Moved", "Extracted", "Deceased")

is_blank_cell <- function(cell) {
    is.null(cell) || length(cell) == 0L || all(is.na(cell))
}

as_date_utc <- function(cell) {
    if (is_blank_cell(cell)) {
        return(as.Date(NA))
    }
    if (inherits(cell, "POSIXt")) {
        return(as.Date(cell, tz = "UTC"))
    }
    if (inherits(cell, "Date")) {
        return(as.Date(cell, tz = "UTC"))
    }
    if (is.numeric(cell)) {
        return(as.Date(cell, origin = "1899-12-30"))
    }
    text <- trimws(as.character(cell[[1L]]))
    parsed <- as.Date(text, format = "%m/%d/%Y")
    if (is.na(parsed)) {
        parsed <- as.Date(text, format = "%Y-%m-%d")
    }
    parsed
}

as_integer_cell <- function(cell) {
    if (is_blank_cell(cell)) {
        return(NA_integer_)
    }
    as.integer(round(as.numeric(cell)))
}

as_text_cell <- function(cell) {
    if (is_blank_cell(cell)) {
        return(NA_character_)
    }
    text <- trimws(paste(as.character(cell), collapse = " "))
    if (!nzchar(text)) {
        return(NA_character_)
    }
    text
}

as_followup_cell <- function(cell) {
    if (is_blank_cell(cell)) {
        return(NA_character_)
    }
    if (
        inherits(cell, "POSIXt") || inherits(cell, "Date") || is.numeric(cell)
    ) {
        return(format(as_date_utc(cell), "%Y-%m-%d"))
    }
    text <- trimws(as.character(cell[[1L]]))
    if (!nzchar(text)) {
        return(NA_character_)
    }
    parsed <- as.Date(text, format = "%m/%d/%Y")
    if (is.na(parsed)) {
        parsed <- as.Date(text, format = "%Y-%m-%d")
    }
    if (!is.na(parsed)) {
        return(format(parsed, "%Y-%m-%d"))
    }
    text
}

flatten_column <- function(column, converter) {
    vapply(column, converter, FUN.VALUE = converter(NA), USE.NAMES = FALSE)
}

letters_only <- function(x) {
    gsub("[^[:alpha:]]+", "", x, perl = TRUE)
}

shorten_names <- function(last_name, first_name) {
    last_letters <- letters_only(last_name)
    first_letters <- letters_only(first_name)
    last_short <- substr(last_letters, 1L, 3L)
    first_short <- substr(first_letters, 1L, 1L)
    last_missing <- is.na(last_letters) | !nzchar(last_letters)
    first_missing <- is.na(first_letters) | !nzchar(first_letters)
    last_short[last_missing] <- NA_character_
    first_short[first_missing] <- NA_character_
    list(last_name = last_short, first_name = first_short)
}

to_snake_case <- function(name) {
    name <- trimws(name)
    name <- gsub("[^A-Za-z0-9]+", "_", name, perl = TRUE)
    name <- gsub("([a-z0-9])([A-Z])", "\\1_\\2", name, perl = TRUE)
    name <- gsub("([A-Z]+)([A-Z][a-z])", "\\1_\\2", name, perl = TRUE)
    name <- gsub("([A-Za-z])([0-9])", "\\1_\\2", name, perl = TRUE)
    name <- gsub("([0-9])([A-Za-z])", "\\1_\\2", name, perl = TRUE)
    name <- tolower(name)
    name <- gsub("_(3|6|12|24)_mo$", "_\\1mo", name, perl = TRUE)
    name <- gsub("_+", "_", name, perl = TRUE)
    gsub("^_|_$", "", name, perl = TRUE)
}

rename_columns <- function(original) {
    unknown <- setdiff(original, names(column_names))
    if (length(unknown) > 0L) {
        warning(
            "No explicit snake_case name for: ",
            paste(unknown, collapse = ", "),
            ". Those headers were converted generically.",
            call. = FALSE
        )
    }
    new_names <- vapply(
        original,
        function(name) {
            if (name %in% names(column_names)) {
                unname(column_names[[name]])
            } else {
                to_snake_case(name)
            }
        },
        FUN.VALUE = character(1L),
        USE.NAMES = FALSE
    )
    if (anyDuplicated(new_names)) {
        stop("Snake_case names are not unique.", call. = FALSE)
    }
    new_names
}

read_cleanflow <- function(path) {
    if (!file.exists(path)) {
        stop(
            "Workbook not found: ",
            path,
            "\n",
            "Working directory: ",
            getwd(),
            call. = FALSE
        )
    }
    # "list" keeps each cell's own type. Guessing a date type would turn
    # Lost / Moved / Extracted / Deceased into NA.
    readxl::read_excel(
        path,
        sheet = 1L,
        col_types = "list",
        trim_ws = TRUE,
        .name_repair = "minimal"
    )
}

code_cleanflow <- function(raw) {
    new_names <- rename_columns(names(raw))
    if (!all(c("last_name", "first_name") %in% new_names)) {
        stop("The sheet has no LastName / FirstName columns.", call. = FALSE)
    }

    out <- vector("list", length(new_names))
    names(out) <- new_names

    for (i in seq_along(new_names)) {
        name <- new_names[[i]]
        column <- raw[[i]]
        if (name %in% integer_columns) {
            out[[i]] <- flatten_column(column, as_integer_cell)
        } else if (name %in% date_columns) {
            out[[i]] <- as.Date(vapply(
                column,
                function(cell) as.character(as_date_utc(cell)),
                FUN.VALUE = character(1L),
                USE.NAMES = FALSE
            ))
        } else if (name %in% followup_columns) {
            out[[i]] <- flatten_column(column, as_followup_cell)
        } else {
            out[[i]] <- flatten_column(column, as_text_cell)
        }
    }

    coded <- shorten_names(out$last_name, out$first_name)
    out$last_name <- coded$last_name
    out$first_name <- coded$first_name

    cleanflow <- as.data.frame(
        out,
        stringsAsFactors = FALSE,
        check.names = FALSE
    )
    keep <- !is.na(cleanflow$subject_number) & nzchar(cleanflow$subject_number)
    cleanflow <- cleanflow[keep, , drop = FALSE]
    rownames(cleanflow) <- NULL

    for (name in followup_columns) {
        values <- cleanflow[[name]]
        bad <- !is.na(values) &
            !grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", values, perl = TRUE) &
            !values %in% followup_words
        if (any(bad)) {
            warning(
                name,
                " has values that are neither a date nor ",
                paste(followup_words, collapse = " / "),
                ": ",
                paste(unique(values[bad]), collapse = ", "),
                call. = FALSE
            )
        }
    }

    cleanflow
}

missing_packages <- c("readxl", "writexl")
missing_packages <- missing_packages[
    !vapply(missing_packages, requireNamespace, logical(1L), quietly = TRUE)
]
if (length(missing_packages) > 0L) {
    stop(
        "Install the missing packages, then re-run:\n",
        "  install.packages(c(",
        paste(sprintf('"%s"', missing_packages), collapse = ", "),
        "))",
        call. = FALSE
    )
}

raw_sheet <- read_cleanflow(input_path)
cleanflow <- code_cleanflow(raw_sheet)
rm(raw_sheet)

writexl::write_xlsx(cleanflow, path = output_path, col_names = TRUE)

message(sprintf(
    "Wrote %d rows x %d columns to %s",
    nrow(cleanflow),
    ncol(cleanflow),
    normalizePath(output_path, mustWork = FALSE)
))
message(sprintf(
    "Name fields are a 3-letter last name and a first initial (row 1: %s %s).",
    cleanflow$last_name[[1L]],
    cleanflow$first_name[[1L]]
))
