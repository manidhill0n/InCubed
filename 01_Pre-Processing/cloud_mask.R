###--------------------------------------------------------------------------###
#                         PLANET CLOUD MASKING                                 #
###--------------------------------------------------------------------------###

## masking all the remaining clouds from the filtered planet tiles.
## first run script filter_clouds.R! 

## author: Svenja Dobelmann
## date: April 2023

## load libraries
library(raster)
library(stringr)
library(parallel)

## set working directory to directory of your files 
setwd(".../InCubed/02_SatelliteData/01_PlanetData")

## read csv file with cloudless images (from filter_clouds.R script)
files_list <- read.csv("Planet_Tiles_cloudless0.05.csv")
paths <- files_list$path

#paths <- paths[2557:4275] # only ter 
#### masking clouds ############################################################ 

cloud_mask <- function(list){
  ## folder name 
  folder <- paste0("02_masked/",str_sub(list, end = 12)) # extract the folder name from the path 
  
  if (file.exists(folder, recursive = T)) { # check if directory exists 
    cat("The folder already exists")
  } else {
    dir.create(folder, recursive = T)} # if not create one 
  
  ## file name
  filename <- paste0(str_sub(list, start = 13, end = -5),"_masked.tif") # extract name of file
  
  if (file.exists(paste0(folder,filename), recursive = T)) { # check if file exists 
    cat("The file already exists")
  } else { # if not read the raster file 
    
    r <- stack(paste0("01_raw/",list)) # stack the raster bands of the current image 
    mask <- stack(paste0("01_raw/",str_sub(list, end = -40),"3B_udm2_clip.tif")) # get current cloud mask 
    mask$cloud[mask$cloud == 1] <-  NA # set cloudy pixel to NA
    
    ## mask the raster
    r_masked <- mask(r,mask = mask$cloud)
    
    ## save results 
    writeRaster(r_masked,paste0(folder,filename))} # write to .tif file 
}


## apply function
#lapply(paths, cloud_mask)



## parLapply function using all cores

numCores <- detectCores()
numCores <- 15

## starting a cluster
cluster <- makeCluster(numCores, type = "PSOCK")

clusterExport(cluster, "paths")
clusterEvalQ(cluster, paths)

clusterEvalQ(cluster, {
  library(raster)
  library(stringr)
})

## parLapply 

system.time(
  r_indices <- parLapply(cl = cluster, X = paths, fun =  cloud_mask)
)

stopCluster(cluster)

################################################################################