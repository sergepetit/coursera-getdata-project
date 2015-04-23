##Course project for "Getting and Cleaning Data" on [Coursera](https://class.coursera.org/getdata-013/)

This project provides the following files:

- **README.md** this file
- **data/** (and subfolders) the data from UCI [Human Activity Recognition Using Smartphones](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones) as retrieved from [course servers](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) on 2015-04-23
- **run_analysis.R** the code to analyse the data and produce a summary 
- **CodeBook.md** the description of the variables of the summary

###Usage

Once you source `run_analysis.R` the following happen:

0. `runAnalysis` function is called, launching the analysis
0. `ensureDataIsAvailable` is called, downloading and extracting the data if required (data is already provided)
0. `mergeTrainingAndTestSets` is called, loading and combining the data from the different txt files
0. `extractMeanAndStd` is called to retain only features related to mean and standard deviations of mesurements
0. `setActivityNames` is called to set the labels of the different activities
0. finally, `meansByActivityAndSubject` is called to aggregate the variables by subject and activity, and calculate their means.

At this point you should have in your environment a variable called `dataSet`, corresponding to step 4, and `averageByActivityAndSubject` corresponding to step 5.

