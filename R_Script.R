cat("\014") # clears console
rm(list = ls()) # clears global environment
try(dev.off(dev.list()["RStudioGD"]), silent = TRUE) # clears plots
try(p_unload(p_loaded(), character.only = TRUE), silent = TRUE) # clears packages
options(scipen = 100) # disables scientific notion for entire R session



                                                           
# Load required libraries
library(dplyr)    # for data manipulation
library(ggplot2)  # for data visualization

# Load the dataset
data <- read.csv("E:/Module2_EDA/Border_Crossing_Entry_Data.csv")


# Basic data exploration
# What did you do with the data in the context of exploration?

# Check variables and data types
str(data)

# Summary statistics
summary(data)


#How many entries are in the dataset?
# Count number of entries
num_entries <- nrow(data)
num_entries


# Was there missing data? Duplications? How clean was the data?
# Check for missing data
any_missing <- any(is.na(data))
any_missing

# Check for duplicates
duplicated_rows <- data[duplicated(data), ]
duplicated_rows_count <- nrow(duplicated_rows)
duplicated_rows_count



# Were their outliers or suspicious data?
# Check summary statistics for the "Value" variable
summary_stats <- summary(data$Value)         ##  The "Value" column in Border_crossing_entry dataset represents
print(summary_stats)                         ## the quantity or numerical count associated with each entry.


# Create a boxplot with colored outliers
boxplot(data$Value, main = "Boxplot of Value with Colored Outliers", ylab = "Value",
        col = "lightblue",  # Color of the box
        border = "black",  # Color of the box border
        outcol = "red"  # Color of the outlier points
)

# Identify potential outliers using boxplot statistics
outliers <- boxplot.stats(data$Value)$out
print(outliers)



# What did you do to clean the data?
# Data Cleaning
# Remove duplicates
cleaned_data <- data[!duplicated(data), ]




# Some other graphs
#1.) Calculate total traffic counts by measure and port
traffic_summary <- data.frame(
  Port = cleaned_data$Port.Name,
  Measure = cleaned_data$Measure,
  Traffic_Count = ave(cleaned_data$Value, cleaned_data$Port.Name, cleaned_data$Measure, FUN = sum)
)

# Sort the summary dataframe by Traffic_Count in descending order
traffic_summary <- traffic_summary[order(-traffic_summary$Traffic_Count), ]

# Create a bar plot to visualize traffic counts by measure at each port
ggplot(traffic_summary, aes(x = Port, y = Traffic_Count, fill = Measure)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Traffic Counts by Measure at Border Ports",
       x = "Border Ports",
       y = "Traffic Count",
       fill = "Measure") +
  theme_minimal() + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for better readability


#2.)
# Bar Chart of Activity Types (Measure) with Color
ggplot(cleaned_data, aes(x = Measure, fill = Measure)) +  
  geom_bar() +
  labs(title = "Count of Activities by Type", x = "Activity Type", y = "Count") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_fill_discrete(name = "Activity Type")  # Customize legend title

# Boxplot of Activity Values by Border Type with Color
ggplot(cleaned_data, aes(x = Border, y = Value, fill = Border)) +  
  geom_boxplot() +
  labs(title = "Distribution of Traffic Volume by Border Type", x = "Border Type", y = "Activity Value") +
  scale_fill_discrete(name = "Border Type")  # Customize legend title

# Bar Chart of Activities by State with Color
ggplot(cleaned_data, aes(x = State, fill = State)) +  
  geom_bar() +
  labs(title = "Count of Activities by State", x = "State", y = "Count") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_fill_discrete(name = "State")  # Customize legend title


#3.) Visualization - Scatter plot for Latitude vs. Longitude
ggplot(cleaned_data, aes(x = Longitude, y = Latitude, color = Border)) +
  geom_point() +
  labs(title = "Border Crossing Locations",
       x = "Longitude",
       y = "Latitude") +
  theme_minimal()



#4. ) Calculate total traffic counts by port
port_traffic <- aggregate(Value ~ Port.Name, data = cleaned_data, FUN = sum)

# Sort the data to plot in descending order
port_traffic <- port_traffic[order(-port_traffic$Value), ]

# Create a bar plot to visualize traffic volume by port
ggplot(port_traffic, aes(x = reorder(Port.Name, -Value), y = Value)) +
  geom_bar(stat = "identity", fill = "skyblue", color = "black") +
  labs(title = "Traffic Volume by Port", x = "Port", y = "Traffic Volume") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))  # Rotate x-axis labels for better readability



#################################### DATA MINING TECHNIQUES ##################################################


#5.)# K - Means Clustering

# Select relevant columns for clustering (e.g., Latitude, Longitude, Value)
cluster_data <- cleaned_data[, c("Latitude", "Longitude", "Value")]

# Normalize the data (optional but recommended for clustering)
normalized_data <- scale(cluster_data)

# Determine the number of clusters (k)
k <- 3  # Adjust the number of clusters as needed based on your preference

# Perform k-means clustering
kmeans_result <- kmeans(normalized_data, centers = k, nstart = 25)

# Add cluster labels to the original data
clustered_data <- cbind(cluster_data, Cluster = kmeans_result$cluster)

# Plot the clustered data
ggplot(clustered_data, aes(x = Longitude, y = Latitude, color = factor(Cluster))) +
  geom_point() +
  labs(title = "K-means Clustering of Border Crossing Data",
       x = "Longitude",
       y = "Latitude",
       color = "Cluster") +
  theme_minimal()



#######Decision Tree
#6.) Load the required library for decision trees
library(rpart)

library(rpart.plot)

# Assuming 'Value' is the target variable and 'Latitude' is the input feature
# Split data into training and testing sets (e.g., 80% training, 20% testing)
set.seed(123)  # for reproducibility
train_idx <- sample(nrow(cleaned_data), 0.8 * nrow(cleaned_data))
train_data <- cleaned_data[train_idx, ]
test_data <- cleaned_data[-train_idx, ]

# Build the decision tree model using only 'Latitude' as the input feature
tree_model <- rpart(Value ~ Latitude, data = train_data, method = "anova")

# Plot the decision tree
rpart.plot(tree_model, type = 0, extra = 101)

# Make predictions on the testing data
predictions <- predict(tree_model, test_data)

# Evaluate the model (calculate mean squared error)
mse <- mean((test_data$Value - predictions)^2)
print(paste("Mean Squared Error (MSE):", mse))




