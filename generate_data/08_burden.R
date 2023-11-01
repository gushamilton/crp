pacman::p_load(tidyverse, vroom, janitor, data.table)

#Bring in data from RAP = CRP


burden <- fread("~/data/CRP/annotations/called_burden.raw.gz")

total <- burden %>%
  mutate(sum = rowSums(na.rm = T,across(7:318))) %>%
  select(FID, sum)

# total <- burden %>%
#   mutate(sum = rowSums(na.rm = T,across(7:318))) %>%
#   select(FID, sum)


included <-total %>%
  filter(sum == 4)
homs <- burden %>%
  select(1, 7:318) %>%
  pivot_longer(-FID) %>%
  filter(value == 2)
homs
         
hets <- burden %>%
  select(1, 7:318) %>%
  pivot_longer(-FID) %>%
  filter(value == 1)  %>%
   filter(!str_detect(name, "159714024")) %>%
  add_count(FID)


hets2 <- hets %>%
  filter(n == 2) %>%
  count(FID)

homs
hets %>%
  count(FID, sort = T)
calls <- total %>%
  select(FID) %>%
  mutate(hom_burden = if_else(FID %in% homs$FID,1,0),
         het_burden = if_else(FID %in% hets2$FID,1,0))

d <- calls %>%
  rename(participant_id = FID) %>%
  drop_na(participant_id) %>%
  left_join(linker_IEU) %>%
  left_join(final) %>%
  left_join(principle_components)


homs %>%
  count(name)

d %>%

  group_by(het_burden) %>%
  summarise(mean = mean(c_reactive_protein, na.rm = T), n = n())
m <- glm(had_infection~ het_burden + PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PC7 + PC8 + PC9 + PC10 + age_at_entry + sex , data = d, family = "binomial")
tidy(m)



run_table_gen <- function(x, y) {
  
  
  f <- as.formula(sprintf(paste0(x, "~ as.factor(het_burden) + PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PC7 + PC8 + PC9 + PC10 + age_at_entry + sex + uk_biobank_assessment_centre")))
  m <- (coxph(formula = f, data = d))
  m2 <- tidy(m, exponentiate = T, conf.int = T) %>% mutate(model = y) 
  return(m2)
}

tab2 <- bind_rows(
  run_table_gen("Surv(time_event_infection, had_infection)", "Infection"),
  run_table_gen("Surv(time_event_pneumonia, had_pneumonia)", "Pneumonia"),
  run_table_gen("Surv(time_event_sepsis, had_sepsis)", "Sepsis"),
  
  run_table_gen("Surv(time_event_death_censor, infection_death)", "Infection death"),
  run_table_gen("Surv(time_event_death_censor, pneumonia_death)", "Pneumonia death"),
  run_table_gen("Surv(time_event_death_censor, sepsis_death)", "Sepsis death")
  
)

tab2 %>%
  filter(str_detect(term, "het_burden")) %>%
  mutate(across(c(estimate,conf.low, conf.high, p.value),~ signif(.x, digits = 3))) %>%
  transmute(model, estimate = paste0(estimate, " (", conf.low, "-",conf.high,")"), p.value, term) %>%
  group_by(model) %>%
  gt::gt()

d$ukb
d %>%
  count(hom_burden, had_pneumonia)
