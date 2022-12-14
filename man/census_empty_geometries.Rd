% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/census_empty_geometries.R
\name{census_empty_geometries}
\alias{census_empty_geometries}
\title{Get empty geometries}
\usage{
census_empty_geometries(
  census_scales = cc.data::census_scales,
  census_years = cc.data::census_years
)
}
\arguments{
\item{census_scales}{<\verb{character vector}> Should be equal to
\code{\link[cc.data]{census_scales}}}

\item{census_years}{<\verb{numeric vector}> Should be equal to
\code{\link[cc.data]{census_years}}}
}
\value{
A named list of \verb{sf data.frame} the same length as census_scales,
with census geometries, containing only ID, population and households.
}
\description{
Get empty geometries
}
