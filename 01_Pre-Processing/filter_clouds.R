###--------------------------------------------------------------------------###
#                         PLANET CLOUD FILTER                                  #
###--------------------------------------------------------------------------###

## create a csv file that lists all cloud free planet tiles

## author: Svenja Dobelmann
## date: April 2023

## download the package 
#install.packages("rjson")

## load libraries 
library(rjson)
library(stringr)

## set working directory to directory of your files 
setwd(".../InCubed/02_SatelliteData/01_PlanetData")

## Enter your cloud cover threshold [0,1] here! 
cloud_treshold <- 0.05

## list all metadata files (.json) within directory 
files <- list.files(recursive = T, pattern = ".json", full.names = F)

## loop over files list and check if threshold is reached 

remove(cloud_free)

for (i in 1:length(files)){
  json <- fromJSON(file = files[i]) # load json file as a list 
  current_path <- paste0(str_sub(files[i], end = -14),"3B_AnalyticMS_SR_8b_harmonized_clip.tif") # path of current .tif file 
  
  if (json$properties$cloud_cover <= cloud_treshold && 
      json$properties$clear_confidence_percent >= 80){ # check for thresholds 
    
    ## if so, extract values from list 
    count <- data.frame("path" = current_path, "ID" = json$id,"acquired" = json$properties$acquired,
                        "cloud_cover" = json$properties$cloud_cover, "clear_conf_prec" = json$properties$clear_confidence_percent)
    
    if (exists("cloud_free") == F){ # for the first run we create a cloud_free data frame 
      cloud_free <- count}
    else {
      cloud_free <- rbind(cloud_free,count)} # for the following runs we combine the data frame 
  }
}


## save results as csv in your working directory 
write.csv(cloud_free,paste0("/Planet_Tiles_cloudless", cloud_treshold, ".csv"), row.names = F)
