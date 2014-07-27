Getting and Cleaning Data: Course Project
=========================================

ND 2014-07-27

## Source Data

The [raw data](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)
was provided as a .zip file containing a number of subdirectories and 
plain text files. A detailed description of the data is provided by the `README.txt`
and `features_info.txt` files. 

The raw data was partitioned into training and test datasets. These datasets contain
respectively 7352 and 2947 records. Within each dataset there are three text files 
prefixed **y_**, **X_** and **subject_**. These files contain the following data:

* **y_** - each row contains a single value, corresponding to the activity codes listed in activity_labels.txt
* **X_** - each row contains 561 values, corresponding to the feature codes listed in features.txt
* **subject_** - each row of contains a subject ID in the range from 0 to 30

Each dataset also includes an Inertial Signals subdirectory that contains nine files,
in which each row contains a vector of 128 values.

## Processing Script

The following steps describe the operation of the script [`run_analysis.R`](run_analysis.R), used to merge, tidy
and summarise the raw data.

1. The script loads the activity, feature and subject data from each of the two datasets.
Since the training and test datasets do not overlap it is possible to combine them by
row using `rbind` on each of the three pairs.

2. Since each row in the subjects, x and y files corresponds to the same observation it
is possible to combine data from the three files into a single dataframe using `cbind`.

3. The script then loads the feature labels and converts them into valid descriptive names
for the feature data columns.

4. Since only mean and standard deviation data are required the script then creates a new
dataframe containing the subset of relevant columns (matched by `grep`) for further processing.

5. The script loads the descriptive activity labels and merges them into the new dataframe.
As the `merge` function does not preserve the order of original data the `join` function
from the plyr package is used instead.

6. The dataframe is then converted into a data.table (using the data.table package), which
provides a quick way to aggregate multiple columns. A new data table is created with
function data summarised by mean for each subject and activity.

7. The new summary data table is finally saved as the [tidy dataset](tidy.data.csv) in .csv text format 
with Windows style line endings.

## Codebook

The codebook describing the variables is included in a separate file, [`codebook.md`](codebook.md).
