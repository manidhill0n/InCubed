###--------------------------------------------------------------------------###
#                        LAND COVER CLASSIFICATION - TRAIN  MODEL              #
###--------------------------------------------------------------------------###
# supervised classifcation using Random Forest Algorithm
## following this tutorial: https://valentinitnelav.github.io/satellite-image-classification-r/

## author: Svenja Dobelmann
## date: July 2023

#### load libraries ############################################################
library(rgdal)
library(raster)
library(tidyr)
library(caret)
library(randomForest)
library(splitTools)
library(ggplot2)
library(dplyr)
library(parallel)
library(doParallel)
library(reshape2)
library(MLmetrics)

#### Loading the data ##########################################################
## training data

samples <- readOGR(".../InCubed/01_SecondaryData/05_landcover_classes/landcover_classes_new.shp") # within ent_004

# inspect dataset
unique(samples$Class) # classes
unique(samples$Date) #date of aquisition

date <- "20220319" # choosing date in between the two aquisitions for loading satellite data 
j_date <- as.Date("20220319",format = "%Y%m%d")  %>% format("%j") ## convert to julian date format


## satellite data from the same date for training the model  (PLANET DATA)

sat_dir <- "M:/04-Phil/Fernerkundung1/InCubed/02_SatelliteData/01_PlanetData/02_masked/ent/"
ind_dir <- "M:/04-Phil/Fernerkundung1/InCubed/02_SatelliteData/01_PlanetData/03_indices/"

# ent_004
sat_data4 <- list.files(paste0(sat_dir,"ent_004"), pattern = "20220319",full.names=TRUE)[2] %>% brick()# chossing secord file which is Histmatched
ndvi_data4 <- list.files(paste0(ind_dir, "NDVI/ent/ent_004"), pattern =  paste0("2022_",as.character(j_date)) ,full.names=TRUE) %>% brick()
msavi_data4 <- list.files(paste0(ind_dir, "MSAVI/ent/ent_004"), pattern =  paste0("2022_",as.character(j_date)) ,full.names=TRUE) %>% brick()# chossing secord file which is Histmatched
ndsi_data4 <- list.files(paste0(ind_dir, "NDSI/ent/ent_004"), pattern =  paste0("2022_",as.character(j_date)) ,full.names=TRUE)%>% brick()# chossing secord file which is Histmatched
nhfi_data4 <- list.files(paste0(ind_dir, "NHFI/ent/ent_004"), pattern =  paste0("2022_",as.character(j_date)) ,full.names=TRUE) %>% brick()# chossing secord file which is Histmatched

data_04 <- stack(sat_data4,ndvi_data4,msavi_data4,ndsi_data4,nhfi_data4)


# ent_005 (for water class): 
sat_data5 <- list.files(paste0(sat_dir,"ent_005"), pattern = "20220319",full.names=TRUE)[2] %>% brick()# chossing secord file which is Histmatched
ndvi_data5 <- list.files(paste0(ind_dir, "NDVI/ent/ent_005"), pattern =  paste0("2022_",as.character(j_date)) ,full.names=TRUE)%>% brick()# chossing secord file which is Histmatched
msavi_data5 <- list.files(paste0(ind_dir, "MSAVI/ent/ent_005"), pattern =  paste0("2022_",as.character(j_date)) ,full.names=TRUE)%>% brick()# chossing secord file which is Histmatched
ndsi_data5 <- list.files(paste0(ind_dir, "NDSI/ent/ent_005"), pattern =  paste0("2022_",as.character(j_date)) ,full.names=TRUE) %>% brick()# chossing secord file which is Histmatched
nhfi_data5 <- list.files(paste0(ind_dir, "NHFI/ent/ent_005"), pattern =  paste0("2022_",as.character(j_date)) ,full.names=TRUE)%>% brick()# chossing secord file which is Histmatched

data_05 <- stack(sat_data5, ndvi_data5, msavi_data5, ndsi_data5, nhfi_data5)

## mosaic them all together
sat_data <- merge(data_04,data_05)
names(sat_data) <- c(paste0("Band",c(1:nlayers(sat_data5))), "NDVI", "MSAVI", "NDSI", "NHFI")

## visualizatiom
plot(sat_data[[1]])
plot(samples, add = T)


#### extract values from raster ################################################
out = NULL
for (i in (1:length(samples))){
 # i <- 70
  print(paste0("Iteration: ", i))
  class <- samples$Class[i]
  if (class == "built up"){
    class <- "built_up"}
  
  values <- terra::extract(sat_data, samples[i,], df = T)
  values <- cbind(class, values)
  out <- rbind(out, values)
  
}

# convert class to factor and remove NA
#out$class <- factor(out$class) 
out <- na.omit(out)
out <- out[,-2] # remove ID column 
#out$class[out$class == "built up"] <- "build_up"

#### visualize band statistics #################################################
out %>% 
  select(-"class") %>% 
  melt(measure.vars = names(.)) %>% 
  ggplot() +
  geom_histogram(aes(value)) +
  geom_vline(xintercept = 0, color = "gray70") +
  facet_wrap(facets = vars(variable), ncol = 3)




#### split samples into training and testing ###################################
set.seed(3451)
inds <- partition(out$class, p = c(train = 0.9, valid = 0.1))
str(inds)
train_df <- out[inds$train, ]
valid_df <- out[inds$valid, ]



#### create cross-validation folds #############################################
##(splits the data into n random groups)
n_folds <- 10
set.seed(321)
folds <- createFolds(1:nrow(train_df), k = n_folds)
# Set the seed at each resampling iteration. Useful when running CV in parallel.
seeds <- vector(mode = "list", length = n_folds + 1) # +1 for the final model
for(i in 1:n_folds) seeds[[i]] <- sample.int(1000, n_folds)
seeds[n_folds + 1] <- sample.int(1000, 1) # seed for the final model

#### model settings ############################################################
ctrl <- trainControl(summaryFunction = multiClassSummary,
                     method = "cv",
                     number = n_folds,
                     search = "grid",
                     classProbs = TRUE, # not implemented for SVM; will just get a warning
                     savePredictions = TRUE,
                     index = folds,
                     seeds = seeds)

#### train the model ###########################################################
## Register a doParallel cluster, using 3/4 (75%) of total CPU-s
cl <- makeCluster(3/4 * detectCores())
registerDoParallel(cl)

model_rf <- caret::train(class ~ . , method = "rf", data = train_df,
                         importance = TRUE, # passed to randomForest()
                         # run CV process in parallel;
                         # see https://stackoverflow.com/a/44774591/5193830
                         allowParallel = TRUE,
                         tuneGrid = data.frame(mtry = c(2, 3, 4, 5, 8)),
                         trControl = ctrl)

stopCluster(cl); remove(cl) # Unregister the doParallel cluster so that we can use sequential operations

registerDoSEQ()


saveRDS(model_rf, file = "./cache/model_rf_planet_12bands.rds")
# 

#### Model evaluation ##########################################################
plot(model_rf)

cm_rf <- confusionMatrix(data = factor(predict(model_rf, newdata = valid_df)),
                         factor(valid_df$class))
cm_rf

randomForest::varImpPlot(model_rf$finalModel) # Band 8 (NIR) and NHFI show high importance 

predict_rf <- raster::predict(object = sat_data,
                              model = model_rf, type = 'raw')

## visulize results 
colours <- c("orange", "pink", "darkgreen", "gray3", "blue")

plot(predict_rf, col = colours, legend = F)
legend("bottomleft", legend = c("Agriculture", "built_up","Forest","road", "Water"), fill = colours)

