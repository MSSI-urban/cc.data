#' Get census vectors values
#'
#' @param census_empty_geometries <`list of sf data.frame`> The output of
#' \code{\link[susdata]{census_empty_geometries}}.
#' @param census_vectors <`data.frame`> Should be equal to
#' \code{\link[susdata]{census_vectors}}
#' @param census_scales <`character vector`> Should be equal to
#' \code{\link[susdata]{census_scales}}
#' @param census_years <`numeric vector`> Should be equal to
#' \code{\link[susdata]{census_years}}
#'
#' @return A list of scales and years of census data accompanied with the
#' parent values.
#' @export
census_data_raw <- function(census_empty_geometries, census_vectors,
                            census_scales, census_years) {
  sapply(census_scales, \(scale) {
    sapply(as.character(census_years), \(year) {

      # Dataframe
      empty_geo <- census_empty_geometries[[scale]][[year]]

      # Relevant named vectors
      vecs <-
        census_vectors[, c("var_code", paste0("vec_", year), "parent_vectors")]
      vecs <- vecs[!is.na(vecs[[paste0("vec_", year)]]), ]
      var_codes <- vecs[[paste0("vec_", year)]]
      names(var_codes) <- vecs$var_code
      var_codes <- var_codes[!is.na(var_codes)]
      # With names, add a number in cases a variable needs to be a sum
      var_codes <-
        mapply(\(vec, name) {
          vec <- unname(vec)
          sapply(vec, \(v) {
            names(v) <- paste0(name, "_", which(v == vec))
            v
          }, USE.NAMES = FALSE)
        }, var_codes, names(var_codes), USE.NAMES = FALSE) |> unlist()

      # Current census dataset
      census_dataset <- paste0("CA", sub("20", "", year))

      # Get the variable values
      dat <- cancensus::get_census(dataset = census_dataset,
                                   regions = list(PR = "13"),
                                   level = scale,
                                   vectors = unlist(var_codes),
                                   geo_format = NA,
                                   quiet = TRUE)
      dat <- dat[, c("GeoUID", names(var_codes))]

      # Addition additive variables
      tb <- table(gsub("_[0-9]$", "", names(dat)))
      to_add <- names(tb[tb > 1])

      to_add_done <- sapply(to_add, \(x) {
        dat[grepl(x, names(dat))] |> rowSums()
      }, USE.NAMES = TRUE)

      dat <- dat[, !grepl(paste0(to_add, collapse = "|"), names(dat))]
      dat <- tibble::as_tibble(cbind(dat, to_add_done))

      names(dat) <- gsub("_[0-9]$", "", names(dat))

      # Get parent vectors
      pv <- cancensus::list_census_vectors(census_dataset)
      pv <- pv[pv$vector %in% var_codes, ]

      pv_vec <- ifelse(is.na(pv$parent_vector), pv$aggregation, pv$parent_vector)
      pv_vec <- gsub(".* ", "", pv_vec)

      pv <- cbind(pv["vector"], parent_vector = pv_vec)
      pv <- merge(tibble::tibble(var_code = names(var_codes), var_codes), pv,
                  by.x = "var_codes", by.y = "vector")
      pv$var_code <- gsub("_[0-9]$", "", pv$var_code)

      switch_pv <- vecs$parent_vectors
      names(switch_pv) <- vecs$var_code
      switch_pv <- switch_pv[!is.na(switch_pv)]
      switch_pv <- switch_pv[grepl(census_dataset, switch_pv)]

      switch_pv <- tibble::tibble(var_code = names(switch_pv),
                                  parent_vector = unlist(switch_pv))

      pv <- pv[!pv$var_code %in% switch_pv$var_code, ]

      pv <- rbind(pv[c("var_code", "parent_vector")], switch_pv)
      pv <- unique(pv)

      pv_vecs <- pv$parent_vector
      names(pv_vecs) <- pv$var_code

      # Retrieve the values of parent vectors
      pv <-
        mapply(\(x, y) {
          out <- cancensus::get_census(dataset = census_dataset,
                                       regions = list(PR = "13"),
                                       level = scale,
                                       vectors = x,
                                       geo_format = NA,
                                       quiet = TRUE)
          out <- out[c(1, length(out))]
          names(out) <- c("GeoUID", paste0(y, "_parent"))
          out
        }, pv_vecs, names(pv_vecs), SIMPLIFY = FALSE)

      pv <- tibble::as_tibble(Reduce(merge, pv))

      # Bind variables values with parent vectors
      tibble::as_tibble(merge(merge(dat, pv), empty_geo)) |>
        sf::st_as_sf()

    }, simplify = FALSE, USE.NAMES = TRUE)
  }, simplify = FALSE, USE.NAMES = TRUE)
}