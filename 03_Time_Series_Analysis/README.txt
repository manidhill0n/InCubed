README: Extract_values_Buffer_Planet.R

running a Time Series Analysis on one of the available Indices using validation data (construction points ent) 

1. enter required Index (one of: NDVI, MSAVI, NDSI, NHFI)
2. set up output path and path to construction data with buffer (ValidationDataInCubed_buffer50.shp)

The script is looping through all subsetctions and list all files within filepath. It then extracts the following metrics
for each construction area (point+ 50m buffer: 
	- mean, max, min, stdev, sum 

the results will be stored in an excel sheet "Index_ENT_Stat_Const_Points_Planet.csv" in the output directory. 

----------------------------------------------------------------------------------------------------------------------------
README: plot_Time_Series.R

script to visualize results of Extract_values_Buffer_Planet.R

1. set up working directory entering the required Index and set output directory 
2. load Time Series Data from .csv file (Index_ENT_Stat_Const_Points_Planet.csv)
3. select one of the construction points that you want to plot (selected_id)
4. mutate data to bring it to right form for plotting
5. make a plot for each metric (mean,max,min,stdev,sum) and arrange them in a grid

the output is a .png file with all 5 metrices plotted over time for the selected construction ID.

