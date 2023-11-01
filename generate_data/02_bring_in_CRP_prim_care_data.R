pacman::p_load(tidyverse, vroom, data.table)


#pull in CRP codes

crp <- vroom("https://github.com/spiros/ukb-biomarker-phenotypes/raw/master/CRP.csv")
weight <- vroom("https://github.com/spiros/ukb-biomarker-phenotypes/raw/master/Weight.csv")
height <- vroom("https://github.com/spiros/ukb-biomarker-phenotypes/raw/master/Height.csv")
#Bring in data from prim care


read_2 <- fread("/Volumes/MRC-IEU-research/projects/ieu1/wp3/030/working/data/pheno/clinical_diagnosis/2021/gp_clinical.txt.gz", select = c("eid","event_dt", "read_2", "read_3", "value1")) %>%
  as_tibble()

crp_data <- read_2 %>%
  filter(read_2 %in% crp$readcode | read_3 %in% crp$readcode)
crp_data_final <- crp_data %>%
  mutate(value1 = as.numeric(value1), event_dt = lubridate::dmy(event_dt)) 


weight <- read_2 %>%
  filter(read_2 %in% weight$readcode | read_3 %in% weight$readcode) %>%
  select(eid, event_dt, weight = value1)
height <- read_2 %>%
  filter(read_2 %in% height$readcode | read_3 %in% height$readcode) %>%
  select(eid, event_dt, height = value1) 
  

bmi_data_final <- weight %>%
  inner_join(height) %>%
  mutate(bmi = as.numeric(weight) / (as.numeric(height))^2) %>%
  select(eid, event_dt, bmi) %>%
  vroom_write("~/data/CRP/primary_care_bmi.tsv.gz")
bmi_data_final

crp_data_final %>%
  select(eid, crp_gp = value1, event_dt_crp = event_dt) %>%
  vroom_write("~/data/CRP/primary_care_crp.tsv.gz")



  
#some plots

crp_data_final %>%
  ggplot(aes(x = log(value1))) +
  geom_histogram() 

crp_data_final %>%
  group_by(eid) %>%
  count(sort = T)
