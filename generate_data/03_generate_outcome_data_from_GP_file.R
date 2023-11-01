#run once to generate the outcome data: 
#Directly from UKB mapping file
gp_clinical_data <- vroom("/Volumes/MRC-IEU-research/projects/ieu1/wp3/030/working/data/pheno/clinical_diagnosis/2021/gp_clinical.txt.gz")
read_3 <- vroom("~/data/CRP/read_3_icd_map.txt")
read_2 <- vroom("~/data/CRP/read_2_icd_map.txt")
transplant <-vroom("~/data/CRP/data_hesin_oper.tsv.gz")
read_3_d <- gp_clinical_data %>%
  select(eid, event_dt, read_3) %>%
  drop_na(read_3) %>%
  left_join(read_3) %>%
  drop_na(icd10) %>%
  select(-read_3)
  

read_2_d <-gp_clinical_data %>%
  select(eid, event_dt, read_2) %>%
  drop_na(read_2) %>%
  left_join(read_2) %>%
  drop_na(icd10)%>%
  select(-read_2)

read_2_d %>%
  bind_rows(read_3_d) %>%
  distinct() %>%
  vroom_write("~/data/CRP/icd_10_added_primary_care_events.tsv.gz")




data <- vroom("~/data/CRP/zekevat_infection.txt")
codes <- data %>%
  clean_names() %>%
  select(organ_system, category,description) %>%
  mutate(description = (str_remove(description, "Date "))) %>%
  mutate(icd10_short = substr(description, 1,3))

primary_care_infection <- vroom("~/data/CRP/icd_10_added_primary_care_events.tsv.gz")
infection_only_codes_prim_care <- primary_care_infection %>%
  mutate(icd10_short = substr(icd10, 1,3)) %>%
  filter(str_detect(icd10_short, paste(codes$icd10_short, collapse = "|"))) %>%
  left_join(codes)

primary_care_infection %>%
  filter(str_detect(icd10, "A16")) %>%
  count(eid)

infection_only_codes_prim_care %>%
  vroom_write("~/data/CRP/primary_care_icd_10_infections_only.tsv.gz")

hes <- vroom("~/data/CRP/hes_icd_added.txt.gz")

hes %>%
  mutate(icd10_short = substr(meaning, 1,3)) %>%
  filter(str_detect(icd10_short, paste(codes$icd10_short, collapse = "|"))) %>%
  left_join(codes) %>%
  vroom_write("~/data/CRP/HES_icd_10_infections_only.tsv.gz")


#make transplant list

transplant_list <- c("M01|E53|J01|J54|K01|K01|X33.4|X33.5|X33.6")
codes <- read_csv("~/Desktop/codes.csv")
codes_to <- codes$opcs4%>%
  str_remove("\\*") %>%
  str_remove("\\.")

codes_to
rap_data <- vroom("~/data/CRP/data_participant.tsv.gz", guess_max = 1e5) %>%
  janitor::clean_names() %>%
  select(participant_id,contains("opcs"))


transplant_only <- rap_data %>%
  
  filter(str_detect(operative_procedures_opcs4, paste(codes_to, collapse = "|"))) %>%
  separate(operative_procedures_opcs4, sep = "\\|", paste0("op_only", 1:60)) %>%
  select(participant_id, contains("op_only")) %>%
  pivot_longer(-participant_id) %>%
  filter(str_detect(value, paste(codes_to, collapse = "|"))) %>%
  mutate(name = as.numeric(str_remove(name, "op_only")))

codes_to <- codes$icd10%>%
  str_remove("\\*") %>%
  str_remove("\\.")

hes %>%
  filter(eid %in% transplant_only$participant_id) %>%
  filter(str_detect(meaning, paste(codes_to, collapse = "|"))) %>%
  count(meaning, sort = T) %>%
  gt::gt()

transplant_only



transplant_dates <- rap_data %>%
  select(participant_id, contains("array")) %>%
  pivot_longer(-participant_id) %>%
  mutate(name = as.numeric(str_remove(name, "date_of_first_operative_procedure_opcs4_array_"))) %>%
  drop_na(value) %>%
  rename(transplant_date = value)

transplant_dates
mr(dat)



opcs_transplant <- transplant_only %>%
  left_join(transplant_dates) %>%
  drop_na(transplant_date)  %>%
  select(eid = participant_id, transplant_date) 
  
hes_transplant <-hes %>%
  filter(str_detect(meaning, "Z94")) %>%
  select(eid, transplant_date = event_dt) %>%
  mutate(transplant_date = dmy(transplant_date))
  
primary_transplant <-primary_care_infection %>%
  filter(str_detect(icd10, "Z94")) %>%
  select(eid, transplant_date = event_dt) %>%
  mutate(transplant_date = dmy(transplant_date))

 bind_rows(opcs_transplant, hes_transplant, primary_transplant) %>%
 
  arrange(transplant_date) %>%
  group_by(eid) %>%
  slice(1) %>%
  ungroup() %>%
   vroom::vroom_write("~/data/CRP/transplant_list.tsv.gz")
  
 

 
 
z<-  bind_rows(opcs_transplant, hes_transplant, primary_transplant) %>%
   
   arrange(transplant_date) %>%
   group_by(eid) %>%
   slice(1) %>%
   ungroup() %>% 
 left_join(final) %>%
  mutate(time_to_death = as.numeric(difftime(date_of_death, study_entry, units = "days"))) %>%
  mutate(time_event_infection= if_else(is.na(date_of_death), time_event_infection, time_to_death)) 
 prim_crp <- vroom("~/data/CRP/primary_care_crp.tsv.gz")


 transplant_only %>%
   filter(name>30) %>%
   count(name)




