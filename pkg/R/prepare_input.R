#' @title Check and prepare input for running 3-PG model
#' @description Checks and prepares all input tables to be used in \code{\link{run_3PG}}. For detailed descriptions see Forrester (2020).
#'
#' @param site table containing the information about site conditions.
#' \itemize{
#' \item latitude: site latitude in the WGS84 coordinate system.
#' \item altitude: site altitude, m a.s.l.
#' \item soil_class: 1 - Sandy; 2 - Sandy loam; 3 - Clay loam; 4 - Clay; 0 - No effect of asw on production.
#' \item asw_i: initial available soil water (mm).
#' \item asw_min: minimum available soil water (mm).
#' \item asw_max: maximum available soil water (mm).
#' \item from: year and month indicating the start of simulation. Provided in form of year-month. E.g. "2000-01".
#' \item to: year and month indicating the end of simulation. Provided in form of year-month. E.g. "2009-12", will include December 2009 as last simulation month
#' }
#' @param species table containing the information about species level data. Each row corresponds to one species/cohort.
#' \itemize{
#' \item species: species or cohort id/name. It must be consistent with species names in \code{thinning}, \code{parameters} and \code{sizeDist} tables.
#' \item planted: year and month indicating when species was planted. Provided in form of year-month. E.g. "2000-01".
#' \item fertility: soil fertility for a given species. Range from 0 to 1.
#' \item stems_n: number of trees per ha.
#' \item biom_stem: stem biomass for a given species (Mg/ha).
#' \item biom_root: root biomass for a given species (Mg/ha).
#' \item biom_foliage: initial foliage biomass (Mg/ha). If this is a leafless period, provide the spring foliage biomass.
#' }
#' @param climate  table containing the information about monthly values for climatic data. If the climate table has exactly 12 rows it will be replicated for the number of years and months specified by \code{from} - \code{to}. Otherwise, it will be subsetted to the selected time period. More details about preparing climate data are at \code{\link{prepare_climate}}.
#' \itemize{
#' \item year: year of observation (only required for subsetting) (optional).
#' \item month: months of observation (only required for subsetting) (optional).
#' \item tmp_min: monthly mean daily minimum temperature (C).
#' \item tmp_max: monthly mean daily maximum temperature (C).
#' \item tmp_ave: monthly mean daily average temperature (C) (optional).
#' \item prcp: monthly rainfall (mm month-1).
#' \item srad: monthly mean daily solar radiation (MJ m-2 d-1).
#' \item frost_days: frost days per month (d month-1).
#' \item vpd_day: water pressure deficit (mbar) (optional).
#' \item co2: monthly mean atmospheric co2 (ppm), required if calculate_d13c=1 (optional)
#' \item d13catm: monthly mean isotopic composition of air (‰), required if calculate_d13c=1 (optional)
#' }
#' @param thinning table containing the information about thinnings. If there is no thinning, it must be \code{NULL}.
#' \itemize{
#' \item species: species or cohort id/name. It must be consistent with species names in \code{species}, \code{parameters} and \code{sizeDist} tables.
#' \item age: age when thinning is performed.
#' \item stems_n: number of trees remaining after thinning
#' \item foliage: type of thinning (above/below). Default is 1.
#' \item root: type of thinning (above/below). Default is 1.
#' \item stem: type of thinning (above/below). Default is 1.
#' }
#' @param parameters table containing the information about parameters to be modified. Values that are not provided are replaced by defaults.
#' \itemize{
#' \item parameter: name of the parameter, must be consistent in naming with \code{\link{i_parameters}}
#' \item species: each column must correspond to species/cohort id/name, as defined in \code{species} table
#' }
#' @param size_dist table containing the information about size distribution to be modified. Values that are not provided are replaced by defaults.
#' \itemize{
#' \item parameter: name of the parameter, must be consistent in naming with \code{\link{i_sizeDist}}
#' \item species: each column must correspond to species/cohort id/name, as defined in \code{species} table
#' }
#' @param settings a list with settings for the model. Values that are not provided are replaced by defaults.
#' \itemize{
#' \item light_model: `1` - 3-PGpjs (default); `2` - 3-PGmix
#' \item transp_model: `1` - 3-PGpjs (default); `2` - 3-PGmix
#' \item phys_model:  `1` - 3-PGpjs (default); `2` - 3-PGmix
#' \item height_model: `1` - linear (default); `2` - non-linear
#' \item correct_bias: `0` - no (default); `1` - yes
#' \item calculate_d13c: `0` - no (default); `1` - yes
#' }
#'
#' @details This function checks and prepares the input data for the \code{\link{run_3PG}}. The output is a list with 7 tables. Each of them corresponds to the one from input.
#'
#' @seealso \code{\link{run_3PG}}, \code{\link{prepare_parameters}}, \code{\link{prepare_sizeDist}}, \code{\link{prepare_thinning}}, \code{\link{prepare_climate}}, \code{\link{prepare_site}}
#'
#' @return a list with seven tables. Each table corresponds to one of the input tables.
#'
#' @example inst/examples/prepare_input-help.R
#'
#' @references
#' Forrester, D. I., 2020. 3-PG User Manual. Swiss Federal Institute for Forest, Snow and Landscape Research WSL, Birmensdorf, Switzerland. 70 p. Available at the following web site: \url{http://sites.google.com/site/davidforresterssite/home/projects/3PGmix/3pgmixdownload}
#'
#'Sands, P. J., 2010. 3PGpjs user manual. Available at the following web site: \url{https://3pg.sites.olt.ubc.ca/files/2014/04/3PGpjs_UserManual.pdf}
#'
#' @export
#'
prepare_input <- function(
  site,
  species,
  climate,
  thinning = NULL,
  parameters = NULL,
  size_dist = NULL,
  settings = NULL
){

  # Site
  site = prepare_site(site = site)

  # Species
  species = prepare_species(species = species)

  # Settings
  set_def = list(light_model = 1, transp_model = 1, phys_model = 1, height_model = 1, correct_bias = 0, calculate_d13c = 0)
  set_def[names(settings)] <- settings

  # Climate
  if( set_def['calculate_d13c'] == 1 ){
    if( !all( c("co2","d13catm") %in% colnames(climate) ) ){
      stop('Please provide forcing data for co2 and d13catm in climate, if calculate_d13c = 1')
    }
  }

  climate = prepare_climate(climate = climate, from = site$from, to = site$to)

  # Thinning
  thinning = prepare_thinning( thinning = thinning, sp_names = species$species)

  # Parameters
  parameters = prepare_parameters( parameters = parameters, sp_names = species$species)

  # Size distribution
  if( set_def['correct_bias'] == 1 & is.null(size_dist) ){
    stop('Please provide size_dist table or change the setting to size_dist = 0')
  }
  size_dist = prepare_sizeDist( size_dist = size_dist, sp_names = species$species)


  # return the checked output
  out <- list( site = site, species = species, climate = climate, thinning = thinning, parameters = parameters, size_dist = size_dist, settings = set_def)

  return( out )
}
