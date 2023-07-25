###--------------------------------------------------------------------------###
#                         AWS - DATA DOWNLOAD                                  #
###--------------------------------------------------------------------------###

## download Planet tiles from Amazon Web Server using the paws package 

## author: Svenja Dobelmann
## date: April 2023

## download the packages 
#install.packages("paws","stringr")

## load libraries 
library(paws)
library(stringr)

## enter your credentials here! 
### (you need to be authorized for downloading the required bucket!) 

Sys.setenv(
  AWS_ACCESS_KEY_ID = "YOUR_ACCESS_KEY_ID",
  AWS_SECRET_ACCESS_KEY = "YOUR_SECRET_ACCESS_KEY",
  AWS_REGION = "eu-central-1"
)

## create a client 
s3 <- paws::s3()

## The list_objects function is limited to max 1000 Keys! In order to download more
## files, we will use a while loop to repeat the process until the key of the last
## image is reached.

## enter Bucket and Folder name here! 
Bucket <- "supervision-planetscope-archive"
Folder <- "ent/ent_010"

## using first image as marker for the first run. Enter name here! 
Marker <-  "ent/ent_010/20200730_093526_67_2212/20200730_093526_67_2212_3B_AnalyticMS_8b_metadata_clip.xml" # example key

## last key to end the while loop. Enter name here! 
lastKey <- "ent/ent_010/20230410_093330_59_24be/20230410_093330_59_24be_metadata.json" # example key 


#### List files  ###############################################################

remove(files_list, objects, contents)

## listing all files within current folder
while( Marker != lastKey){ # loop until last key is reached
  objects <- s3$list_objects(Bucket = Bucket,
                           MaxKeys = 1000,
                           Prefix = Folder, 
                           Marker = Marker)
  contents <- objects$Contents
  # extract keys from all the objects 
  for (i in 1:length(contents)){
    if(exists("files_list") == F){ # for the first run we create a files_list 
      files_list <- contents[i][[1]][1]
    }
    else { # for the following runs we combine the files_list 
      files_list <-  c(files_list,contents[i][[1]][1])}}
## set marker for the next run     
Marker <-  files_list[length(files_list)] 
}


#### download files ############################################################  

## Enter directory where you want to save the files!
dir <- "C:/"

if (file.exists(paste(dir,Folder, sep = "/"))) { # check if directory exists 
  cat("The folder already exists")
} else {
  dir.create(paste0(dir,Folder), recursive = T)} # if not create one 

## loop over files list and download the files 
for (i in 1:length(files_list)){
  pos <- unlist(str_locate_all(pattern =str_extract(files_list[i],"[0-9]{8}"),files_list[i]))[2]   # find position where file name begins 
  name <- substr(files_list[[i]],pos,nchar(files_list[i])) # extract the name of the files from the list 
  Filename <- paste0(dir,Folder,"/",name) # directory name of current file 
  
  if (file.exists(Filename)){
    print("File already downloaded!")
  }
  else {
  s3$download_file(Bucket = Bucket, 
                   Key = files_list[i],
                   Filename = Filename)}
}
