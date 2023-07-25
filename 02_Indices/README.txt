README: calc_indices.R 

with this script you can calculate 5 different band Indices from Planetscope Superdove data (8 band data). 

1. set input and output directory and list all your planetscope files. 
2. run "add_indices" function and choose one the following Indices: 
	- Normalized Difference Vegetation Index
	- Soil Adjusted Vegetation Index
	- Modified Soil Adjusted Vegetation Index
	- Normalized Difference Soil Index
	- Non Homegeneous Feature Index
Option A: apply function using lapply
Option B: apply function using parallel processing (way faster!)

the output will be a one band raster.tiff file stored in the output directory under the provided Index name. 

