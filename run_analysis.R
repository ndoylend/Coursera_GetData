# Load requried packages (described below)
library(plyr)
library(data.table)

# Set working directory to point to the unzipped source data
setwd("~/Work/Projects/Coursera/Getting and Cleaning Data/Data/UCI HAR Dataset")

# Load activity data
y.test <- read.table("test/y_test.txt")
y.train <- read.table("train/y_train.txt")

# Inspect activity data (for checking)
str(y.test)
str(y.train)
table(y.test)
table(y.train)

# Load subject data
subjects.test <- read.table("test/subject_test.txt")
subjects.train <- read.table("train/subject_train.txt")

# Inspect subject data (for checking)
str(subjects.test)
str(subjects.train)
table(subjects.test)
table(subjects.train)

# Load sensor data
x.test <- read.table("test/X_test.txt")
x.train <- read.table("train/X_train.txt")

# Inspect sensor data (for checking)
str(x.test, list.len = 10)
str(x.train, list.len = 10)

# NB: The training and test datasets do not overlap,
# which makes combining the datasets straightforward.

# Combine datasets by row
y.new <- rbind(y.test, y.train)
subjects.new <- rbind(subjects.test, subjects.train)
x.new <- rbind(x.test, x.train)

# Tidy up
rm(y.test, y.train)
rm(subjects.test, subjects.train)
rm(x.test, x.train)

# Assign descriptive column names
names(y.new) <- c("activity.code")
names(subjects.new) <- c("subject")

# NB: Each row in subjects, x and y files corresponds
# to the same observation so combining the files is
# also straightforward.

# Combine the data by column
data <- cbind(y.new, subjects.new, x.new)

# Tidy up
rm(y.new, subjects.new, x.new)

# Load feature labels
features <- read.table("features.txt")

# Assign descriptive column names
names(features) <- c("feature.code", "feature")

# Convert the feature descriptions into valid names
features$feature <- make.names(features$feature)

# Convert ... to . in the feature names (double backslashes 
# must be used to escape the . character)
# See: http://stackoverflow.com/questions/6638072/escaped-periods-in-r-regular-expressions
features$feature <- gsub("\\.\\.\\.", "\\.", features$feature)

# Assign descriptive feature names to data columns V1:V561
names(data)[3:ncol(data)] <- paste(features$feature)

# Create subset of columns 1 to 2 plus any matching mean or standard deviation (std)
data.subset <- data[, c(1:2,grep("mean|std", names(data)))]

# Load activity labels
activity.labels <- read.table("activity_labels.txt")

# Assign descriptive column names
names(activity.labels) <- c("activity.code", "activity")

# Because the column names now match it should be possible to merge the 
# descriptive activity labels into the combined dataset. However the
# merge function does not preserve the order of original data. The plyr
# package provides a join() function, which DOES preserve row order.
# See: http://www.r-statistics.com/2012/01/merging-two-data-frame-objects-while-preserving-the-rows-order/
data.subset <- join(data.subset, activity.labels, by = "activity.code")

# Activity.code colunm is now redundent having merged in descriptive 
# activity labels so it can be removed
data.subset$activity.code <- NULL

# Give the columns a sensible order
data.subset <- data.subset[, c(1,81,2:80)]

# The data.table package provides fast and flexible aggregate functions,
# including the ability to aggregate multiple columns at once.
# See: http://stackoverflow.com/questions/18091146/aggregate-all-columns-with-data-table

# Convert data frame into data.table
data.subset <- data.table(data.subset)

# Aggregate mean by subject and activity:
aggregate.subset <- data.subset[, lapply(.SD, mean), by = c("subject", "activity")]

# Save the final tidied dataset (using .csv text format with Windows style line endings)
write.csv(aggregate.subset, file = "tidy.data.csv", row.names = FALSE, eol = "\r\n")
