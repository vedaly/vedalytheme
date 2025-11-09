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
