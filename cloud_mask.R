###--------------------------------------------------------------------------###
#                         PLANET CLOUD MASKING                                 #
###--------------------------------------------------------------------------###

## masking all the remaining clouds from the filtered planet tiles.
## first run script filter_clouds.R! 

## load libraries
library(raster)
library(stringr)

## set working directory to directory of your files 
setwd("M:/")

## read csv file with cloudless images (from filter_clouds.R script)
files_list <- read.csv("Planet_Tiles_cloudless0.05.csv")

#### masking clouds ############################################################ 

## loop through the list files and masked out the clouds 
for (i in 1:nrow(files_list)){
  r <- stack(files_list$path[i]) # stack the raster bands of the current image 
  mask <- stack(paste0(str_sub(files_list$path[i], end = -40),"3B_udm2_clip.tif")) # get current cloud mask 
  mask$cloud[mask$cloud == 1] <-  NA # set cloudy pixel to NA
  
  ## mask the raster
  r_masked <- mask(r,mask = mask$cloud)
  
  ## save results in folder called "masked" 
  folder <- paste0("masked/",str_sub(files_list$path[i], end = 12)) # extract the folder name from the path 
  
  if (file.exists(paste0(getwd(),folder), recursive = T)) { # check if directory exists 
    cat("The folder already exists")
  } else {
    dir.create(folder, recursive = T)} # if not create one 
  
  filename <- paste0(str_sub(files_list$ID[i], end = -5),"3B_AnalyticMS_SR_8b_harmonized_clip_masked.tif") # extract name of file
  
  if (file.exists(paste0(folder,filename), recursive = T)) { # check if file exists 
    cat("The file already exists")
  } else {
    writeRaster(r_masked,paste0(folder,filename))} # write to .tif file 
}
