pacman::p_load(tidyverse, data.table)
rare_var <- data.table::fread("~/data/CRP/exome/called_rare_var.raw.gz")
linker_IEU <- data.table::fread("~/data/CRP/ref_link/eids_merge.tsv.gz")
linker_MY <- data.table::fread("~/data/CRP/ref_link/linker_MY_APP.csv.gz")
rare_var <- rare_var %>%
  clean_names() %>%
  as_tibble() %>%
  select(participant_id = fid, contains("x1")) %>%
  mutate(participant_id = as.numeric(participant_id)) %>%
  select(rare_var_CRP = x1_159714024_g_a_a, participant_id) %>%
  left_join(linker_IEU) %>%
  drop_na(eid) %>%
  select(eid, rare_var_CRP)

rare_var %>%
  filter(rare_var_CRP !=2) %>%
  write_csv("~/data/CRP/exome/CRP_rare_var_PHESANT.csv")
