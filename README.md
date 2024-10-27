# BBLoP (Beyond Baselines of Performance: beta regression models of compositional variability in craft production studies)

This repository contains the data and scripts used in the manuscript:

```         
  Vieri et al., submitted. Beyond baselines of performance: beta regression models of compositional variability in craft production studies
```

# Structure

The user can download the whole contents in bulk, with all of the analyses designed to be run on a script-by-script basis. The repository is organised into four main sections as follows:

| FOLDER                                 | DESCRIPTION                                                                                   |
|----------------------------------------|--------------------------|
| **0-stanmodelcodes**                   | **All Stan model codes**                                                                      |
| **1-part1**                            | **Simulated data and R scripts used for *Part I - Modelling compositional data***             |
| **2-part2**                            | **Simulated data and R scripts used for *Part II - Multilevel models of compositional data*** |
| **3-part3**                            | **Data and R scripts used for *Part III - Muisca goldwork as a case study***                  |
| **S-supplementarymaterials**           | **Code used for the Supplementary Materials**                                                   |


Each folder is also divided into the following sub-sections, where relevant: **analysis**, **data**, **figures**, **model_outputs**, **simulation**, and **tables**.

While some of the scripts rely on Stan model codes or outputs from other script files, the repository is designed so that each script can be run independently from one another, with each script accessing the relevant Stan files or .RData files using relative file paths to the root of the project directory.

However, where and if the analyses follow a particular order, i.e. are sequential to one another, this is indicated by prefixes in the file names, so that, e.g., in the folder **3-part3/analysis**, the file _0-clean_data.R_ produces a cleaned version of the compositional Muisca dataset, the file _1-run_muisca_model.R_ is used to fit the model on the cleaned dataset, and the files _2-model_predictions_type1and2.R_ and _2-model_predictions_type3.R_ are used to extract and plot the model predictions from the output file storing the model fit.

# Models

The final model used for the Muisca case study was the most computationally expensive and took less than one minute to run with the following processor: Apple M2 Max. Re-running the models and extracting posterior samples will require installation of RStan and the C++ toolchain ([instructions](https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started)). The Stan syntax in this repository reflects that used by RStan v. 2.26.1. An index of the script files used for re-running each model used for the Muisca case study is provided below.

| Model                | Stan file                                                             | R Script                                                          | Model output                      | Model output file                    |
| -------------------------- | --------------------------------------------------------------- | ----------------------------------------------------------------- | --------------------------------- | ------------------------------------ |
| Final model                | "./0-stanmodelcodes/beta_vardisp_hierarchical_varintslope.stan" | "./5-part_2-modelling/muisca_aginau_models/run_aginau_models.R"   | "fit_muisca_aginau_multi"         | "aginau_model.RData"                 |
| Var disp. beta reg         |  "./0-stanmodelcodes/betareg_vardisp.stan"                      | "./S-supplementarymaterials/analysis/run_models_for_comparison.R" | "fit_muisca_aginau_beta_vardisp"  | "aginau_model1_for_comparison.RData" |
| Beta reg.                  |  "./0-stanmodelcodes/betareg.stan"                              | "./S-supplementarymaterials/analysis/run_models_for_comparison.R" | "fit_muisca_aginau_beta_novardisp"| "aginau_model2_for_comparison.RData" |


# Tables and Figures

Finally, an index of the tables and figures contained within the article and in the Supplementary Material (if created in R), and the associated scripts and output file names.

| Table               | Scripts                                                     | Output files                                                  |
|---------------------|-------------------------------------------------------------|---------------------------------------------------------------|
| 1                   |  "./3-part3/tables/model_summary.R"                         | "./3-part3/tables/summary_post.csv"                           |
| S3                  |  "./S-supplementarymaterials/tables/sample_sizes.R"         |"./S-supplementarymaterials/tables/sample_sizes.csv"           |
| S6                  |  "./S-supplementarymaterials/analysis/model_comparison.R"   | "./S-supplementarymaterials/tables/loo_model_comparison.csv"  |



