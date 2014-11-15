unzip('activity.zip')
data <- read.csv('activity.csv')
date_data <- aggregate(list(total_steps=data$steps), by=list(date=data$date), FUN=sum)
date_data <- aggregate(list(total_steps=data$steps), by=list(date=data$date), FUN=sum)
interval_data <- aggregate(list(total_steps=data$steps), 
                           by=list(interval=data$interval),
                           FUN=function(a) {mean(a, na.rm=TRUE)}
)

my_func <- function(row) {

  if (is.na(row[[1]])) {
    row[[1]] = interval_data$total_steps[interval_data$interval == as.numeric(row[[3]])]
  }
  as.numeric(row[[1]])
}