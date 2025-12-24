# Vedaly Rmarkdown Theme

This theme creates `html_report` and `pdf_report` compatible with Vedaly 
PREON platform. Key features include:

*  Integration with commenting on selected text within the report on PREON
*  Ability to save plot from the report to Favorites on PREON, or insert it into 
own report
*  `info` and `warning` boxes for emphasizing 

To use `info` and `warning` formatting boxes, use the following syntax:

```
::: {.warning data-latex=""}
Some warning text that will appear in a yellow box
:::
```

```
::: {.info data-latex=""}
Some info text that will appear in a blue box
:::
```

# Installing the package

```
devtools::document()
devtools::install()
```

If above fails with something like:

```
ℹ Updating vedalytheme documentation
ℹ Loading vedalytheme
Error in env_get_list(ns, names(active_bindings)[!active_bindings]) : 
  lazy-load database '/opt/homebrew/lib/R/4.5/site-library/vedalytheme/R/vedalytheme.rdb' is corrupt
In addition: Warning message:
In env_get_list(ns, names(active_bindings)[!active_bindings]) :
  internal error -3 in R_decompress1
```

then do:
```
try(detach("package:vedalytheme", unload = TRUE, character.only = TRUE), silent = TRUE)
try(unloadNamespace("vedalytheme"), silent = TRUE)
remove.packages("vedalytheme")
unlink(c("man", "NAMESPACE", "vedalytheme.Rproj.user", ".Rproj.user"), recursive = TRUE, force = TRUE)
unlink(list.files(pattern = "\\.Rds$|\\.rdb$|\\.rdx$|\\.o$|\\.so$|\\.dll$", recursive = TRUE, full.names = TRUE),
       recursive = TRUE, force = TRUE)
devtools::clean_dll()
devtools::install(build = FALSE, force = TRUE)
```
