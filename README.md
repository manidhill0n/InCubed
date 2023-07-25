# InCubed
The repository is designed to share the code and material for the InCubed project.  


It contains two parts:  
## 1) Planetscope Data  
Download Planet dataset from the Amazon Web Server (AWS) and Process data using R. The respective steps are:  
    a)  **01_Pre-Processing** including download cloud filter and cloud mask  
    b)  **02_Indices** including calculation of band indices  
    c)  **03_Time_Series_Analysis** including extraction of construction values from the dataset and their visualization    
    d)  **04_Classification** including training a Random Forest model and predicting Land Cover Classification  

### Training Data used for Classification 
  <img src="https://github.com/manidhill0n/InCubed/blob/main/viz/Training_samples.png" alt="Alt text" title="Visualization of training samples for Random Forest">  

  
### Sample Results of Time Series Analysis 
  <img src="https://github.com/manidhill0n/InCubed/blob/main/viz/Time_Series_results.png" alt="Alt text" title="Visualization of Time Series Results">




## 2) Sentinel-2 Data 
Download and preprocess the Sentinel-2 dataset from Google Earth Engine (GEE) using Java script. The respective files are:  
    a) GEEcode_Sentinel-2.txt  
    b) Sample Maps for ENT (Sentinel_2_ENT_NDVI.jpg) and TER (Sentinel_2_TER_NDVI.jpg)  
    
   <img src="https://github.com/manidhill0n/InCubed/blob/main/viz/Sentinel_2_ENT_NDVI.jpg" alt="Alt text" title="NDVI visulaization at different dates using Sentinel-2 (ENT)">
   <img src="https://github.com/manidhill0n/InCubed/blob/main/viz/Sentinel_2_TER_NDVI.jpg" alt="Alt text" title="NDVI visulaization at different dates using Sentinel-2 (TER)">

    
