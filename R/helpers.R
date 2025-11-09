#' Get the path to the Vedaly logo
#' @return Character string with the path to the logo
get_logo_path <- function() {
  system.file("rmarkdown/resources/vedaly-logo.png", package = "vedalytheme")
}
