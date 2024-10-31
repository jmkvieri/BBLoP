#Load data and packages------------------------------------------------------
library(here)
library(RColorBrewer)
library(rstan)
library(scales)

load(here("3-part3","data","aginau_data.RData"))
load(here("3-part3","model_outputs","aginau_model.RData"))

#Helper functions--------------------------------------------------------------
inv_logit <- function(x) {
  1 / (1 + exp(-x))
}

#Calc predictions for each municipality per object type----------------------


#subset original dataset to the two object types
vots <- subset(data_aginau,data_aginau$object_type=="Votive figure" )
adorns <- subset(data_aginau,data_aginau$object_type=="Adornment" )

#extract municipality names
comb <- as.data.frame(unique(data_aginau$combined))
comb$no <- rownames(comb)

#get matches of municipalities for the two object types
vots_no <- comb[comb$`unique(data_aginau$combined)` %in% vots$combined,]
adorns_no <- comb[comb$`unique(data_aginau$combined)` %in% adorns$combined,]


#extract samples
post <- extract(fit_muisca_aginau_multi)

#make predictions for baseline category of adornments for each municipality
#predictions multiplied by 0.4 to convert back from modelling scale (scaled with 40wt% as maximum)
#to original scale of weight percents

y_rep_adorn <- inv_logit(mean(post[["beta"]][,1]) 
                         + apply(post[["beta_mun"]][,,1], 2, mean))*0.4

y_rep_adorn <- y_rep_adorn[as.numeric(adorns_no$no)]

y_rep_adorn_PI <- post[["beta"]][,1] + post[["beta_mun"]][,,1]
y_rep_adorn_PI50 <- inv_logit(apply(y_rep_adorn_PI, 2, quantile, probs=c(0.25,0.75)))*0.4
y_rep_adorn_PI50 <- y_rep_adorn_PI50[,as.numeric(adorns_no$no)]
y_rep_adorn_PI95 <- inv_logit(apply(y_rep_adorn_PI, 2, quantile, probs=c(0.025,0.975)))*0.4
y_rep_adorn_PI95 <- y_rep_adorn_PI95[,as.numeric(adorns_no$no)]


#make predictions for votive figures for each municipality

y_rep_votive <- inv_logit(mean(post[["beta"]][,1]) 
                          + apply(post[["beta_mun"]][,,1], 2, mean) 
                          + mean(post[["beta"]][,3])  
                          + apply(post[["beta_mun"]][,,3], 2, mean))*0.4

y_rep_votive <- y_rep_votive[as.numeric(vots_no$no)]

y_rep_votive_PI <- post[["beta"]][,1] + post[["beta_mun"]][,,1] + post[["beta"]][,3] + post[["beta_mun"]][,,3]
y_rep_votive_PI50 <- inv_logit(apply(y_rep_votive_PI, 2, quantile, probs=c(0.25,0.75)))*0.4
y_rep_votive_PI50 <- y_rep_votive_PI50[,as.numeric(vots_no$no)]
y_rep_votive_PI95 <- inv_logit(apply(y_rep_votive_PI, 2, quantile, probs=c(0.025,0.975)))*0.4
y_rep_votive_PI95 <- y_rep_votive_PI95[,as.numeric(vots_no$no)]


#order from lowest Ag-in-Au ratios to highest
order_adorn <- order(y_rep_adorn)
y_rep_adorn <- y_rep_adorn[order_adorn]
y_rep_adorn_PI50 <- y_rep_adorn_PI50[,order_adorn]
y_rep_adorn_PI95 <- y_rep_adorn_PI95[,order_adorn]

rownames(adorns_no) <- 1:nrow(adorns_no)
adorns_no <- adorns_no[order_adorn,]


order_votive <- order(y_rep_votive)
y_rep_votive <- y_rep_votive[order_votive]
y_rep_votive_PI50 <- y_rep_votive_PI50[,order_votive]
y_rep_votive_PI95 <- y_rep_votive_PI95[,order_votive]
vots_no <- vots_no[order_votive,]


#Plotting settings ------------------------------------------------------------

#Set colours
qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))
palette(col_vector)


#Plot data-------------------------------------------------------------------

#adornments

png(file=here("3-part3","figures","aginau_mun.png"),
    width=3740,
    height=1500
)

par(mfrow=c(1,2),
    cex=2,
    cex.lab=2,
    cex.axis=1.75,
    cex.main=2.25,
    mar=c(5, 6, 4, 2))


plot(
  y_rep_adorn,
  pch = 21,
  cex = 2.5,
  bg = adorns_no$no,
  ylab = "Ag-in-Au (wt%)",
  xlab = "",
  main = c("A) Predicted average Ag-in-Au per cluster for adornments"),
  yaxt = "n",
  xaxt = "n",
  ylim = c(0.07,0.3)
)


axis(2, c(0.05,0.1,0.15,0.2,0.25,0.3), c(5,10,15,20,25,30))

for (i in 1:nrow(adorns_no))
  lines(rep(i, 2) , y_rep_adorn_PI50[, i] , lwd=3, col=alpha(rgb(0,0,0), 0.3), lty=1)

for (i in 1:nrow(adorns_no))
  lines(rep(i, 2) , y_rep_adorn_PI95[, i] , lwd=1, col=alpha(rgb(0,0,0), 0.3), lty=2)



text(
  y_rep_adorn,
  labels = substr(adorns_no[,1], start = 1, stop = 4) ,
  pos = ifelse(seq_along(y_rep_adorn) %% 2 == 1, 3, 1),
  cex = 1,
  offset = 2
)


plot(
  y_rep_votive,
  pch = 23,
  cex = 2.5,
  bg = vots_no$no,
  ylab = "Ag-in-Au (wt%)",
  xlab = "",
  yaxt = "n",
  xaxt = "n",
  ylim = c(0.07,0.3),
  main = c("B) Predicted average Ag-in-Au per cluster for votive figures")
)

axis(2, c(0.05,0.1,0.15,0.2,0.25,0.3), c(5,10,15,20,25,30))

for (i in 1:nrow(vots_no))
  lines(rep(i, 2) , y_rep_votive_PI50[, i] , lwd=3, col=alpha(rgb(0,0,0), 0.3), lty=1)

for (i in 1:nrow(vots_no))
  lines(rep(i, 2) , y_rep_votive_PI95[, i] , lwd=1, col=alpha(rgb(0,0,0), 0.3), lty=2)


text(
  y_rep_votive,
  labels = substr(vots_no[,1], start = 1, stop = 4) ,
  pos = ifelse(seq_along(y_rep_votive) %% 2 == 1, 3, 1),
  cex = 1,
  offset = 2
)


dev.off()
