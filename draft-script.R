##this file is experimental and working around the main-script
##to ensure data integrity and not tries not to skew any df
##this file contains excess code; may not have used in the final script or report

library(readr)
data1 <- read.csv("/Users/biryani/Documents/code/time-series-avocado/avocado.csv")

#head(data1)

# Assuming your data frame is named 'avocado_data'
# Convert the 'Date' column to a Date object
data1$Date <- as.Date(data1$Date)

# Split the data into training and test datasets
test_data <- subset(data1, Date >= as.Date("2018-01-01") & Date <= as.Date("2018-03-11"))
training_data <- subset(data1, Date <= as.Date("2017-12-31"))

# Verify the dimensions of the datasets
dim(training_data)
dim(test_data)

library(ggplot2)

ggplot(data1, aes(x = AveragePrice)) +
  geom_histogram(fill = "skyblue", color = "black") +
  labs(title = "Distribution of Average Price")

ggplot(data1, aes(x = type, y = AveragePrice, fill = type)) +
  geom_boxplot() +
  labs(title = "Average Price Distribution by Type")

ggplot(data1, aes(x = Total.Volume, y = AveragePrice)) +
  geom_point() +
  labs(title = "Scatterplot of Average Price vs. Total Volume")

correlation_matrix <- cor(data1[, c("Total.Volume", "AveragePrice", "X4046", "X4225", "X4770")])
correlation_matrix

#summary and the blank correlation matrix describes the presence of NA values in AveragePrice
data_clean <- na.omit(data1)

summary(data_clean)

correlation_matrix <- cor(data_clean[, c("Total.Volume", "AveragePrice", "X4046", "X4225", "X4770")])
correlation_matrix

options(repr.plot.width=8, repr.plot.height=4)
ggplot(data_clean, aes(x=AveragePrice, fill=type)) + geom_density() + facet_wrap(~type) + theme_minimal() + 
  theme(plot.title=element_text(hjust=0.5), legend.position="bottom") + labs(title="Avocado Price by Type") + scale_fill_brewer(palette="Set1")

#seasonal chart
seasonal_df <- data_clean

seasonal_df$month_year <- format(as.Date(data_clean$Date), "%Y-%m")
seasonal_df$month <- format(as.Date(data_clean$Date), "%m")
seasonal_df$year <- format(as.Date(data_clean$Date), "%Y")


seasonal_df$monthabb <- sapply(seasonal_df$month, function(x) month.abb[as.numeric(x)])
seasonal_df$monthabb = factor(seasonal_df$monthabb, levels = month.abb)


# # Let's see if there are seasonal patterns with conventional avocadoes
ggplot(seasonal_df, aes(x = AveragePrice, fill = as.factor(year))) + 
  geom_density(alpha = .5) +
  facet_wrap(~ year) + theme(plot.title=element_text(hjust=0.5), plot.background=element_rect(fill="#F9E79F")) + 
  guides(fill = FALSE) + labs(title="Distribution of Prices by year", x = 'Average Price', y = 'Density') + 
  scale_fill_manual(values=c("#2E64FE", "#40FF00", "#FE642E", "#FE2E2E"))


library(dplyr)
# Detecting seasonality patterns
conv_patterns <- seasonal_df %>% select(monthabb, AveragePrice, type) %>% filter(type == "conventional") %>%
  group_by(monthabb) %>% summarize(avg=mean(AveragePrice)) %>%
  ggplot(aes(x=monthabb, y=avg)) + geom_point(color="#F35D5D", aes(size=avg)) + geom_line(group=1, color="#7FB3D5") + 
  theme(legend.position="none", plot.title=element_text(hjust=0.5), plot.background=element_rect(fill="#F9E79F")) + 
  labs(title="Conventional Avocados", x="Month", y="Average Price")


org_patterns <- seasonal_df %>% select(monthabb, AveragePrice, type) %>% filter(type == "organic") %>%
  group_by(monthabb) %>% summarize(avg=mean(AveragePrice)) %>%
  ggplot(aes(x=monthabb, y=avg)) + geom_point(color="#F35D5D", aes(size=avg)) + geom_line(group=1, color="#58D68D") + 
  theme(legend.position="none", plot.title=element_text(hjust=0.5), plot.background=element_rect(fill="#F9E79F")) + 
  labs(title="Organic Avocados", x="Month", y="Average Price")

plot(org_patterns)
plot(conv_patterns)


conv_pattern <- seasonal_df %>%
  select(monthabb, AveragePrice, type) %>%
  filter(type == "conventional") %>%
  group_by(monthabb) %>%
  summarize(avg = mean(AveragePrice)) %>%
  ggplot(aes(x = monthabb, y = avg)) +
  geom_point(color = "#F35D5D", size = 3) +  # Adding points
  geom_line(color = "#7FB3D5", group = 1) +   # Adding line
  labs(title = "Conventional Avocados", x = "Month", y = "Average Price") +
  theme_minimal()  # Remove any background or foreground specifications

