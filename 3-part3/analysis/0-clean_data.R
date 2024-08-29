#Load packages and data---------------------------------------------------------------
library(here)

muisca_data <-
  read.csv(here("3-part3","data","muisca_comp_data.csv"), na.strings = "NA")

#Pre-process data-----------------------------------------------------------------------

#Create combined column based on municipality + department
muisca_data$combined <- toupper(paste(muisca_data$municipality, muisca_data$state_department, sep=", "))

#Change NAs in comp data to 0
muisca_data$cu[is.na(muisca_data$cu)] <- 0
muisca_data$ag[is.na(muisca_data$ag)] <- 0
muisca_data$au[is.na(muisca_data$au)] <- 0

#normalise
muisca_data$cu_norm <-
  as.numeric(muisca_data$cu / (muisca_data$cu + muisca_data$au +
                                    muisca_data$ag))
muisca_data$ag_norm <-
  as.numeric(muisca_data$ag / (muisca_data$cu + muisca_data$au +
                                    muisca_data$ag))
muisca_data$au_norm <-
  as.numeric(muisca_data$au / (muisca_data$cu + muisca_data$au +
                                    muisca_data$ag))


#Aaccount for inability of model to consider 100% or 0%
muisca_data$cu_norm[muisca_data$cu_norm == 0] <-
  min(subset(muisca_data, muisca_data$cu_norm != 0)$cu_norm) * (2 / 3)

muisca_data$cu_norm[muisca_data$cu_norm == 1] <- 0.9999


#Calculate Ag-in-Au

muisca_data$aginau <-
  muisca_data$ag_norm / (muisca_data$ag_norm + muisca_data$au_norm)

muisca_data$aginau[muisca_data$aginau == 0] <-
  min(subset(muisca_data, muisca_data$aginau != 0)$aginau) * (2 / 3)


#create factor based on object type
muisca_data$object_type <- as.factor(ifelse(
  muisca_data$object_function == 'Votive figure' ,
  'Votive figure',
  ifelse(
    muisca_data$object_function %in% c(
      'Melting ingot',
      'Tejuelo (melting ingot)',
      'Casting funnel',
      'Casting sprue',
      'Casting waste',
      'Nugget',
      'Nugget (large)',
      'Nugget (small)',
      'Metal spherule (microscopic)',
      'Spheroid'
    ),
    'Production',
    ifelse(
      muisca_data$object_function %in% c(
        'Axe',
        'Bowl',
        'Chisel',
        'Comb',
        'Fish hook',
        'Needle',
        'Spoon',
        'Tweezers',
        "Sheet over spearthrower",
        'Spearthrower'
      ),
      'Utilitarian',
      ifelse(
        muisca_data$object_function %in% c(
          'Container for coca leaves',
          'Container',
          'Bell finial for lime stick',
          'Hallucinogen tray',
          'Horizontal staff finial',
          'Lime stick',
          'Lime container',
          'Lime container with lid',
          'Lime container/handle',
          'Lime stick finial',
          'Neck of lime container',
          'Pan flute',
          'Staff finial',
          "Sheet over staff",
          'Sheet over wind instrument',
          'Sheet over flute',
          'Wind instrument'
        ),
        'Ceremonial',
        ifelse(
          muisca_data$object_function %in% c(
            'Cylindrical fragment',
            'Fragment',
            'Figure',
            'Hemispherical object',
            'Sharp object',
            'Sheet',
            'Wire',
            'Various items',
            'Fragment - folded sheet',
            'Fragment - tubular',
            'Fragments',
            'Pin head with rattle',
            'Plaque',
            'Rattle',
            "Sheet fragment",
            "Sheet over shell",
            "Sheet over snail shell",
            'Tweezers'
          ),
          'Other',
          'Adornment'
        )
      )
    )
  )
))




#Calculate how many analyses per composite object
n_duplicates <- data.frame(table(muisca_data$composite_id))
names(n_duplicates) <- c("composite_id", "n_duplicates")
muisca_data <-
  merge(muisca_data, n_duplicates, by = "composite_id", all.x = TRUE)


#Calculate volume of individual composite element and multiply this by no of components divided by no of analyses
muisca_data$weightwithcomp <-
  ifelse(
    is.na(muisca_data$weight),
    ifelse(
      !(
        is.na(muisca_data$composite_id) &
          is.na(muisca_data$no_components)
      ),
      muisca_data$composite_weight / muisca_data$no_components *
        muisca_data$no_components / muisca_data$n_duplicates,
      muisca_data$composite_weight
    ),
    muisca_data$weight
  )


muisca_data$weightor <- muisca_data$weight

muisca_data$volume <-
  muisca_data$weightwithcomp / (
    8.92 * muisca_data$cu_norm + 10.49 * muisca_data$ag_norm +
      19.3 * muisca_data$au_norm
  )


save(muisca_data, file = here("3-part3","data","cleaned_data.RData"))
