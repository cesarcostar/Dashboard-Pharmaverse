

library(metacore)
library(metatools)
library(admiral.test)
library(admiral)
library(xportr)
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)

# Read in input SDTM data 
data("admiral_dm")
data("admiral_ex")

load(metacore_example("pilot_ADaM.rda"))
metacore <- metacore %>% 
  select_dataset("ADSL")

adsl_preds <- build_from_derived(metacore, 
                                 ds_list = list("dm" = admiral_dm), 
                                 predecessor_only = FALSE, keep = TRUE)
head(adsl_preds, n=10)





