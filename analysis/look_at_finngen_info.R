pacman::p_load(tidyverse, vroom, janitor)
# bring in finngen data 

# tabix -h https://storage.googleapis.com/finngen-public-data-r8/annotations/R8_sisuv4_annotated_variants_v1.gz 1:159714024-159714999 > crp_finngen.tab
# tabix -h https://storage.googleapis.com/finngen-public-data-r8/annotations/R8_sisuv4_annotated_variants_v1.gz 1:154454494-154454494 > crp_finngen_common.tab

finngen <- vroom("~/Downloads/crp_finngen.tab")
finngen_common <- vroom("~/Downloads/crp_finngen_common.tab")
common <-finngen_common %>%
  clean_names() %>%
  select(contains("ac")) %>%
  pivot_longer(everything()) %>%
  arrange(desc(value)) %>%
  transmute(name = str_remove(name, "ac_het_"), ac_common = value)
colnames(finngen_common)

  
ac <- finngen %>%
  clean_names() %>%
  select(contains("ac")) %>%
  pivot_longer(everything()) %>%
  arrange(desc(value)) %>%
  transmute(name = str_remove(name, "ac_het_"), ac = value)

finngen$INFO
info <-finngen %>%
  clean_names() %>%
  select(contains("INFO")) %>%
  pivot_longer(everything()) %>%
  arrange(desc(value)) %>%
  transmute(name = str_remove(name, "info_"), info = value)

ac %>%
  inner_join(info) %>%
  inner_join(common) %>%
  arrange(desc(ac)) %>%
  ggplot(aes(x = ac_common/0.300, y = info)) +
  geom_point()


ac %>%
  inner_join(info) %>%
  inner_join(common) %>%
  arrange(desc(ac)) %>%
  mutate(total_count = ac_common/0.30027) %>%
  mutate(info_weighted = info * total_count) %>%
  summarise(sum_total_count = sum(total_count), sum_info_weighted = sum(info_weighted)) %>%
  mutate(info_overall = sum_info_weighted/sum_total_count)
