# Author: Robert Carroll

library(plyr)
library(reshape2)

DownloadHAR <- function() {

    if(!file.exists("har_data.zip")){
        
        download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                      "har_data.zip",
                      "curl")
        date.downloaded <- date()
        file.create("date_downloaded.txt")
        write(date.downloaded, "date_downloaded.txt")
    }

    unzip("har_data.zip")
}

PrepareX <- function(test.only=FALSE){
    # Use test.only boolean to indicate that only the test data should be analyzed
    
    # Read X data files and merge them
    x.test <- read.fwf("UCI HAR Dataset/test/X_test.txt",list(rep(16,561)),buffersize=50)
    if (test.only){
        cat("X Test Only")
        x <- x.test
    } else {
        cat("X Test and Train")
        x.train <- read.fwf("UCI HAR Dataset/train/X_train.txt",list(rep(16,561)),buffersize=50)    
        x <- rbind(x.test,x.train)
    }
    # Get the feature names from the provided file and prepare them for use
    # as the column names for the x data frame
    features <- read.csv("UCI HAR Dataset/features.txt",sep=" ", header=FALSE)

    # select mean and std dev features, excluding meanFreq features
    mean.or.std <- regexpr("mean\\(\\)|std\\(\\)",features[,2])
    bool.mean.or.std <- mean.or.std > 0
    
    # Separate column numbers and column names
    colnums <- features[bool.mean.or.std,1]
    colnames <- as.character(features[bool.mean.or.std,2])

    # Remove BodyBody typos and change dashes to underscores
    colnames <- gsub(pattern = "BodyBody", replacement = "Body", x = colnames)
    colnames <- gsub(pattern = "-", replacement = ".", x = colnames)
    
    # select the mean and std columns from the x data and name the columns
    x.sub <- x[,colnums]
    colnames(x.sub) <- colnames
    x.sub
}

PrepareY <- function(test.only=FALSE) {
    # Use test.only boolean to indicate that only the test data should be analyzed
    
    # Read the Y data files and merge them
    y.test <- read.csv("UCI HAR Dataset/test/y_test.txt",header=FALSE)
    if (test.only){
        cat("Y Test Only")
        y <- y.test
    } else {
        cat("Y Test and Train")
        y.train <- read.csv("UCI HAR Dataset/train/y_train.txt",header=FALSE)
        y <- rbind(y,y.train)
    }
    activity.labels <- read.csv("UCI HAR Dataset/activity_labels.txt", sep=" ",header=FALSE)
    
    # Join y data frame and activity label data frame
    # use join function to preserve order
    y.readable <- join(y, activity.labels)
    colnames(y.readable) <- c("num", "Activity")
    y.readable
}

PrepareSubject <- function(test.only=FALSE) {
    # Read and merge the subject data sets
    
    subject.test <- read.csv("UCI HAR Dataset/test/subject_test.txt", header=FALSE)
    
    if (test.only){
        cat("Subject Test Only")
        subject <- subject.test
    } else {
        cat("Subject Test and Train")
        subject.train <- read.csv("UCI HAR Dataset/train/subject_train.txt", header=FALSE)
        subject <- rbind(subject.test,subject.train)
    }
    colnames(subject) <- "Subject"
    
    subject
}

ProcessHAR <- function(test.only = FALSE) {
    # Use test.only boolean to indicate that only the test data should be analyzed
    
    DownloadHAR()
    x.sub <- PrepareX(test.only)
    y.readable <- PrepareY(test.only)
    
    # Add readable activity column to the feature vector
    xy <- cbind(y.readable[2], x.sub)

    subject <- PrepareSubject(test.only)

    # Add the subject column to the complete data set
    xysubject <- cbind(subject,xy)
    
    # Summarize data
    melted.xysubject <- melt(xysubject,
                             id.vars = c("Subject","Activity"),
                             variable.name = "Feature",
                             value.name = "Value")
    melted.xysubject$Value <- as.numeric(melted.xysubject$Value)
    
    # Generate summary grouping by Subject, Activity, and Feature, and calculate
    # the mean the values in that group
    summary <- ddply(melted.xysubject,
                     .(Subject, Activity, Feature),
                     summarize,
                     MeanValue = mean(Value))
    
    # Write the data frames to files
    write.csv(xysubject,"UCI_HAR_clean.csv", row.names = FALSE)
    write.csv(summary,"UCI_HAR_summary.csv", row.names = FALSE)
    xysubject
}
