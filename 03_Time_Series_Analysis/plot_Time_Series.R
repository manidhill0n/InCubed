###--------------------------------------------------------------------------###
#                       PLOT - TIME SERIES ANALYSIS - BUFFER                   #
###--------------------------------------------------------------------------###

## visualize point values from Planet vegetation indices with buffer 

## author: Svenja Dobelmann
## date: June 2023

## load libraries
library(dplyr)
library(ggplot2)
library(gridExtra)
library(grid)
library(tidyverse)

#### set up

## set working directory
setwd(".../InCubed/02_SatelliteData/01_PlanetData/03_indices/MSAVI/ent") # set required Index here! 
outdir <- ".../InCubed/04_Results/02_Plots/Time_Series_plots_planet/buffer/"


## import data 
filepath<- list.files(recursive = F, pattern = ".csv$", full.names = F) 
data <- read.csv(filepath, sep = ";")


#### mutate data
unique(data$constr_ID) # see available options 
selected_id <- unique(data$constr_ID)[70] # enter Index Nr. here! 

df <- data %>%
  filter(constr_ID == selected_id) %>% # filter selected constr. ID 
  mutate(date = as.Date(date,format = "%Y_%j")) %>% # convert date format
  mutate(constr_date = as.Date(constr_date)) %>% 
  mutate(mean = as.numeric(constr_LUE_mean)) %>% 
  mutate(max = as.numeric(constr_LUE_max)) %>% 
  mutate(min = as.numeric(constr_LUE_min)) %>% 
  mutate(std = as.numeric(constr_LUE_sd)) %>% 
  mutate(sum = as.numeric(str_sub(constr_LUE_sum, 1,5))) %>%
  filter(!is.infinite(max)) %>% # drop non valid values (+- Inf)
  filter(!is.infinite(min)) #%>% # drop non valid values (+- Inf)

  #select(constr_date, constr_ID, subsection, date, mean, max, min, std, sum) # select only relevant column



#### plot results 

## MEAN 
g_mean <- ggplot(df, aes(x = date, y = mean)) + 
  
  ## adding time series values 
  geom_point( alpha = 0.4, color = "#8ebad0") + 
  geom_line(linewidth= .8, color = "#8ebad0") +
  geom_smooth(method = "loess", color = "#2d596f") +
  
  ## adding construction information
  geom_vline(xintercept = df$constr_date[1], size = 1,color = "#fc8d62") +
  annotate("text", x = mean(c(df$date[1], df$constr_date[1])), y = -0.255, label = "Pre-Construction",color = "#fc8d62") + 
  annotate("rect", xmin = df$date[1] - 5, xmax = df$constr_date[1] - 5 , ymin = -0.32, ymax = -0.2, alpha = .3, fill = "gray") + 
  
  annotate("text", x = mean(c(df$date[length(df$date)], df$constr_date[1])), y = -0.255, label = "Post-Construction",color = "#fc8d62") + 
  annotate("rect", xmin = df$constr_date[1] + 5, xmax = df$date[length(df$date)] + 5 , ymin = -0.32, ymax = -0.2, alpha = .3, fill = "gray") + 
  
  
  ## layout
  ggtitle("Mean Values") +
  ylim(c(-0.32,1.2)) +
  xlab("") + 
  
  theme_minimal() + 
  theme(title = element_text(size = 10))


## MAX
g_max <- ggplot(df, aes(x = date, y = max)) + 
  
  ## adding time series values 
  geom_point( alpha = 0.4, color = "#8ebad0") + 
  geom_line(linewidth= .8, color = "#8ebad0") +
  geom_smooth(method = "loess", color = "#2d596f") +
  
  ## adding construction information
  geom_vline(xintercept = df$constr_date[1], size = 1,color = "#fc8d62") +
  annotate("text", x = mean(c(df$date[1], df$constr_date[1])), y = -0.255, label = "Pre-Construction",color = "#fc8d62") + 
  annotate("rect", xmin = df$date[1] - 5, xmax = df$constr_date[1] - 5 , ymin = -0.32, ymax = -0.2, alpha = .3, fill = "gray") + 
  
  annotate("text", x = mean(c(df$date[length(df$date)], df$constr_date[1])), y = -0.255, label = "Post-Construction",color = "#fc8d62") + 
  annotate("rect", xmin = df$constr_date[1] + 5, xmax = df$date[length(df$date)] + 5 , ymin = -0.32, ymax = -0.2, alpha = .3, fill = "gray") + 
  
  
  ## layout
  ggtitle("Maximum Values") +
  ylim(c(-0.32,1.2)) +
  xlab("") + 
  
  theme_minimal() + 
  theme(title = element_text(size = 10))


