library(TwoSampleMR)
library(nephro)




final %>%
  sample_n(10000) %>%
  ggplot(aes(x = log(egfr_cys_cr), y = log(cystatin_c)))+
  geom_point() +
  geom_smooth(method = lm) 


final %>%
  add_count(eid) %>%
  filter(n ==1) %>%
  drop_na(c_reactive_protein, study_entry) %>%
  distinct(c_reactive_protein, creatinine, body_mass_index_bmi, albumin, calcium, year_of_birth) 

cys_m <- lm(log(cystatin_c) ~ log(egfr_cys_cr), data = final)
cys_dat <- final %>%
  drop_na(cystatin_c, egfr_cys_cr) %>%
  mutate(resid = cys_m$residuals)


ao <- available_outcomes()

final <- final %>%
  mutate(sex_b = if_else(sex == "Male",1,0), 
         ethnicity = 0)
snp <- extract_instruments("ieu-a-835")
outcomes <- extract_outcome_data(snp$SNP, "ukb-d-30720_irnt")
dat <- harmonise_data(snp, outcomes)
mr(dat)

mi <- rap_data %>%
  select(eid = participant_id, date_of_myocardial_infarction, date_of_attending_assessment_centre_instance_0) %>%
  mutate(history_MI = case_when(ymd(date_of_myocardial_infarction) > date_of_attending_assessment_centre_instance_0 ~1 , TRUE ~ 0)) %>% 
  select(eid, mi_event = history_MI)

final <- final %>%
  left_join(mi)
m <- glm(had_pneumonia~ scale(resid) + scale(log(cystatin_c)), data = cys_dat, family = "binomial")

m <- glm(had_infection~ scale(log(cystatin_c)) +  scale(egfr_cre) + GlycA_scaled + scale(age_at_entry) + sex + log(c_reactive_protein) +  body_mass_index_bmi + S_HDL_C_scaled + scale(resid) + townsend_deprivation_index_at_recruitment +ever_smoked  + history_MI + history_stroke, data = cys_dat, family = "binomial")
summary(m)
with(summary(m), 1 - deviance/null.deviance)
  
177.6 * creatinine^-0.65 * cystatin_c^-0.57 * age^-0.2

sd(cys_dat$resid)
cor(cys_dat$resid, cys_dat$egfr_cys_cr)

final$creatinine
final <- final %>% mutate(
egfr_cys = CKDEpi.cys(final$cystatin_c, final$sex_b, final$age_at_entry),
egfr_cre = CKDEpi.creat(final$creatinine/88.4, final$sex_b, final$age_at_entry, final$ethnicity),
egfr_cys_cr = CKDEpi.creat.cys(final$creatinine/88.4, final$cystatin_c, final$sex_b, final$age_at_entry, final$ethnicity))
eGFR$CKDEpi.creat.cys <- CKDEpi.creat.cys(creat, cyst, sex, age, ethn)