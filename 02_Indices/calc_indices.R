###--------------------------------------------------------------------------###
#                         PLANET ADD INDICES                                   #
###--------------------------------------------------------------------------###

## calculate indices and add as bands for the pre-processed planet data. 

## author: Svenja Dobelmann
## date: April 2023

#### SuperDove bands ###################
##  1. Coastal Blue: 431 - 452 nm     ##
##  2. Blue: 465 – 515 nm             ##
##  3. Green_I: 513 - 549 nm          ##
##  4. Green: 547 – 583 nm            ##
##  5. Yellow: 600 - 620 nm           ##
##  6. Red: 650 – 680 nm              ##
##  7. RedEdge: 697 – 713 nm          ## 
##  8. NIR:  845 – 885 nm             ##
####----------------------------------##

## set name of index that you want to calculate

## load parallel library
library(terra)
library(stringr)

## set working directory to directory of planet files 
setwd(".../InCubed/02_SatelliteData/01_PlanetData/02_masked")


## set output directory
outdir <- ".../InCubed/02_SatelliteData/01_PlanetData/03_indices"


## list all tiff files within directory
files <- list.files(recursive = T, pattern = "masked.tif$", full.names = F)

#files <- files[grepl("ent/", files)] # only ent
#files <- files[grepl("ter/", files)] # only ent


#### function to calculate indices ############################################# 

add_indices <- function(list, index){
  
  ## extract date as julian day 
  year <- str_extract(list,"[0-9]{4}")
  day <- str_extract(list,"[0-9]{8}") %>% 
    as.Date(format = "%Y%m%d")  %>%
    format("%j")
  ID <- str_sub(list,start = 29, end = 30)
  
  ## file name
  filename <- paste(year,day,ID,"Planet",index, sep = "_")
  
  ## folder name 
  folder <- str_sub(list, end = 12) # extract the folder name from the path 
  outdir <- paste(outdir,index,folder, sep= "/")
  
  if (file.exists(outdir, recursive = T)) { # check if directory exists 
    cat("The folder already exists")
  } else {
    dir.create(folder, recursive = T)} # if not create one 
  
  if (file.exists(paste0(filename), recursive = T)) { # check if file exists 
    cat("The file already exists")
    
  } else { # if not read the raster file 
    
    r <- terra::rast(list) # load raster file
    names(r) <- c("CB","B","Gi","G","Y","R","RE","NIR") # rename bands 
    
    #### indices ###############################################################
    
    stopifnot(index %in% c("NDVI","SAVI","MSAVI","NDSI","NHFI"))
    
    if (index == "NDVI"){
      ## normalized difference vegetation index
      ind <- (r$NIR - r$R) / (r$NIR + r$R)
    }
    else if (index == "SAVI"){
      ## SAVI
      L <- 0.5 # L = 0,5 (between -0,9 and 1,6) 
      ind <- (r$NIR - r$R) / (r$NIR + r$R + L) * (1+L)
    }
    else if (index == "MSAVI"){
      
      ## Modified Soil Adjusted Vegetation Index (MSAVI)
      ind <- (2*r$NIR + 1 - sqrt((2*r$NIR + 1)^2 - 8*(r$NIR - r$R))) / 2  
    }
    else if (index == "NDSI"){
      ## Normalized difference soil index (NDSI)
      ind <- (r$G - r$Y) / (r$G + r$Y)
      
    }
    else if (index == "NHFI"){
      ## Non-homogeneous feature index
      ind <- (r$RE - r$CB) / (r$RE + r$CB) 
      
    }
    else {cat("index not available!")}
    
    
    ## rename raster band 
    names(ind) <- index
    ## save results ############################################################
    
    
    # if (file.exists(outdir, recursive = T)) { # check if directory exists
    #   
    # } else {
    #   dir.create(outdir, recursive = T)} # if not create one
    
    ## write to raster tiff
    terra::writeRaster(ind,paste0(outdir,filename,".tif"), overwrite = T)  # write to .tif file 
  }
  
}

#### apply function ############################################################

# AVAILABLE INDICES:  "NDVI","SAVI","MSAVI","NDSI","NHFD"


# ## normal lapply function
# system.time(
#   lapply(files, add_indices, index = "NHFD")
# )


## OR: parLapply function using all cores (for large datasets)
library(parallel)

numCores <- detectCores()
numCores

## starting a cluster
cluster <- makeCluster(numCores, type = "PSOCK")

clusterExport(cluster, c("files","outdir"))
clusterEvalQ(cluster, c(files,outdir))

clusterEvalQ(cluster, {
  library(terra)
  library(stringr)
})

## parLapply 

system.time(
  r_indices <- parLapply(cl = cluster, X = files, fun =  add_indices, index = "NDVI") # ENTER INDEX HERE! 
)

stopCluster(cluster)

##########################################