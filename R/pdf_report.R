#' Custom RMarkdown Theme
#'
#' @param ... Arguments passed to the output format function.
#' @return A modified HTML or PDF output format with the custom theme.
#' @export
pdf_report <- function(toc = TRUE, ...) {


    logo <- system.file(
      "rmarkdown/resources/vedaly-logo.png",
      package = "vedalytheme"
    )

    # update header file with correct logo path
    header <- system.file("rmarkdown/templates/pdf_report/header.tex",
                       package = "vedalytheme")
    tx  <- readLines(header)
    tx2  <- gsub(
      pattern = "\\{vedaly-logo.png\\}",
      replace = paste0("\\{", logo, "\\}"),
      x = tx
    )
    writeLines(tx2, con=header)

    # update footer file with correct logo path
    footer <- system.file("rmarkdown/templates/pdf_report/footer.tex",
                          package = "vedalytheme")
    tx  <- readLines(footer)
    tx2  <- gsub(
      pattern = "\\{vedaly-logo.png\\}",
      replace = paste0("\\{", logo, "\\}"),
      x = tx
    )
    writeLines(tx2, con=footer)

    rmarkdown::pdf_document(
      toc = toc,
      includes = rmarkdown::includes(in_header = header, after_body = footer),
      ...
    )
}
