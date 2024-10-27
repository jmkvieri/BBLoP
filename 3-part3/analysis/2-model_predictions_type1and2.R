#Load packages and data--------------------------------------------------------
library(here)
library(ggplot2)
library(rstan)
library(gridExtra)

load(here("3-part3","model_outputs","aginau_model.RData"))
load(here("3-part3","data","aginau_data.RData"))


#Helper functions--------------------------------------------------------------
inv_logit <- function(x) {
  1 / (1 + exp(-x))
}

#Plotting settings ------------------------------------------------------------

#create scale that converts from standardised to original scale
scale_x <-
  scale_x_continuous(breaks = sapply(seq(
    from = min(data_aginau$volume),
    to = max(data_aginau$volume),
    by = 2),
    function(non_standard)
      (non_standard - mean(data_aginau$volume)) / sd(data_aginau$volume)),
    labels = round(seq(
      from = min(data_aginau$volume),
      max(data_aginau$volume),
      by = 2),
      digits = 1))


My_Theme = theme(
  axis.title.x = element_text(size = 66,vjust = -0.75),
  axis.text.x = element_text(size = 64),
  axis.text.y = element_text(size = 64),
  axis.title.y = element_text(size = 66, vjust=5),
  legend.text = element_text(size = 66),
  legend.title = element_text(size = 66),
  legend.position = "bottom",
  legend.box.spacing = unit(85, "pt"),
  legend.key.size = unit(2, "cm"),
  panel.grid = element_line(size = 2.5,
                            linetype = 2),
  plot.margin = unit(c(1,2,1,2), "cm"),
  plot.title = element_text(size = 80))


scale_y <-
  scale_y_continuous(breaks = c(0,0.1,0.2,0.3,0.4),
                     labels = c(0,10,20,30,40),
                     limits = c(0,0.4))

scale_y2 <-
  scale_y_continuous(breaks = c(0,0.05,0.1,0.15),
                     labels = c(0,5,10,15),
                     limits = c(0,0.15))


#Calc predictions for specified pred values for votive figures------------------

#extract posterior samples
post <- extract(fit_muisca_aginau_multi)

#Choose values of volume to predict for
vol.seq <-
  seq(
    from = min(data_aginau$volume_std) ,
    to = max(data_aginau$volume_std) ,
    length.out = 30
  )


#use param posteriors, vol seq, to make preds

#var and phi will store calculations based on all posterior values of params
#those with _mean will store mean predictions
#PI90 store prediction intervals covering 0.95 probability
#predictions multiplied by 0.4 to convert back from modelling scale (scaled with 40wt% as maximum)
#to original scale of weight percents

vot <-  sapply(vol.seq , function(vol)
  (inv_logit(
    (post$beta[, 1] + 
       post$beta[, 2] * vol + 
       post$beta[, 3] * 1
    ))
  )
)

vot_phi <-  sapply(vol.seq , function(vol)
  (exp(
    post$gamma[, 1] + 
      post$gamma[, 2] * vol + 
      post$gamma[, 3] * 1
  ))
)


vot_mean <- apply( vot , 2 , mean ) * 0.4
vot_PI95 <- apply( vot , 2 , quantile, probs=c(0.025, 0.975)) * 0.4
vot_phi_mean <- apply( vot_phi , 2 , mean )
vot_phi_PI95 <- apply( vot_phi , 2 , quantile, probs=c(0.025, 0.975))
vot_var_mean <- apply((vot * (1 - vot)) / (vot_phi + 1) * 0.4, 2, mean)
vot_var_PI95 <- apply((vot * (1 - vot)) / (vot_phi + 1) * 0.4, 2, quantile, probs=c(0.025, 0.975))


#Calc predictions for specified pred values for adornments---------------------

orn <-  sapply(vol.seq , function(vol)
  (inv_logit(
    (post$beta[, 1] + 
       post$beta[, 2] * vol + 
       post$beta[, 3] * 0
    ))
  )
)

orn_phi <-  sapply(vol.seq , function(vol)
  (exp(
    post$gamma[, 1] + 
      post$gamma[, 2] * vol + 
      post$gamma[, 3] * 0
  ))
)

orn_mean <- apply( orn , 2 , mean ) * 0.4
orn_PI95 <- apply( orn , 2 , quantile, probs=c(0.025, 0.975)) * 0.4
orn_phi_mean <- apply( orn_phi , 2 , mean )
orn_phi_PI95 <- apply( orn_phi , 2 , quantile, probs=c(0.025, 0.975))
orn_var_mean <- apply((orn * (1 - orn)) / (orn_phi + 1) * 0.4, 2, mean)
orn_var_PI95 <- apply((orn * (1 - orn)) / (orn_phi + 1) * 0.4, 2, quantile, probs=c(0.025, 0.975))


#Plot predictions---------------------------------------------------------


#create and save plots for mu

graph_mean <- ggplot() +
  geom_ribbon(aes(
    x = vol.seq,
    ymin = vot_PI95[1, ],
    ymax = vot_PI95[2, ],
    color = "Votive figure",
    fill="Votive figure"),
    alpha = 0.20) +
  geom_ribbon(aes(
    x = vol.seq,
    ymin = orn_PI95[1, ],
    ymax = orn_PI95[2, ],
    color = "Adornment",
    fill="Adornment"),
    alpha = 0.20) +
  geom_line(aes(x = vol.seq, y = vot_mean),
          color = "#F8766D",
          linewidth = 4) +
  geom_line(aes(x = vol.seq, y = orn_mean),
            color = "#00BFC4",
            linewidth = 4) + scale_y +
  My_Theme + ylab("\u00b5 of Ag-in-Au (wt%)") + xlab(bquote("Volume (" * cm^3 * ")")) + scale_x + 
  scale_color_manual(name="Object type",
                     values = c("Votive figure" = "#F8766D",  "Adornment" = "#00BFC4")) + 
  scale_fill_manual(name="Object type",
                    values = c("Votive figure" = "#F8766D",  "Adornment" = "#00BFC4")) +
  ggtitle("A")



graph_disp <- ggplot() + 
  geom_ribbon(aes(
    x = vol.seq, 
    ymin = sqrt(orn_var_PI95[1, ]), 
    ymax = sqrt(orn_var_PI95[2, ]), 
    color="Adornment", 
    fill="Adornment"
  ), alpha = 0.20) + 
  geom_ribbon(aes(
    x = vol.seq, 
    ymin = sqrt(vot_var_PI95[1, ]), 
    ymax = sqrt(vot_var_PI95[2, ]), 
    color="Votive figure", 
    fill="Votive figure"
  ), alpha = 0.20) +
  geom_line(aes(x = vol.seq, y = sqrt(vot_var_mean)), linewidth = 4, color = "#F8766D") +
  geom_line(aes(x = vol.seq, y = sqrt(orn_var_mean)), linewidth = 4, color = "#00BFC4") + 
  scale_y2 + 
  My_Theme + 
  ylab("SD of Ag-in-Au (wt%)") + 
  xlab(bquote("Volume (" * cm^3 * ")")) + 
  scale_x + 
  scale_color_manual(
    name="Object type", 
    values = c("Votive figure" = "#F8766D", "Adornment" = "#00BFC4")
  ) + 
  scale_fill_manual(
    name="Object type", 
    values = c("Votive figure" = "#F8766D", "Adornment" = "#00BFC4")
  ) + 
  ggtitle("B")


png(file =  here("3-part3","figures","aginau_vol.png"),
    height = 1754,
    width = 3740)

grid.arrange(graph_mean,graph_disp,ncol=2)

dev.off()


