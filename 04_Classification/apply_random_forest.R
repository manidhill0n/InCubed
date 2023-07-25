###--------------------------------------------------------------------------###
#                        LAND COVER CLASSIFICATION - PREDICT                   #
###--------------------------------------------------------------------------###
# apply Random Forest Model (model_rf_planet_12bands.rds) on all data 

## author: Svenja Dobelmann
## date: July 2023

library(stringr)
library(stringi)
library(raster)


# we need all 8 Planet bands plus the 4 indices for the classification 

out_dir <-  ".../InCubed/02_SatelliteData/01_PlanetData/04_Landcover/"

sat_dir <- ".../InCubed/02_SatelliteData/01_PlanetData/02_masked/"
ind_dir <- ".../InCubed/02_SatelliteData/01_PlanetData/03_indices/"

sat_files_ent <- list.files(paste0(sat_dir,"ent/"), pattern = ".tif$", full.names=TRUE, recursive = T)
sat_files_ter <- list.files(paste0(sat_dir,"ter/"), pattern = ".tif$", full.names=TRUE, recursive = T)
sat_files <- c(sat_files_ent,sat_files_ter)
ndvi_files <- list.files(paste0(ind_dir, "NDVI"), pattern = "NDVI.tif$", full.names=TRUE, recursive = T)
msavi_files <- list.files(paste0(ind_dir, "MSAVI"), pattern = "MSAVI.tif$", full.names=TRUE, recursive = T)
ndsi_files <- list.files(paste0(ind_dir, "NDSI"), pattern = "NDSI.tif$", full.names=TRUE, recursive = T)
nhfi_files <- list.files(paste0(ind_dir, "NHFI"), pattern = "NHFI.tif$", full.names=TRUE, recursive = T)
ind_files <- c(ndvi_files,msavi_files,ndsi_files,nhfi_files)


## load random-forest model 
model_rf <- readRDS(".../InCubed/03_Methods/02_Rscripts/cache/model_rf_planet_12bands.rds")

list <- NULL
ind <- NULL
model <- NULL
  
## function for calculating land cover
calc_LC <- function(list,ind, model){
  ## extract date from filename as DOY 
  folder <- str_sub(list, start = 76, end = 87)

  year <- str_extract(list,"[0-9]{4}")
  day <- str_extract(list,"[0-9]{8}") %>% 
    as.Date(format = "%Y%m%d")  %>%
    format("%j")
  ## extract ID from filename 
  ID <-  stringi::stri_extract_last(list,regex = "_[0-9]{2}_")
  
  ## paste Date and ID for extracting Indice data
  filename <- paste0(folder, year,"_",day,ID,"Planet_LC.tif")
  
  if (file.exists(paste0(filename), recursive = T)) { # check if file exists 
    cat("The file already exists")
    
  } else { # if not read the raster file 
  
  ## grep corresponding Indicices for current file 
  r_ndvi <- ind[grepl(paste0(folder, year,"_",day,ID,"Planet_NDVI"), ind)] 
  r_msavi <- ind[grepl(paste0(folder,year,"_",day,ID,"Planet_MSAVI"), ind)]
  r_ndsi <- ind[grepl(paste0(folder,year,"_",day,ID,"Planet_NDSI"), ind)] 
  r_nhfi <- ind[grepl(paste0(folder,year,"_",day,ID,"Planet_NHFI"), ind)] 
  
  if(length(r_ndvi) == 0 | length(r_msavi) == 0 | length(r_ndsi) == 0 | length(r_nhfi) == 0){
    print("file doesnt exist")
  }
  else {
  raster <- stack(list,r_ndvi,r_msavi,r_ndsi,r_nhfi)
  names(raster) <- c(paste0("Band",c(1:8)), "NDVI", "MSAVI", "NDSI", "NHFI")
  
  LC <- raster::predict(object = raster, model = model, type = 'raw')

  terra::writeRaster(LC,paste0(out_dir,filename), overwrite = T)}}  # write to .tif file 
}


## apply function
#lapply(sat_files, FUN = calc_LC, ind = ind_files, model = model_rf)

##  OR: parallel processing instead (using all cores)
library(parallel)

numCores <- detectCores()
numCores
 
## starting a cluster
cluster <- makeCluster(numCores, type = "PSOCK")

clusterExport(cluster, c("sat_files","ind_files","out_dir", "model_rf"))
clusterEvalQ(cluster,  c(sat_files,ind_files,out_dir, model_rf))

clusterEvalQ(cluster, {
  library(stringi)
  library(raster)
  library(stringr)
})

## parLapply 

system.time(
  r_indices <- parLapply(cl = cluster, X = sat_files, fun =  calc_LC, ind = ind_files, model = model_rf) 
)

stopCluster(cluster)

##########################################