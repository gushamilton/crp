pacman::p_load(tidyverse, vroom, survival, lubridate)
  
data <- vroom("~/data/CRP/zekevat_infection.txt")
data %>%
  clean_names() %>%
  select(organ_system, category,description) %>%
  mutate(description = (str_remove(description, "Date "))) %>%
  mutate(icd10 = substr(description, 1,3))

         