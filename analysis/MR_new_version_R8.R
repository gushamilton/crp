# load required libraries
library(TwoSampleMR)
library(tidyverse)
library(vroom)

outcome_p <- vroom("https://raw.githubusercontent.com/gushamilton/il6-sepsis/main/data/harmonised_data_final.tsv") %>%
  select(SNP, contains("outcome")) %>%
  distinct() %>%
  mutate(id.outcome = outcome)


crp_d <- data.table::fread("~/data/CRP/gwas/GCST90029070_buildGRCh37.tsv.gz") %>%
  select(SNP = variant_id, effect_allele.exposure = effect_allele, other_allele.exposure = other_allele, beta.exposure = beta, se.exposure = standard_error, pval.exposure = p_value, chromosome, base_pair_location) %>%
  as_tibble() %>%
  mutate(eaf.exposure = NA) 

SNPS <- c("rs3093077", "rs1205", "rs1130864", "rs1800947") 
crp <- crp_d %>%
  filter(SNP %in% SNPS) %>%
  mutate(exposure = "crp", id.exposure = "crp") %>%
  mutate(eaf.exposure = if_else(SNP == "rs1800947", 0.95, eaf.exposure))



dat <- harmonise_data(crp, outcome_p)
d <- mr(dat, method = "mr_ivw")
d %>%
  view()
finngen <- vroom("~/data/CRP/finngen/crp_finngen_whole_region_every.tab.gz", col_names= FALSE)
outcomes <- finngen %>%
  as_tibble() %>%
  select(SNP = X5,
         pval.outcome = X7,
         beta.outcome = X9,
         se.outcome = X10,
         eaf.outcome = X11,
         outcome = X14,
         effect_allele.outcome = X4,
         other_allele.outcome = X3) %>%
  mutate(id.outcome = outcome)

outcomes %>%
  filter(SNP == "rs3093077") %>%
  view()
  arrange(pval.outcome)
exposure <- exposure %>%
  select(SNP, contains("exposure")) %>%
  filter(exposure == "cisCRP") %>%
  distinct()

outcomes %>%
  arrange(pval.outcome) %>%
  select(outcome)

dat <- harmonise_data(crp, outcomes, action = 2)

res <- mr(dat, method = "mr_ivw")
res %>%
  mutate(bonp = p.adjust(pval, method = "bonferroni")) %>%
  view()
qqman::qq(res$pval)

pneum <- dat %>%
  filter(outcome == "finngen_R8_AB1_OTHER_BACTERIAL") 
res <- mr(pneum)


res %>%
  filter(pval <0.05) %>%
  arrange(-b) %>%
  head(20) %>%
  mutate(outcome = str_remove(outcome, "finngen_R8_")) %>%
  ggforestplot::forestplot(
    name = outcome,
    estimate = b,
    se = se,
    logodds = T
  ) +
  xlab("Odds ratio (95% CI)")

p <- mr_scatter_plot(res, pneum) 
p$crp.finngen_R8_AB1_OTHER_BACTERIAL + theme_bw() + theme(legend.position = "top")


crp <- crp_d %>%
  filter(!(chromosome == 1 & base_pair_location < (159714024 + 1e5) & base_pair_location > (159714024 -1e5) )) %>%
    mutate(pval.exposure = as.double(pval.exposure)) %>%
  filter(pval.exposure <5e-8) %>%
  clump_data()

crp %>%
  arrange(chromosome) %>%
  transmute(file = paste0("chr",chromosome, ":", base_pair_location,"-",base_pair_location)) %>%
  write.table("crp_across_genome.tsv", row.names = F, quote = F)


x <- vroom::vroom("~/Downloads/hglft_genome_1aa8e_9221e0.bed", col_names = F)
x %>%
  mutate(X1 = str_remove(X1, "chr")) %>%
  transmute(file = paste0(X1,":",X2)) %>%
  write.table("crp_across_genome.tsv", row.names = F, quote = T)
  
