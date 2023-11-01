pacman::p_load(tidyverse, vroom, janitor, data.table)

#Bring in data from RAP = CRP

my <- fread("~/data/CRP/ref_link/direct_dl/MY_app_data_link.tsv.gz") %>%
  clean_names() %>%
  drop_na(genetic_principal_components_array_1) %>%
  select(participant_id, contains("genetic")) %>%
  rename(eid = participant_id) %>%

  distinct()
ieu <- fread("~/data/CRP/ref_link/direct_dl/IEU_app_data_link.tsv.gz") %>%
  clean_names() %>%
  drop_na(genetic_principal_components_array_1) %>%
  distinct()

d <- my %>%
  head(1e6) %>%

  left_join(ieu)




d %>%
  select(eid, participant_id) %>%
  vroom_write("~/data/CRP/ref_link/eids_merge.tsv.gz")
