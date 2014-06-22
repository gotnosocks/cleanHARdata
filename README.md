#README

This script run_analysis processes the HAR dataset to produce a reduced “clean” dataset and a summary dataset. These datasets are saved to the following csv files:

UCI_HAR_clean.csv

UCI_HAR_summary.csv

##Script Details
The script contains 4 functions:

####DownloadHAR()
Downloads the original data zip package and save it as "har_data.zip", creates a file with the date of the download called "date_downloaded.txt", and unzips original data zip package.

####PrepareX(test.only=FALSE)
Read the feature vector data from the feature data files x_test.txt and x_train.txt. If test.only is set to TRUE, then the script will only read teh test data. 

Select only the columns whose name contains "mean()" or "std()". The specification of those two strings will exclude "meanFreq()" features.

Data Modifications

The column names are extracted from the features.txt file and converted by replacing all "-" characters with "." periods. Several feature names contained a duplication "BodyBody" which was replaced with "Body" to match the documented naming convention.The script selects only the columns whose name contains "mean()" or "std()". The specification of those two strings will exclude "meanFreq()" features.

Return

This method returns the reduced X dataset containing ony mean() and std() fields with the column names described above.

####PrepareY(test.only=FALSE)
Read the classfication data from the data files y_test.txt and y_train.txt.
If test.only is set to TRUE, then the script will only read teh test data.
Merge in the human readable names from the activity_labels.txt file. The dat

####PrepareSubject(test.only=FALSE)
Read the classfication data from the data files y_test.txt and y_train.txt.
If test.only is set to TRUE, then the script will only read the test data.

####ProcessHAR(test.only=FALSE)
This function call the other functions in the proper order and passes along the test.only variable to the functions that take an argument.

This method combines the X, Y , and Subject datasets prepared by the other methods, uses the melt function to generate a summary of average values for each feature broken down by Subject and Activity, and writes the combined data set and summary data set to csv files.
