## UCI HAR Data Analysis Project

## You should create one R script called run_analysis.R that does the following.

## (Merge) Merges the training and the test sets to create one data set.
## (Extract) Extracts only the measurements on the mean and standard deviation for each measurement.
## (Rename) Uses descriptive activity names to name the activities in the data set
## (Label) Appropriately labels the data set with descriptive variable names.
## (Tidy) From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## Download data

if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile="./data/Dataset.zip", method="curl")

## Unzip DataSet to /data directory
unzip(zipfile="./data/Dataset.zip", exdir="./data")

## Load required packages
library(dplyr)
library(data.table)
library(tidyr)

## Useful UCI HAR datasets for this project
##  Subject variable values are stored in the following files:
##      test/subject_test.txt
##      train/subject_train.txt
##  Feature values are stored in the following files:
##      test/X_test.txt
##      train/X_train.txt
##  Activity variable values are stored in the following files:
##      test/y_test.txt
##      train/y_train.txt
##  Column feature variable names are contiained in the next file listed:
##      features.txt
##  Activity class labels that contain the level of activity variable are saved in the following file:
##      activity_labels.txt


## (Merge) Read in above datafiles

## Read in training data
x_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

## Read in testing data
x_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

## Read in the feature vector
features <- read.table('./data/UCI HAR Dataset/features.txt')

## Read in activity classes
activityLabels = read.table('./data/UCI HAR Dataset/activity_labels.txt')

## Rename column names 
colnames(x_train) <- features[,2] 
colnames(y_train) <-"activityId"
colnames(subject_train) <- "subjectId"
      
colnames(x_test) <- features[,2] 
colnames(y_test) <- "activityId"
colnames(subject_test) <- "subjectId"
      
colnames(activityLabels) <- c('activityId','activityType')

## Merge all data together into one dataset
mrg_train <- cbind(y_train, subject_train, x_train)
mrg_test <- cbind(y_test, subject_test, x_test)
setAllInOne <- rbind(mrg_train, mrg_test)

## Take time to explore new dataset
str(setAllInOne)

## (Extract) the measurements on the mean and standard deviation for each measurement

## Read column names
colNames <- colnames(setAllInOne)

## Create vector for defining ID, mean and standard deviation
mean_and_std <- (grepl("activityId" , colNames) | 
                 grepl("subjectId" , colNames) | 
                 grepl("mean.." , colNames) | 
                 grepl("std.." , colNames) 
                 )

str(mean_and_std)

## Create subset from setAllInOne
setForMeanAndStd <- setAllInOne[ , mean_and_std == TRUE]

## (Rename) Use descriptive activity names to name the activities in the data set
setWithActivityNames <- merge(setForMeanAndStd, activityLabels,
                              by='activityId',
                              all.x=TRUE)
## Check dataframe structure
head(setWithActivityNames$activityId, 30)

## (Label) the data set with descriptive variable names
##      prefix t is replaced by time
##      Acc is replaced by Accelerometer
##      Gyro is replaced by Gyroscope
##      prefix f is replaced by frequency
##      Mag is replaced by Magnitude
##      BodyBody is replaced by Body

names(setWithActivityNames)<-gsub("^t", "time", names(setWithActivityNames))
names(setWithActivityNames)<-gsub("^f", "frequency", names(setWithActivityNames))
names(setWithActivityNames)<-gsub("Acc", "Accelerometer", names(setWithActivityNames))
names(setWithActivityNames)<-gsub("Gyro", "Gyroscope", names(setWithActivityNames))
names(setWithActivityNames)<-gsub("Mag", "Magnitude", names(setWithActivityNames))
names(setWithActivityNames)<-gsub("BodyBody", "Body", names(setWithActivityNames))

## Check labels
names(setWithActivityNames)

## (Tidy) Create tidy dataset with the average of each variable for each activity and each subject

## Create second tidy dataset
secTidySet <- aggregate(. ~subjectId + activityId, setWithActivityNames, mean)
secTidySet <- secTidySet[order(secTidySet$subjectId, secTidySet$activityId), ]

## Write second tidy dataset in text file
write.table(secTidySet, file = "secTidySet.txt", row.name=FALSE)
