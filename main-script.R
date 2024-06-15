library(readr)
library(ggplot2)
library(gridExtra)
library(fpp)
library(fpp2)
library(fma)

df <- read.csv("/Users/biryani/Documents/code/time-series-avocado/avocado.csv")

# Split the data into training and test datasets
test_data <- subset(df, Date >= as.Date("2018-01-01") & Date <= as.Date("2018-03-11"))
training_data <- subset(df, Date <= as.Date("2017-12-31"))

## b
summary(training_data)
training_data_clean <- na.omit(training_data)

eda_df <- training_data_clean #duplicating df for exploratory data analysis part

#setting the month, month_year and year
eda_df$month_year <- format(as.Date(training_data_clean$Date), "%Y-%m")
eda_df$month <- format(as.Date(training_data_clean$Date), "%m")
eda_df$year <- format(as.Date(training_data_clean$Date), "%Y")

eda_df$monthabb <- sapply(eda_df$month, function(x) month.abb[as.numeric(x)])
eda_df$monthabb = factor(eda_df$monthabb, levels = month.abb)

conv_eda <- eda_df %>%
  select(monthabb, AveragePrice, type) %>%
  filter(type == "conventional") %>%
  group_by(monthabb) %>%
  summarize(avg = mean(AveragePrice)) %>%
  ggplot(aes(x = monthabb, y = avg)) + geom_point(color = "#F35D5D", size = 2) + geom_line(color = "#7FB3D5", group = 1) + 
  labs(title = "Conventional Avocados", x = "Month", y = "Average Price") + theme_minimal() 

# For Organic Avocados
org_eda <- eda_df %>%
  select(monthabb, AveragePrice, type) %>%
  filter(type == "organic") %>%
  group_by(monthabb) %>%
  summarize(avg = mean(AveragePrice)) %>%
  ggplot(aes(x = monthabb, y = avg)) + geom_point(color = "#F35D5D", size = 2) + geom_line(color = "#7FB3D5", group = 1) +
  labs(title = "Organic Avocados", x = "Month", y = "Average Price") + theme_minimal()  

#creating seperate df for each type
org_df <- filter(eda_df, type == "organic")
conv_df <- filter(eda_df, type == "conventional")

org_df$Date <- as.Date(org_df$Date)
conv_df$Date <- as.Date(conv_df$Date)

#plotting the conv and org plot for average price
conv_plot <- conv_df %>%
  ggplot(aes(x=Date, y=AveragePrice)) + geom_line(color="#7FB3D5") + theme_minimal() + 
  theme(plot.title=element_text(hjust=0.5)) + 
  labs(title="Conventional Avocados")

org_plot <- org_df %>%
  ggplot(aes(x=Date, y=AveragePrice)) + geom_line(color="#7FB3D5") + theme_minimal() + 
  theme(plot.title=element_text(hjust=0.5)) + 
  labs(title="Organic Avocados")

grid.arrange(org_plot, org_eda, conv_plot, conv_eda, ncol = 2)

#modelling and forecasting of the dataset

conv_ts <- ts(conv_df$AveragePrice, start=c(2015, 1), frequency=52, end = c(2017,52))
org_ts <- ts(org_df$AveragePrice, start=c(2015, 1), frequency=52, end = c(2017,52))

#conventional arima modelling
arima_conv <- auto.arima(conv_ts, d=1, D=1, stepwise=FALSE, approximation=FALSE, trace=TRUE)

print(summary(arima_conv))

#organic arima modelling
arima_os <- auto.arima(org_ts, d=1, D=1, stepwise=FALSE, approximation=FALSE, trace=TRUE)

#forecasting of both types
forecast_os <- forecast(arima_os, h = 10)
forecast_cv <- forecast(arima_conv, h = 10)

plot_os <- autoplot(forecast_os)
plot_cv <- autoplot(forecast_cv)

grid.arrange(plot_os, plot_cv, nrow = 2) #plotting the forecast graph

#residual analysis for conventional avocados
residuals_cv <- residuals(arima_conv)
resid_cv_ts <- ts(residuals_cv, start=c(2015, 1), frequency=52)

#residual analysis for organic avocados

residuals_os <- residuals(arima_os)
resid_os_ts <- ts(residuals_os, start=c(2015, 1), frequency=52)

plot.new()
#plotting residual, acf, pacf
layout(matrix(c(1,1,2,3), 2, 2, byrow = TRUE))

plot(resid_cv_ts, main="Residuals", ylab="", xlab="Year")
acf(resid_cv_ts, main="ACF", ylim = c(-0.2, 0.2))
pacf(resid_cv_ts, main="PACF")

#plotting residual, acf, pacf
layout(matrix(c(1,1,2,3), 2, 2, byrow = TRUE))

plot(resid_os_ts, main="Residuals", ylab="", xlab="Year")
acf(resid_os_ts, main="ACF", ylim = c(-0.2, 0.2))
pacf(resid_os_ts, main="PACF")

# Evaluating the model
# test data to time series
test_data_ts <- ts(na.omit(test_data)$AveragePrice, start=c(2018, 1), frequency=52, end = c(2018, 10))

# assigning mean
forecast_values_os = forecast_os$mean
forecast_values_cv = forecast_cv$mean

mse_value_os <- mean((as.vector(test_data_ts) - forecast_values_os)^2)
mse_value_cv <- mean((as.vector(test_data_ts) - forecast_values_cv)^2)

#print(mse_value_cv)
#print(mse_value_os)


mse_cv <- mse_value_cv
mse_os <- mse_value_os

# Creating a data frame for the table
mse_df <- data.frame(Type = c("CV", "OS"),
                     MSE = c(mse_cv, mse_os))
knitr::kable(mse_df)