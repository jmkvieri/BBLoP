#Load data and packages--------------------------------------------------------
library(here)

load(here("3-part3","data","aginau_data.RData"))

sample_sizes <- as.data.frame.matrix(table(data_aginau$combined,data_aginau$object_type))

sample_sizes$Total <- sample_sizes$Adornment+sample_sizes$`Votive figure`

sample_sizes <- rbind(sample_sizes, Total=as.integer(colSums(sample_sizes)))

sample_sizes <- sample_sizes[c(rev(order(sample_sizes$Total))[2:48],48),]

write.csv(sample_sizes, here("S-supplementarymaterials","tables","sample_sizes.csv"))