# For Organic Avocados
org_pattern <- seasonal_df %>%
  select(monthabb, AveragePrice, type) %>%
  filter(type == "organic") %>%
  group_by(monthabb) %>%
  summarize(avg = mean(AveragePrice)) %>%
  ggplot(aes(x = monthabb, y = avg)) +
  geom_point(color = "#F35D5D", size = 3) +  # Adding points
  geom_line(color = "#58D68D", group = 1) +   # Adding line
  labs(title = "Organic Avocados", x = "Month", y = "Average Price") +
  theme_minimal()  # Remove any background or foreground specifications

plot(org_pattern)
plot(conv_pattern)

                ## new day new vibes ## 

summary(training_data)
training_data_clean <- na.omit(training_data)

seasonal_df <- training_data_clean

seasonal_df$month_year <- format(as.Date(training_data_clean$Date), "%Y-%m")
seasonal_df$month <- format(as.Date(training_data_clean$Date), "%m")
seasonal_df$year <- format(as.Date(training_data_clean$Date), "%Y")


seasonal_df$monthabb <- sapply(seasonal_df$month, function(x) month.abb[as.numeric(x)])
seasonal_df$monthabb = factor(seasonal_df$monthabb, levels = month.abb)

conv_pattern1 <- seasonal_df %>%
  select(monthabb, AveragePrice, type) %>%
  filter(type == "conventional") %>%
  group_by(monthabb) %>%
  summarize(avg = mean(AveragePrice)) %>%
  ggplot(aes(x = monthabb, y = avg)) +
  geom_point(color = "#F35D5D", size = 3) +  # Adding points
  geom_line(color = "#7FB3D5", group = 1) +   # Adding line
  labs(title = "Conventional Avocados TDC", x = "Month", y = "Average Price") +
  theme_minimal()  # Remove any background or foreground specifications

# For Organic Avocados
org_pattern1 <- seasonal_df %>%
  select(monthabb, AveragePrice, type) %>%
  filter(type == "organic") %>%
  group_by(monthabb) %>%
  summarize(avg = mean(AveragePrice)) %>%
  ggplot(aes(x = monthabb, y = avg)) +
  geom_point(color = "#F35D5D", size = 3) +  # Adding points
  geom_line(color = "#58D68D", group = 1) +   # Adding line
  labs(title = "Organic Avocados TDC", x = "Month", y = "Average Price") +
  theme_minimal()  # Remove any background or foreground specifications

plot(org_pattern1)
plot(conv_pattern1)

          ##    fitting a statistical model     ##

head(training_data_clean)
library(fpp)
library(fpp2)
library(fma)
training_data_clean$Date <- as.Date(training_data_clean$Date, format = "%Y-%m-%d")

training_data_clean_df$Date <- as.Date(training_data_clean_df$Date)

# Convert data frame to time series object
training_data_ts <- ts(training_data_clean_df$AveragePrice, frequency = 1, start = 1)

# Now try using autoplot with the time series object
autoplot(training_data_ts)

model1.1 <- auto.arima(training_data_ts)
model1.1

plot(forecast(model1.1))

arima_model <- auto.arima(training_data_ts, d=1, D=1, stepwise=FALSE, approximation=FALSE, trace=TRUE)

print(summary(arima_model))
checkresiduals(arima_model) + theme_minimal() + scale_x_date(date_breaks = "1 year", date_labels = "%X")

arima_forecast <- forecast(arima_model)

#autoplot(arima_forecast, include = 70) + theme_minimal() + theme(plot.title = element_text(hjust=0.5), plot.background = element_rect(fill = "#F4F6F7"), legend.position = "bottom", legend.background = element_rect(fill = "#FFF9F5", size = 0.5, linetype = "solid", color = "blank")) +
 # labs(title = "Forecasting", x = "Date", y = "Price") 
class(arima_forecast$Date)

# If the class is not Date, convert it to Date class
if (!inherits(arima_forecast$Date, "Date")) {
  arima_forecast$Date <- as.Date(arima_forecast$Date)
}

# Get the minimum and maximum dates
min_date <- min(arima_forecast$Date)
max_date <- max(arima_forecast$Date)

# Plot with the converted Date variable and set x-axis limits
autoplot(arima_forecast, include = 70, x = Date) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5),
        plot.background = element_rect(fill = "#F4F6F7"),
        legend.position = "bottom",
        legend.background = element_rect(fill = "#FFF9F5", size = 0.5, linetype = "solid", color = "blank")) +
  labs(title = "Forecasting", x = "Date", y = "Price") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y")



library(fpp)
library(fpp2)
library(fma)
tdcx <- training_data_clean

tdcx$Date <- as.Date(tdcx$Date, format = "%Y-%m-%d")
tdcx_ts <- ts(tdcx$Date, frequency = 1, start = 1)

autoplot(tdcx_ts)

arima_model <- auto.arima(training_data_ts, d=1, D=1, stepwise=FALSE, approximation=FALSE, trace=TRUE)

print(summary(arima_model))
checkresiduals(arima_model, x = Date) + theme_minimal()

arima_forecast <- forecast(arimaarima_forecast <- forecast(arima_model)
                           
plot(arima_forecast)
                           