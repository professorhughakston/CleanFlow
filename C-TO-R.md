# C / Windows → this R house style

One-screen map. The enforceable rules live in `AGENTS.md`.

| Old habit | Here | Why |
|---|---|---|
| Systems Hungarian (`iCount`, `strName`, `bFlag`, `hwnd`) | Drop | R will not keep the type stamp honest (`5` is double; `i + 1` becomes double) |
| Apps Hungarian (kind, not storage) | Keep, as `kind_which` | `n_readers`, `df_raw`, `is_complete` |
| `n` = float, `i` = integer | No | `n_` = count. `i` / `j` / `k` = loop index. Continuous values get no type prefix |
| CamelCase locals | `snake_case` | tidyverse / lintr / Air |
| PascalCase functions you write | `snake_case` verbs | Call other packages by *their* published names |
| K&R braces | Keep | `{` last on the line, 4-space indent (house override) |
| Allman braces | Only in untouched legacy C | Not in new `.R` files |
| `=` assignment | `<-` | `=` is for named arguments only |
| `.` member access | `$` and `[[` | In R, `.` is just a character in a name. S3 methods are `generic.class` |
| `->` pointer | Does not exist | |
| `;` terminator | Drop | |
| `T` / `F` | `TRUE` / `FALSE` | `T` and `F` are variables you can overwrite |
| Spaces in filenames | `01-load.R` | No spaces, no parentheses |
| 8-character C names | Meaningful `snake_case` | The 80s constraint is gone |

## Prefixes you actually use

```
n_readers      count of readers
df_raw         original frame
df_clean       after filters
df_alluvial    shaped for a specific plot
idx_case       position
id_reader      identifier
is_complete    logical
has_lesion     logical
fit_surv       model
fig_km         ggplot
p_adj          adjusted p-value only
```

Never: `i_readers`, `n_number`, `df_data_frame`, `p_plot`.

## Tiny honest example

```r
n_obs <- nrow(df_raw)
df_clean <- df_raw |>
    filter(!is.na(time), !is.na(status))
fit_surv <- survminer::surv_fit(
    survival::Surv(time, status) ~ sex,
    data = df_clean
)
fig_km <- survminer::ggsurvplot(fit_surv)
```