| Figure       | Scripts                                                                   | Output files                                                       |
|--------------|---------------------------------------------------------------------------|--------------------------------------------------------------------|
| 2            |  "./1-part1/simulation/beta_densities.R"                                  | "./1-part1/figures/beta_densities.png"                             |
| 3            |  "./1-part1/simulation/betareg_type1.R"                                   | "./1-part1/figures/simulated_model_performance.png"                |
| 4            |  "./1-part1/simulation/betareg_type2.R"                                   | "./1-part1/figures/sim_comp_pred[...].png"                         |
|              |                                                                           | "./1-part1/figures/sim_comp_SD_pred[...].png"                      |
| 5            |  "./2-part2/simulation/betareg_type3.R"                                   | "./2-part2/figures/"simulated_multi.png"                           |
| 8            |  "./3-part3/analysis/model_predictions_type1and2.R"                       | "./3-part3/figures/"aginau_vol.png"                                |
| 9            |   "./3-part3/analysis/model_predictions_type3.R"                          | "./3-part3/figures/"aginau_orn_mun.png"                            |
|              |                                                                           | "./3-part3/figures/"aginau_vot_mun.png"                            |
| S1           |   "./S-supplementarymaterials/analysis/log_transformation_skewness.R"     | "./S-supplementarymaterials/figures/"log_skewness.png"             |
| S2           |   "./S-supplementarymaterials/analysis/exploratory_scatterplot.R"         | "./S-supplementarymaterials/figures/"exploratory_muisca_aginau.png"|
| S3           |   "./S-supplementarymaterials/analysis/model_comparison.R"                | "./S-supplementarymaterials/figures/"aginau_model_comp.png"        |

# R Session info

```
attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
[1] scales_1.2.1        RColorBrewer_1.1-3  reshape2_1.4.4      brms_2.19.0         Rcpp_1.0.11         ggplot2_3.4.4.9000  rstan_2.26.22       StanHeaders_2.26.27
[9] here_1.0.1         

loaded via a namespace (and not attached):
 [1] tidyselect_1.2.1     dplyr_1.1.2          farver_2.1.1         loo_2.7.0            fastmap_1.1.1        tensorA_0.36.2       shinystan_2.6.0     
 [8] shinyjs_2.1.0        promises_1.2.0.1     digest_0.6.33        estimability_1.4.1   mime_0.12            lifecycle_1.0.4      ellipsis_0.3.2      
[15] processx_3.8.2       magrittr_2.0.3       posterior_1.5.0      compiler_4.3.1       rlang_1.1.2          tools_4.3.1          igraph_1.5.0        
[22] utf8_1.2.4           labeling_0.4.3       prettyunits_1.1.1    bridgesampling_1.1-2 htmlwidgets_1.6.2    pkgbuild_1.4.2       curl_5.2.1          
[29] plyr_1.8.9           dygraphs_1.1.1.6     abind_1.4-5          miniUI_0.1.1.1       withr_2.5.2          grid_4.3.1           stats4_4.3.1        
[36] fansi_1.0.5          xts_0.13.1           xtable_1.8-4         colorspace_2.1-0     inline_0.3.19        emmeans_1.8.9        gtools_3.9.4        
[43] cli_3.6.1            mvtnorm_1.2-2        crayon_1.5.2         generics_0.1.3       RcppParallel_5.1.7   rstudioapi_0.15.0    stringr_1.5.0       
[50] shinythemes_1.2.0    bayesplot_1.10.0     parallel_4.3.1       matrixStats_1.0.0    base64enc_0.1-3      vctrs_0.6.4          V8_4.3.2            
[57] Matrix_1.6-0         jsonlite_1.8.7       callr_3.7.3          crosstalk_1.2.0      glue_1.6.2           codetools_0.2-19     ps_1.7.5            
[64] DT_0.28              distributional_0.3.2 stringi_1.7.12       gtable_0.3.4         later_1.3.1          munsell_0.5.0        tibble_3.2.1        
[71] colourpicker_1.2.0   pillar_1.9.0         htmltools_0.5.5      Brobdingnag_1.2-9    R6_2.5.1             rprojroot_2.0.3      shiny_1.7.4.1       
[78] lattice_0.21-8       markdown_1.7         backports_1.4.1      threejs_0.3.3        httpuv_1.6.11        rstantools_2.3.1     coda_0.19-4         
[85] gridExtra_2.3        nlme_3.1-162         checkmate_2.2.0      zoo_1.8-12           pkgconfig_2.0.3     
```


## Funding

Primary funding was obtained from the Arts and Humanities Research Council UK (AHRC), who funded the lead author's Cambridge AHRC-Doctoral Training Partnership Scholarship (2112128). Additional funding was obtained from the Osk. Huttunen Foundation, the European Research Council (ERC) under the European Union’s Horizon 2020 research and innovation programme (Grant agreement No. 101021480, REVERSEACTION project), St John's College, University of Cambridge, and the Department of Archaeology, University of Cambridge.
