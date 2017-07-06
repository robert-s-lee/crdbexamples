
library("ggplot2")

mydata = read.table("~/gitHub/crdbexamples/log.txt")

ggplot(mydata,aes(x=factor(V4),y=V10)) + geom_boxplot() + facet_grid (V6 ~ ., scales="free_y") + geom_smooth(aes(group=1)) + labs(title="insert performance of varying batch size and number of column",x="batch size",y="rows/sec")

ggsave("~/gitHub/crdbexamples/basic-batchwrite.pdf")


