rm_na <- function(x) {
  x[!is.na(x)]
}

anchor <- function(x) {
  paste0("^", x, "$")
}

input <- function(x = NULL) {
  paste0("input_", x)
}

unit <- function(x = NULL) {
  paste0("unit_", x)
}
