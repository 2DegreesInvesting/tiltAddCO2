rm_na <- function(x) {
  x[!is.na(x)]
}

anchor <- function(x) {
  paste0("^", x, "$")
}
