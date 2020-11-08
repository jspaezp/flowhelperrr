
#' Read FCS files with multiple experiments in them
#'
#' @param filename name of the file to be read
#' @param ...
#'
#' @return a list of flow frames and warning of
#'         which ones were not read successfully
#' @export
read.multi.FCS <- function(filename, ...) {
  warn_message <- tryCatch(
    flowCore::read.FCS(filename),
    warning = function(w) {
      return(w$message)
    }
  )
  num_samples <- gsub("The file contains ([0-9]+) .*", "\\1", warn_message)
  num_samples <- as.integer(num_samples) + 1

  # TODO decide if I want to handle some common warning automatically ...
  data_list <- purrr::map(
    seq_len(num_samples),
    purrr::safely(~ read.FCS(filename, dataset = .x))
  )

  failed_datasets <- purrr::map_lgl(data_list, ~ !is.null(.x$error))

  warning(
    "\n\nDatasets number ",
    paste(which(failed_datasets), collapse = ", "),
    " Failed to be read\n\n"
  )

  data_list <- data_list[!failed_datasets]
  data_list <- purrr::map(data_list, ~ .x$result)

  # TODO make this check if the field exists first ...
  names(data_list) <- purrr::map_chr(
    data_list,
    ~ .x@description$`GTI$SAMPLEID`
  )

  return(data_list)
}


#' Concatenates a list of flow frames into a tibble
#'
#' @param flowframe_list a named list of flow frames
#'
#' @return a tibble
#' @export
concat_exprs <- function(flowframe_list) {
  out_df <- purrr::map_dfr(
    flowframe_list, ~ as.data.frame(.x@exprs),
    .id = "SampleID"
  )

  return(tibble::as_tibble(out_df))
}
