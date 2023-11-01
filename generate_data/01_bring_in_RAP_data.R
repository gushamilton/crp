pacman::p_load(tidyverse, vroom, janitor)

#Bring in data from RAP = CRP

rap_data <- vroom("~/data/CRP/data_participant.tsv.gz", guess_max = 1e5) %>%
  janitor::clean_names() %>%
  select(-contains("opcs"))


colnames(rap_data)
rap_death <- vroom("~/data/CRP/data_death.tsv.gz") %>%
  janitor::clean_names() %>%
  select(eid = participant_id, date_of_death)

covariates <- rap_data %>%
  mutate(study_entry = date_of_attending_assessment_centre_instance_0) %>%
  mutate(history_stroke = case_when(ymd(date_of_stroke) < study_entry ~1 , TRUE ~ 0)) %>%
  mutate(history_MI = case_when(ymd(date_of_myocardial_infarction) < study_entry ~1 , TRUE ~ 0)) %>%
  mutate(history_asthma = case_when(ymd(date_of_asthma_report) < study_entry ~1 , TRUE ~ 0)) %>%
  mutate(history_dementia = case_when(ymd(date_of_all_cause_dementia_report) < study_entry ~1 , TRUE ~ 0)) %>%
  mutate(history_copd = case_when(ymd(date_of_chronic_obstructive_pulmonary_disease_report) < study_entry ~1 , TRUE ~ 0)) %>%
  mutate(history_liver = case_when(ymd(date_k70_first_reported_alcoholic_liver_disease) < study_entry ~1,
                                     ymd(date_k71_first_reported_toxic_liver_disease) < study_entry ~1,
                                     ymd(date_k74_first_reported_fibrosis_and_cirrhosis_of_liver) < study_entry ~1,
                                     ymd(date_k75_first_reported_other_inflammatory_liver_diseases) < study_entry ~1,
                                     ymd(date_k76_first_reported_other_diseases_of_liver) < study_entry ~1,
                                     ymd(date_k77_first_reported_liver_disorders_in_diseases_classified_elsewhere) < study_entry ~1,
                                      TRUE ~ 0)) %>%
  mutate(future_stroke = case_when(ymd(date_of_stroke) > study_entry ~1 , TRUE ~ 0)) %>%
  mutate(future_MI = case_when(ymd(date_of_myocardial_infarction) > study_entry ~1 , TRUE ~ 0)) %>%
  
  mutate(history_cancer = if_else(is.na(cancer_code_self_reported_instance_0),0,1)) %>%
  mutate(diastolic_bp = (diastolic_blood_pressure_automated_reading_instance_0_array_0 + diastolic_blood_pressure_automated_reading_instance_0_array_1)/2) %>%
  mutate(systolic_bp = (systolic_blood_pressure_automated_reading_instance_0_array_0 + systolic_blood_pressure_automated_reading_instance_0_array_1)/2) %>%
  select(-contains("instance_1"), -contains("instance_2"), -contains("array")) %>%
  select(-contains("date")) %>%
  mutate(age_at_entry = year(study_entry) - year_of_birth) %>%
  rename(eid = participant_id) %>%
  left_join(rap_death) 


colnames(covariates) <- colnames(covariates) %>%
  str_remove("_instance_0")


colnames(covariates)
vroom_write(covariates, "~/data/CRP/covariates_cleaned_rap.tsv.gz")
