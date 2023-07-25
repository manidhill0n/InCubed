README: AWS_download_img.R 

with this script you can download files from your Amazon Web Server in a batch.
Make sure your amazon account is authorized to download the files and have your AWS_Access_Key_ID and your AWS_SECRET_ACCESS_KEY ready.

1. Enter your AWS credentials and set up a client
2. Enter your required bucket name and the folder you want to download 
3. List all object within the bucket
	Since the 'list_objects()' function is limited to 1000 objects we will repeat the process until we reach the key of the last required object.
	Therefore you need to enter the first ('Marker') and the last object key ('lastKey')
4. Download all the listed files in the directory of your choice 'dir'


---------------------------------------------------------

README: filter_clouds.R

filter all the cloud free scenes from a large amount of planet tiles using the metadata (.json) and store them in a .csv file 

1. Set the directory of your planet data as working directory
2. Set your required cloud threshold between 0 and 1
3. List all your metadata files within directory
4. Loop through the files list and check for the threshold. Tiles that fullfill the threshold will be stored in a data frame called 'cloud_free'
5. Write your results to a .csv file and save them in your working directory


---------------------------------------------------------

README: cloud_mask.R

mask all the remaining cloud pixel from your filtered Planet dataset using Planets cloud mask (3B_udm2_clip.tif)

1. Set the directory of your planet data as working directory
2. Load your list of cloudless planet scenes ('Planet_Tiles_cloudless0.05.csv')
3. Loop through your list of files. Load each file and the corresponding cloud mask and remove all cloudy pixel. Results will be stored in a folder
	called 'masked' within your working directory
