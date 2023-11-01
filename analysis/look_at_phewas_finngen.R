pacman::p_load(tidyverse, vroom, janitor, data.table, ggforestplot)
manifest <- fread("~/data/CRP/finngen/R8_manifest.tsv")
manifest <- manifest %>%
  select(condition = phenocode, name, num_cases, num_controls)
finngen <- fread("~/data/CRP/finngen/crp_finngen_rare_var_only.tab.gz")
finngen2 <-finngen %>%
  as_tibble() %>%
  select(pval = V7,
         beta = V9, 
         sebeta = V10,
         af_alt_cases = V12, 
         condition = V14) %>%
  mutate(condition = str_remove(condition, "finngen_R8_")) %>%
  left_join(manifest) %>%
  filter(af_alt_cases >0) %>% 
  filter(num_cases >10000) %>%
  mutate(fdrp = p.adjust(pval, method = "fdr")) %>%
  mutate(cases = af_alt_cases * num_cases)  %>%
  arrange(pval) 


finngen2 %>% v
finngen2 %>%
  arrange(beta) %>%
  filter(str_detect(condition, "J10_LOW|PULM_INFECTIONS|AB1_BACTINF_NOS|J10_PNE")) %>%
  forestplot(name = name,
             estimate = beta,
             se = sebeta,
             logodds = T)

finngen2 %>%
  arrange(pval) %>%
  arrange(-beta) %>%
  head(20) %>%
  forestplot(name = name,
             estimate = beta,
             se = sebeta,
             logodds = T)


finngen2 %>%
  arrange(beta) %>%
  filter(str_detect(condition, "J10_LOW|PULM_INFECTIONS|AB1_BACTINF_NOS|J10_PNE")) %>%
  mutate(upper = exp(beta + 1.96*sebeta),
         lower = exp(beta - 1.96*sebeta),
         or = exp(beta))

x <- TwoSampleMR::extract_instruments("ukb-d-30710_irnt")  
library(tidyverse)
x %>%
  as_tibble()%>%
  arrange(pval.exposure) %>%
  view()

(log(4.13) - log(0.45))/3.92

m <- meta::metagen(c(0.99, 0.27), c(0.86, 0.56))
m
tibble(te = c(0.99, 0.27, 0.56),
       se = c(0.82, 0.56, 0.47),
       name = c("Finn", "UKB", "MA")) %>%
  forestplot(name = name, 
             estimate= te,
             se = se, logodds = T)

