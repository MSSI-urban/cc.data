% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/census_drop_parents.R
\name{census_drop_parents}
\alias{census_drop_parents}
\title{Drop parent variables}
\usage{
census_drop_parents(
  normalized,
  census_vectors_table = cc.data::census_vectors_table
)
}
\arguments{
\item{normalized}{<\verb{list of sf data.frame}> The output of
\code{\link[cc.data]{census_normalize}}.}

\item{census_vectors_table}{<\verb{character vector}> Should be equal to
\code{\link[cc.data]{census_vectors_table}}}
}
\value{
A list of scales and years of census data with the columns
corresponding to ID, census_vectors_table$var_code, and geometry.
}
\description{
Drop parent variables
}
