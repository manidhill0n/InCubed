###--------------------------------------------------------------------------###
#                        TIME SERIES ANALYSIS - BUFFER                         #
###--------------------------------------------------------------------------###

## extract point values from Planet vegetation indices with buffer and visualize them 

## author: Svenja Dobelmann
## date: June 2023

## Load libraries 
library(rsq)
library(raster)
library(rgdal)
library(maptools)
library(plyr)
library(ggthemes)
library(sf)
library(xlsx)
library(gtools)
library(stringr)
library(rlist)



## set up directories ###########################################################
index <- "MSAVI" # one of: NDVI, MSAVI, NDSI, NHFI
outpath <- paste0(".../InCubed/02_SatelliteData/01_PlanetData/03_indices/", index,"/ent/")


## read construction data (+ buffer)
constr <- readOGR(".../InCubed/01_SecondaryData/02_Construction_Sites/01_Validation_data_Kuhle/Validation/Validation","ValidationDataInCubed_buffer50",encoding="UTF-8")

## list with all the subsections 
subsections <- c("ent_001","ent_002","ent_003","ent_004","ent_005","ent_006","ent_007","ent_008","ent_009","ent_010")

################################################################################

out_table <- NULL

## loop through folders for subsections 
system.time(
for (k in 1:length(subsections)){
  #k <- 2
  filepath<-paste0(".../InCubed/02_SatelliteData/01_PlanetData/03_indices/", index,"/ent/", subsections[k])
  filelist <- mixedsort(list.files(path = paste0(filepath), pattern='.tif$', 
                                   all.files=TRUE, full.names=TRUE))
  
  # read first raster
  first_raster<- raster(filelist[1])
  
  # reproject construction points to crs of raster data 
  constr <- spTransform(constr, crs(first_raster))
  
  #extracting the useful coloumns from the shapefile
  constr2<-constr[, (names(constr) %in% c("properti_2","properti_3","subsection"))]
  constr2 <- subset(constr2, subsection == subsections[k]) # filter points by subsection
  
  paste0("number of points in current subsection:", length(constr2))
  
  constr_Prop<-as.data.frame(cbind(constr2$properti_2,constr2$properti_3, constr2$subsection))
  
  constr_list<-constr2$properti_3
  
  
  # create empty vectors to store data later
  constr_Comparison<-list()
  
  constr_LUE_mean <- c()
  constr_LUE_max <- c()
  constr_LUE_min<- c()
  constr_LUE_sd<- c()
  constr_LUE_sum<- c()
  constr_date <-  c()
  constr_ID <-  c()
  subsection <- c()

  
  
  ## loop through files-list 
  for (i in 1: length(filelist)){
    #i<-1
    # read current raster file 
    current_raster<- raster(filelist[i])
    
    ## extract date from file name  (DOY format)
    date <- str_extract(filelist[i],"[0-9]{4}_[0-9]{3}")
    #names(current_raster) <- date
    
    ## loop through construction points 
    for (j in 1:length(constr_list)){
      #j<- 2
      # filter current construction point 
      current_constr = subset(constr2,properti_3 == constr_list[j])
      
      #current_constr_data <- crop(current_raster, extent(current_constr))
      #current_constr_data<-mask(current_constr_data,current_constr)
      
      # mask raster by construction area
      current_constr_data<-mask(current_raster,current_constr)
      
      ## visualize current raster
      #plot(current_constr_data,main=paste0(constr_list[j]))
      #plot(current_constr,add=TRUE)
      
      ## extract values from raster
      out <- raster::extract(current_constr_data,SpatialPolygons(current_constr@polygons),na.rm=TRUE)
      ## convert to data frame
      a<-as.data.frame(out)
      a<-a[complete.cases(a), ] # remove  NA values 
      
      ## calculate statistics from raster values 
      meanNDVI<-(mean(a))
      maxNDVI<-(max(a))
      minNDVI<-(min(a))
      sdNDVI<-(sd(a))
      sumNDVI<-sum(a)
      ## bind values of each construction point 
      constr_LUE_mean[j]<-meanNDVI
      constr_LUE_max[j]<-maxNDVI
      constr_LUE_min[j]<-minNDVI
      constr_LUE_sd[j]<-sdNDVI
      constr_LUE_sum[j]<-sumNDVI
      constr_date[j] <- current_constr$properti_2
      constr_ID[j] <- current_constr$properti_3
      subsection[j] <- current_constr$subsection
    }
    
    ## bind values of each raster file 
    constr_Comparison[[i]]<-cbind(constr_date,constr_ID,subsection,date,
                                  constr_LUE_mean,constr_LUE_max,constr_LUE_min,constr_LUE_sd,constr_LUE_sum)

    print(paste0("End loop number:",i))
  }
  
  constr_Comparison_1<-list.rbind(constr_Comparison)
  
  out_table <- rbind(out_table,constr_Comparison_1)
  
  print(paste0("End Subsection:",subsections[[k]]))
}


)


out_table$constr_LUE_sum <- round(out_table$constr_LUE_sum)



write.csv(out_table,file= file.path(paste0(outpath),paste0(index, "_ENT_Stat_Const_Points_Planet", ".csv")))
