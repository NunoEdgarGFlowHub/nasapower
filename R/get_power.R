#' Get NASA POWER Data and Return a Tidy Data Frame
#'
#' Get \acronym{POWER} global meteorology and surface solar energy climatology
#'   data and return a tidy data frame \code{\link[tibble]{tibble}}. All options
#'   offered by the official \acronym{POWER} \acronym{API} are supported.
#'
#' @param community A character vector providing community name: \dQuote{AG},
#'   \dQuote{SB} or \dQuote{SSE}.  See argument details for more.
#' @param pars A character vector of solar, meteorological or climatology
#'   parameters to download.  See \code{\link{parameters}} for a full list of
#'   valid values and definitions.  If downloading \dQuote{CLIMATOLOGY} a
#'   maximum of three \code{pars} can be specified at one time, for
#'   \dQuote{DAILY} and \dQuote{INTERANNUAL} a maximum of 20 can be specified at
#'   one time.
#' @param temporal_average Temporal average for data being queried, supported
#'   values are \dQuote{DAILY}, \dQuote{INTERANNUAL} and \dQuote{CLIMATOLOGY}.
#'   See argument details for more.
#' @param lonlat A numeric vector of geographic coordinates for a cell or region
#'   entered as x, y coordinates.  Not used when \code{temporal_average} is set
#'   to \dQuote{CLIMATOLOGY}.  See argument details for more.
#' @param dates A character vector of start and end dates in that order,\cr
#'   \emph{e.g.}, \code{dates = c("1983-01-01", "2017-12-31")}.
#'   Not used when\cr \code{temporal_average} is set to \dQuote{CLIMATOLOGY}.
#'   See argument details for more.
#'
#' @section Argument details for \dQuote{community}: There are three valid
#'   values, one must be supplied. This  will affect the units of the parameter
#'   and the temporal display of time series data.
#'
#' \describe{
#'   \item{AG}{Provides access to the Agroclimatology Archive, which
#'  contains industry-friendly parameters formatted for input to crop models.}
#'
#'  \item{SB}{Provides access to the Sustainable Buildings Archive, which
#'  contains industry-friendly parameters for the buildings community to include
#'  parameters in multi-year monthly averages.}
#'
#'  \item{SSE}{Provides access to the Renewable Energy Archive, which contains
#'  parameters specifically tailored to assist in the design of solar and wind
#'  powered renewable energy systems.}
#'  }
#'
#' @section Argument details for \code{temporal_average}: There are three valid
#'  values.
#'  \describe{
#'   \item{DAILY}{The daily average of \code{pars} by day, month and year.}
#'   \item{INTERANNUAL}{The monthly average of \code{pars} by year.}
#'   \item{CLIMATOLOGY}{The monthly average of \code{pars} at the surface of the
#'    earth for a given month, averaged for that month over the 30-year period
#'     (Jan. 1984 - Dec. 2013).}
#'  }
#'
#' @section Argument details for \code{lonlat}:
#' \describe{
#'  \item{For a single point}{To get a specific cell, 1/2 x 1/2 degree, supply a
#'  length-two numeric vector giving the decimal degree longitude and latitude
#'  in that order for data to download,\cr
#'  \emph{e.g.}, \code{lonlat = c(-89.5, -179.5)}.}
#'
#'  \item{For regional coverage}{To get a region, supply a length-four numeric
#'  vector as lower left (lon, lat) and upper right (lon, lat) coordinates,
#'  \emph{e.g.}, \code{lonlat = c(xmin, ymin, xmax, ymax)} in that order for a
#'  given region, \emph{e.g.}, a bounding box for the southwestern corner of
#'  Australia: \code{lonlat = c(112.5, -55.5, 115.5, -50.5)}. *Maximum area
#'  processed is 4.5 x 4.5 degrees (100 points).}
#' }
#'
#' @section Argument details for \code{dates}: If one date only is provided, it
#'   will be treated as both the start date and the end date and only a single
#'   day's values will be returned, \emph{e.g.}, \code{dates = "1983-01-01"}.
#'   When \code{temporal_average} is set to \dQuote{INTERANNUAL}, use only two
#'   year values (YYYY), \emph{e.g.} \code{dates = c(1983, 2010)}.  This
#'   argument should not be used when \code{temporal_average} is set to
#'   \dQuote{CLIMATOLOGY}.
#'
#' @note The associated metadata are not saved if the data are exported to a
#'   file format other than a native \R data format, \emph{e.g.}, .Rdata, .rda
#'   or .rds.
#'
#' @return A data frame of \acronym{POWER} data including location, dates (not
#' including \dQuote{CLIMATOLOGY}) and requested parameters. A header of
#' metadata is included.
#'
#' @references
#' \url{https://power.larc.nasa.gov/documents/POWER_Data_v8_methodology.pdf}
#' \url{https://power.larc.nasa.gov}
#'
#' @examples
#' \donttest{
#' # Fetch daily "AG" community temperature, relative
#' # humidity and precipitation for January 1 1985
#' # for Kingsthorpe, Queensland, Australia
#' ag_d <- get_power(
#'    community = "AG",
#'    lonlat = c(151.81, -27.48),
#'    pars = c("RH2M", "T2M", "PRECTOT"),
#'    dates = "1985-01-01",
#'    temporal_average = "DAILY"
#' )
#'
#' ag_d
#'
#' # Fetch global AG climatology for temperature
#' ag_c <- get_power(community = "AG",
#'    pars = "T2M",
#'    temporal_average = "CLIMATOLOGY")
#'
#' ag_c
#'
#' # Fetch interannual solar cooking parameters
#' # for a given region
#' sse_i <- get_power(
#'   community = "SSE",
#'   lonlat = c(112.5, -55.5, 115.5, -50.5),
#'   dates = c("1984", "1985"),
#'   temporal_average = "INTERANNUAL",
#'   pars = c("CLRSKY_SFC_SW_DWN", "ALLSKY_SFC_SW_DWN")
#' )
#'
#' sse_i
#'
#' }
#'
#' @author Sparks, A. H. \email{adamhsparks@@gmail.com}
#'
#' @export
get_power <- function(community,
                      pars,
                      temporal_average,
                      lonlat = NULL,
                      dates = NULL) {
  if (is.character(temporal_average)) {
    temporal_average <- toupper(temporal_average)
  }
  if (temporal_average %notin% c("DAILY", "INTERANNUAL", "CLIMATOLOGY")) {
    stop(
      call. = FALSE,
      "\nYou have entered an invalid value for `temporal_average`.\n"
    )
  }
  if (temporal_average == "CLIMATOLOGY") {
    dates <- NULL
  }
  if (is.character(pars)) {
    pars <- toupper(pars)
  }
  if (is.character(community)) {
    community <- toupper(community)
  }

  # user input checks and formatting -------------------------------------------
  # see internal_functions.R for these functions

  .check_community(community, pars)

  dates <- .check_dates(
    dates,
    lonlat,
    temporal_average
  )
  pars <- .check_pars(
    pars,
    temporal_average,
    lonlat
  )
  lonlat_identifier <- .check_lonlat(
    lonlat,
    pars,
    temporal_average
  )

  # submit query ---------------------------------------------------------------
  # see internal_functions.R for this function
  NASA <- .power_query(community,
    lonlat_identifier,
    pars,
    dates,
    outputList = "CSV"
  )
}
