## Import the data, provided by http://www.gemconsortium.org/key-indicators
## Key indicators and definitions are listed:
## http://www.gemconsortium.org/docs/download/414
USent_data <- read.csv('http://gemdata.dev.marmaladeontoast.co.uk/dataset/csv?country[]=1&variable[]=21&variable[]=6&variable[]=22&year[]=all&v=', header = T, skip = 2)

## melt & format
library(reshape)
molten <- melt(USent_data, id = "Name", measure = c("X2001", "X2002", "X2003", "X2004", "X2005", "X2006", "X2007", "X2008", "X2009", "X2010", "X2011", "X2012"))

names(molten)[names(molten)=='variable'] <- 'Year'
names(molten)[names(molten)=='value'] <- 'Percentage'

## plot
library(ggplot2)

p <- ggplot(molten, aes(x = Year, y = Percentage, color = Name, group = Name))
p <- p + geom_line() + geom_point()
p <- p + scale_x_discrete(labels=c("2001","2002", "2003","2004","2005","2006","2007","2008","2009","2010","2011","2012"))
p <- p + theme(legend.position = 'bottom')
p <- p + ggtitle("Early-Stage Entrepreneurial Activity in the US: 2001 - 2012")

#save
png(filename="saaya_hw1.png", width=1024, height=768)
p
dev.off()