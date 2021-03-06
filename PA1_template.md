# Reproducible Research: Peer Assessment 1
Aurimas R.  
11/15/2014  

This is my version of the peer assessment 1 for the [Reproducible Research course on Coursera](https://class.coursera.org/repdata-008). We're working on activity data from a personal activity monitoring device (ala Fitbit). Very awesome!

##Loading and preprocessing data

First, let's get the data in order. We will also need to do some calculations and by interval, so why not to prepare the datasets accordingly.


```r
unzip('activity.zip')
data <- read.csv('activity.csv')
date_data <- aggregate(list(total_steps=data$steps), by=list(date=data$date), FUN=sum)
interval_data <- aggregate(list(total_steps=data$steps), by=list(interval=data$interval), FUN=function(a) {mean(a, na.rm=TRUE)})
```

## What is mean total number of steps taken per day?


```r
hist(date_data$total_steps, main="Number of steps taken per day", xlab="")
```

![](./PA1_template_files/figure-html/unnamed-chunk-2-1.png) 

```r
mean <- sprintf("%.0f", mean(date_data$total_steps, na.rm=TRUE))
median <- sprintf("%.0f", median(date_data$total_steps, na.rm=TRUE))
```

The average number of steps taken per day is 10766 and the median is 10765.

## What is the average daily activity pattern?


```r
plot(interval_data$interval, interval_data$total_steps, type='l', xlab="Numbers of steps per interval")
```

![](./PA1_template_files/figure-html/unnamed-chunk-3-1.png) 

```r
max <- interval_data$interval[interval_data$total_steps == max(interval_data$total_steps)]
start_time <- format(strptime(x=0, format='%s') + max * 60, "%H:%M", tz='UTC')
end_time <- format(strptime(x=0, format='%s') + (max + 5) * 60, "%H:%M", tz='UTC')
```

The interval with highest average activity is 835 (13:55 - 14:00).

## Imputing missing values


```r
missing_values = length(is.na(data$steps))
```
So... this dataset has 17568 missing values. That's quite a bit! Why don't we impute the missing values by using average numbers of steps in an interval (e.g. if an interval is missing data, let's just plug an average for that interval accross the dataset). Given the variance of activity throughout a day, this should be more accurate than using day-based average.


```r
new_data <- data
new_data$steps <- apply(new_data, MARGIN=1, FUN = function(row) {
  if (is.na(row[[1]])) {
    row[[1]] = interval_data$total_steps[interval_data$interval == as.numeric(row[[3]])]
  }
  as.numeric(row[[1]])
})
```

Now, let's try to recalculate the means/medians on the new dataset.


```r
date_data <- aggregate(list(total_steps=new_data$steps), by=list(date=new_data$date), FUN=sum)
hist(date_data$total_steps, main="Number of steps taken per day", xlab="")
```

![](./PA1_template_files/figure-html/unnamed-chunk-6-1.png) 

```r
mean <- sprintf("%.0f", mean(date_data$total_steps, na.rm=TRUE))
median <- sprintf("%.0f", median(date_data$total_steps, na.rm=TRUE))
```

The average number of steps taken per day is 10766 and the median is 10766. Unsurprisingly, there is no change in the mean (as I used the averages to impute the values), but the median went up a bit (as missing values were replaced with values above 0).


## Are there differences in activity patterns between weekdays and weekends?

Alright. First, let's create a new factor variable.


```r
new_data$day_of_week <- apply(new_data, MARGIN=1, FUN = function(row) {
  day = weekdays(as.Date(row[[2]]), abbreviate = TRUE)
  if (is.element(day, c('Sun', 'Sat'))) {
    factor = 'weekend'
  } else {
    factor = 'weekday'
  }
  factor
})
```

Now, let's make the plots. I'll do it with the base plot system.


```r
nd_wd <- new_data[new_data$day_of_week == 'weekday', ]
nd_wk <- new_data[new_data$day_of_week == 'weekend', ]

interval_data_wd <- aggregate(list(total_steps=nd_wd$steps), by=list(interval=nd_wd$interval), FUN=function(a) {mean(a, na.rm=TRUE)})
interval_data_wk <- aggregate(list(total_steps=nd_wk$steps), by=list(interval=nd_wk$interval), FUN=function(a) {mean(a, na.rm=TRUE)})

par(mfcol=c(2,1), mar=c(4,2,4,2))
plot(
  interval_data_wd$interval,
  interval_data_wd$total_steps,
  type='l',
  main="Numbers of steps per interval",
  xlab="Weekdays",
  ylab=""
)
par(mar=c(4,2,1,2))
plot(
  interval_data_wk$interval,
  interval_data_wk$total_steps,
  type='l',
  xlab="Weekends",
  ylab=""
)
```

![](./PA1_template_files/figure-html/unnamed-chunk-8-1.png) 
