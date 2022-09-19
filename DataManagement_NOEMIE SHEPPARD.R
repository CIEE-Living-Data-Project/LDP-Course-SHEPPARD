### LDP DATA MANAGEMENT COURSE ASSIGNMENT 1 ####
### Author: Noemie Sheppard
### Date: 2022-09-16

## Clean Environment ####
  rm(list = ls())

## Load Packages ####
  
  library(lubridate)
  library(rgdal)
  library(dplyr)

## Read in the relevant parts of the BWG database ####

  # List files in the BWG database
  myfiles <- list.files(path = "BWG database/", pattern = "*.csv", full.names = TRUE)
  myfiles
  
  
  # Import all as separate data frames, remove file path and file extensions (.csv)
  list2env(
    lapply(
      setNames(myfiles, 
               make.names(
                 gsub(".*1_", "", 
                      tools::file_path_sans_ext(myfiles)))), 
      read.csv), 
    envir = .GlobalEnv)

## Make joined dataset to work with ####
  
  # Check structure of the bromeliads data frame
  str(bromeliads) 
  
  # Create a new dataframe called bromeliads_selected
  # include the columns: visit_id, bromeliad_id, species, num_leaf, extended_diameter, 
  # max_water, and total_detritus
  bromeliads_selected <- bromeliads %>%
    select(visit_id, bromeliad_id, species, num_leaf, 
           extended_diameter, max_water, total_detritus)
  
  # Join bromeliads_selected table with the countries column of the datasets table
  bromeliads_selected <- bromeliads_selected %>%
    left_join(., select(visits, visit_id, dataset_id), by = "visit_id") %>%
    left_join(., select(datasets, dataset_id, country), by = "dataset_id")
  
  # Join bromeliads_selected table with the abundance column of the abundance table
  bromeliads_selected <- bromeliads_selected %>%
    left_join(., select(abundance, bromeliad_id, abundance), by = "bromeliad_id")
  
  # Join date and spatial geographic data from visits to bromeliads 
  bromeliad_visits <- visits %>% 
    select(visit_id, date, latitude, longitude) %>% 
    right_join(., bromeliads_selected, by = "visit_id")
  
  # Check it worked
  head(bromeliad_visits)
  
  # remove bromeliads_selected
  rm(bromeliads_selected)

## Change Time to yyy-mm-dd using LUBRIDATE ####

  ## Convert the dates to the right format so we can work with them
  bromeliad_visits$date <- lubridate::as_date(bromeliad_visits$date) # convert to date-time format
  
  # Check it worked
  head(bromeliad_visits)

## Change geographic coordinates RDGAL ####
  
  ## Columns for longitude and latitude
  xy <- bromeliad_visits[c("longitude", "latitude")]
  xy
  
  ## Convert coordinates to "SpatialPoints"
  coordinates(xy) <- c("longitude", "latitude")
  proj4string(xy) <- CRS("+proj=longlat +datum=WGS84")
  xy
  
  # Transform to UTM coordinate system
  xy_utm <- spTransform(xy, CRS("+proj=utm +zone=16 +datum=WGS84"))
  xy_utm
  
  # Reintegrate into bromeliad_visits
  bromeliad_visits$longitude <- xy_utm$longitude
  bromeliad_visits$latitude <- xy_utm$latitude

  # Check it worked
  head(bromeliad_visits)
  
## Export the cleaned data table(s) as CSV files — Hint: write_csv() ####
write.csv(bromeliad_visits, "BWG database/BWG_Cleaned.csv")