## MIN
g_min <- ggplot(df, aes(x = date, y = min)) + 
  
  ## adding time series values 
  geom_point( alpha = 0.4, color = "#8ebad0") + 
  geom_line(linewidth= .8, color = "#8ebad0") +
  geom_smooth(method = "loess", color = "#2d596f") +
  
  ## adding construction information
  geom_vline(xintercept = df$constr_date[1], size = 1,color = "#fc8d62") +
  annotate("text", x = mean(c(df$date[1], df$constr_date[1])), y = -0.66, label = "Pre-Construction",color = "#fc8d62") + 
  annotate("rect", xmin = df$date[1] - 5, xmax = df$constr_date[1] - 5 , ymin = -0.74, ymax = -0.6, alpha = .3, fill = "gray") + 
  
  annotate("text", x = mean(c(df$date[length(df$date)], df$constr_date[1])), y = -0.66, label = "Post-Construction",color = "#fc8d62") + 
  annotate("rect", xmin = df$constr_date[1] + 5, xmax = df$date[length(df$date)] + 5 , ymin = -0.74, ymax = -0.6, alpha = .3, fill = "gray") + 
  
  
  ## layout
  ggtitle("Minimun Values") +
  ylim(c(-0.74,1.2)) +
  xlab("") + 
  
  theme_minimal() +
  theme(title = element_text(size = 10))


g_min


## STD
g_std <- ggplot(df, aes(x = date, y = std)) + 
  
  ## adding time series values 
  geom_point( alpha = 0.4, color = "#8ebad0") + 
  geom_line(linewidth= .8, color = "#8ebad0") +
  geom_smooth(method = "loess", color = "#2d596f") +
  
  ## adding construction information
  geom_vline(xintercept = df$constr_date[1], size = 1,color = "#fc8d62") +
  annotate("text", x = mean(c(df$date[1], df$constr_date[1])), y =  -0.019, label = "Pre-Construction",color = "#fc8d62") + 
  annotate("rect", xmin = df$date[1] - 5, xmax = df$constr_date[1] - 5 , ymin = -0.034, ymax = -0.005, alpha = .3, fill = "gray") + 
  
  annotate("text", x = mean(c(df$date[length(df$date)], df$constr_date[1])), y = -0.019, label = "Post-Construction",color = "#fc8d62") + 
  annotate("rect", xmin = df$constr_date[1] + 5, xmax = df$date[length(df$date)] + 5 , ymin = -0.034, ymax = -0.005, alpha = .3, fill = "gray") + 
  
  
  ## layout
  ggtitle("Standard Deviation") +
  ylim(c(-0.034, 0.5)) +
  xlab("") + 
  
  theme_minimal() + 
  theme(title = element_text(size = 10))


g_std

## SUM    
g_sum <- ggplot(df, aes(x = date, y = sum)) + 
  ## adding time series values 
  geom_bar(stat = "identity", width = 5, fill = "#8ebad0") +
  geom_smooth(method = "loess", color = "#2d596f") + 
  
  ## adding construction information
  ## adding construction information
  geom_vline(xintercept = df$constr_date[1], size = 1,color = "#fc8d62") +
  annotate("text", x = mean(c(df$date[1], df$constr_date[1])), y = -50, label = "Pre-Construction",color = "#fc8d62") + 
  annotate("rect", xmin = df$date[1] - 5, xmax = df$constr_date[1] - 5 , ymin = -100, ymax = -10, alpha = .3, fill = "gray") + 
  
  annotate("text", x = mean(c(df$date[length(df$date)], df$constr_date[1])), y = -50, label = "Post-Construction",color = "#fc8d62") + 
  annotate("rect", xmin = df$constr_date[1] + 5, xmax = df$date[length(df$date)] + 5 , ymin = -100, ymax = -10, alpha = .3, fill = "gray") + 
  
  
  ## layout
  ggtitle("Sum Values") +
  ylim(c(-100,1500)) +
  xlab("") + 
  
  theme_minimal() + 
  theme(title = element_text(size = 10))


g_sum  


## Grid Layout with all plots 
g_all <- grid.arrange(arrangeGrob(g_mean, g_max, g_min, nrow = 3), arrangeGrob(g_std, g_sum, nrow = 2), 
             ncol = 2, 
             top = textGrob(paste0("MSAVI Time Series for construction point: ", selected_id), hjust = 1.2, gp = gpar(fontsize = 20, font = 3)))


## save results 

ggsave(paste("MSAVI_Time_Series_", selected_id, ".png", sep = ""), plot = g_all, path = outdir, dpi = 500, width = 50, height = 30, units = "cm")

