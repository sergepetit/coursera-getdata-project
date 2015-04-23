ensureDataIsAvailable <- function() {
    #I will download in a folder named "data"
    if(!file.exists("data")) {
        message("Creating data directory")
        dir.create("data")
    }
    
    #if zip is not there, download it
    dataZipFile <- "./data/dataset.zip"
    if(!file.exists(dataZipFile)) {
        fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        message("Downloading to ", dataZipFile, " from [", fileUrl,"]")
        download.file(fileUrl, destfile = dataZipFile, method = "curl")
    }
    
    #if uncompressed data is not there, unzip data
    dataFile <- "./data/UCI HAR Dataset"
    if(!file.exists(dataFile)) {
        message("Extracting ", dataZipFile)
        unzip(dataZipFile, exdir="./data")
    }
}

mergeTrainingAndTestSets <- function() {
    numeric561 <- rep.int("numeric", 561)
    
    trainingSet <- read.table("./data//UCI HAR Dataset/train/X_train.txt", colClasses = numeric561)
    trainingActivity <- read.table("./data//UCI HAR Dataset/train/y_train.txt",
                                   colClasses = "factor",
                                   col.names ="activity")
    trainingSubject <- read.table("./data/UCI HAR Dataset/train/subject_train.txt",
                                  colClasses= "factor",
                                  col.names = "subject")
    
    testSet <- read.table("./data//UCI HAR Dataset/test/X_test.txt", colClasses = numeric561)
    testActivity <- read.table("./data//UCI HAR Dataset/test/y_test.txt",
                               colClasses = "factor",
                               col.names ="activity")
    testSubject <- read.table("./data/UCI HAR Dataset/test/subject_test.txt",
                              colClasses = "factor",
                              col.names = "subject")
    
    #After reading the 6 files, I combine the 3 training and the 3 test sets by column,
    #and then the 2 resulting sets by row 
    rbind( cbind(trainingSubject, trainingSet, trainingActivity),
           cbind(testSubject, testSet, testActivity))
}

extractMeanAndStd <- function(dataSet) {
    features <- read.table("./data//UCI HAR Dataset/features.txt",
                           colClasses = c("numeric", "character"),
                           col.names = c("num","name"))
    
    #Extracts only the measurements on the mean and standard deviation for each measurement
    #there is discussion on the forum on wether this should include features like tBodyAccJerkMean or only
    #feature with mean() in their name.
    #I choose to include all features with "mean" (plus "std") in their name because they are still means.
    #To select the required columns, I combine the index of the subject column, the numbers from features.txt
    #(I add 1 to fStdMean$num because of the subject column), and the index of the activity column (563)
    fStdMean <- features[grep("std|mean", features$name),]
    t <- dataSet[, c(1, fStdMean$num + 1, 563)]
    
    #Appropriately labels the data set with descriptive variable names.
    #Make syntactically valid names (replace special characters like parenthesis, etc)
    newNames <- make.names(fStdMean$name)
    #remove double dots .. introduced by parenthesis replacement (need to escape the dot)
    newNames <- gsub("\\.\\.", "", newNames)
    #fix features.txt typo :)
    newNames <- gsub("BodyBody", "Body", newNames)
    
    names(t) <- c("subject", newNames, "activity")
    t
}

setActivityNames <- function(dataSet) {
    activities <- read.table("./data//UCI HAR Dataset/activity_labels.txt",
                             colClasses = c("numeric", "character"),
                             col.names = c("num","name"))
    #set activity as a factor with labels from activity_labels.txt
    dataSet$activity <- factor(dataSet$activity, labels = activities$name)
    dataSet
}

meansByActivityAndSubject <- function(dataSet) {
    library(dplyr)
    dataSet %>% 
        group_by(activity, subject) %>%
        summarise_each(funs(mean)) %>%
        arrange(activity, as.numeric(as.character(subject)))
    #subject in dataSet is a factor with values not in the numerical order of its labels,
    #so convert to character first to get a character representation of label,
    #and then convert that to a number.
}

runAnalysis <- function() {
    ensureDataIsAvailable()
    
    #1 Merges the training and the test sets to create one data set.
    fullDataSet <- mergeTrainingAndTestSets() 
    
    #2 Extracts only the measurements on the mean and standard deviation for each measurement.
    #4 Appropriately labels the data set with descriptive variable names. 
    dataSet <- extractMeanAndStd(dataSet = fullDataSet)
    
    #3 Uses descriptive activity names to name the activities in the data set
    dataSet <- setActivityNames(dataSet = dataSet)
    
}

dataSet <- runAnalysis()

#5 From the data set in step 4, creates a second, independent tidy data set with the average of each 
#  variable for each activity and each subject.
averageByActivityAndSubject <- meansByActivityAndSubject(dataSet)
