group_benchmark <- function(x, all, na.rm = FALSE) {
  out <- lapply(x, group_benchmark_impl, all = all)
  names(out) <- x

  if (na.rm) out <- rm_na(out)
  out
}

group_benchmark_impl <- function(x, all) {
  if (is.na(x)) {
    return(x)
  }

  out <- all

  # Append other values to `all`
  if (x != "all") {
    out <- c(out, x)
  }

  # Handle unit:
  # 1. Remove it from everywhere
  out <- gsub(col_unit(), "", out)
  # 2. Add it again wherever it's necessary
  if (grepl(col_unit(), x)) {
    if (grepl("input", x)) {
      out <- c(out, input(col_unit()))
    } else {
      out <- c(out, col_unit())
    }
  }

  # Remove debris
  out <- gsub("__", "_", out)
  out <- gsub("^_", "", out)
  out <- out[!grepl(anchor(input()), out)]
  out <- out[nzchar(out)]
  out <- gsub(input(input()), input(), out)

  # tilt_sector groups on tilt subsector
  # https://github.com/2DegreesInvesting/tiltIndicatorAfter/issues/194#issuecomment-2050573259
  if (any(grepl(col_tsector(), out))) {
    # extract original match
    extracted <- grep(col_tsector(), out, value = TRUE)
    # turn col_tsector() into col_tsubsector()
    out <- gsub(col_tsector(), col_tsubsector(), out)
    # re-add original match
    out <- c(out, extracted)
  }

  # Polish
  other <- setdiff(out, all)
  out <- c(all, sort(other))

  out
}
