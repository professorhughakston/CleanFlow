# AGENTS.md — R house style

R analysis project for a solo lab. The author is an old C / Windows programmer
who has chosen this style on purpose. Follow this file over generic R advice
and over C habits. Do not invent a different dialect.

Air (`air.toml`) is the formatter. Do not fight it on spacing, braces, or `<-`.

---

## Non-negotiables

- Write R. New objects and functions use `snake_case`.
- Assign with `<-`. Use `=` only for named arguments (`na.rm = TRUE`).
- K&R braces: `{` is the last character on its line. `} else {` stays on one line.
- Four-space indent. This is a deliberate house override of tidyverse's
  two-space default. Spaces, never tabs. No semicolons. Soft wrap near 80 columns.
  Do not "correct" indent back to two. Air (`indent-width = 4`) is the authority.
- Variables are nouns. Functions are verbs.
- Call other packages by their published names. Do not rename imported functions
  or arguments.
- Filenames: lowercase `snake_case` or `kebab-case`, end in `.R`. No spaces,
  no parentheses.
- No PHI, no real patient identifiers, no secrets in code, comments, filenames,
  or git.
- Do not restyle bundled or legacy C / C++ in this repo.
- Do not create an R package unless asked.

---

## Naming: kind_which

Prefix = kind. Stem = which. Both halves must earn their keep.
Do not encode storage type (integer vs double) in the name.

| Prefix        | Kind                         | Good                      | Bad                          |
|---------------|------------------------------|---------------------------|------------------------------|
| `n_`          | count                        | `n_readers`, `n_cases`    | `n_number`, `n_int`          |
| `df_`         | data frame (when needed)     | `df_raw`, `df_alluvial`   | `df_data_frame`              |
| `idx_`        | integer position             | `idx_case`                | `i_readers`                  |
| `id_`         | identifier, not a position   | `id_reader`               |                              |
| `is_` / `has_`| logical                      | `is_complete`, `has_lesion` | `b_ok`, `bool_flag`        |
| `fit_`        | model object                 | `fit_surv`                | `m_surv`                     |
| `fig_` / `plot_` | ggplot                    | `fig_km`, `plot_roc`      | `p_plot`                     |
| `p_`          | p-value only                 | `p_value`, `p_adj`        | `p_plot`, `p_fit`            |

Forbidden prefixes: `i_` as integer, `n_` as float/double, `str_`, `int_`,
`num_`, `chr_`, `dbl_`, `bool_`, `lst_`, `vec_`, `arr_`, `ptr_`, `hwnd_`,
`t_`, `c_`.

- Loop indices stay `i`, `j`, `k`.
- Counts are `n_what`, never `i_what`.
- Do not prefix columns inside a frame. Columns are `time`, `status`, `age`.
- Do not shadow: `c`, `t`, `data`, `df`, `mean`, `T`, `F`, `n`, `file.path`.
- Use `TRUE` / `FALSE`. Never `T` / `F`.

Data-frame stages:

```r
df_raw      <- ...
df_clean    <- df_raw |> filter(...)
df_alluvial <- df_clean |> mutate(...)
fig_alluvial <- ggplot(df_alluvial, ...)
```

If only one table is in flight, drop `df_` and use `<dataset>_raw` →
`<dataset>_clean` → `<dataset>_<purpose>`.

---

## C-to-R: never emit these

| C habit                         | Here                                      |
|---------------------------------|-------------------------------------------|
| `x.y` or `obj->member`          | `x$y` or `x[["y"]]`                       |
| `.` as a word separator         | `_`. Dots are reserved for S3 methods     |
| `print.foo <- function()`       | That registers an S3 method for class `foo` |
| Leading `.` as a type tag       | Leading `.` hides the object from `ls()`  |
| `iCount`, `strName`, `bFlag`    | Drop Systems Hungarian                    |
| `n` = float, `i` = integer      | `n_` = count. `i` = loop index            |
| `=` assignment                  | `<-`                                      |
| `;` statement terminator        | omit                                      |
| `5` is an int                   | `5` is double. `5L` is integer. Do not stamp that in the name |

---

## Script shape

For a replication of an existing analysis:

```
README.md
AGENTS.md
air.toml
00-original-reference.R   # old script, read-only reference, do not restyle
01-load.R
02-clean.R
03-analyze.R
04-plot.R
```

A single `01-replicate-<short-name>.R` is fine if the original was one file.

Inside a script, in this order:

1. Short header: purpose, and whether the data are public or synthetic.
2. `library()` calls.
3. Load.
4. Clean.
5. Model / plot.
6. `sessionInfo()` at the end of a replication script.

Prefer the native pipe `|>` for a sequence on one object.
Comments explain why, not what. `#` plus one space. No banner-art boxes.

Preferred packages unless the user names others: tidyverse, ggplot2,
survival, survminer. Do not add packages for their own sake.

---

## Safety

- No PHI. No real patient identifiers. No secrets.
- Do not write real names, MRNs, addresses, or identifiable dates into
  files that will be committed.
- If a script needs a local data path, keep that path out of git
  (use a local config or an untracked `paths.R`).
