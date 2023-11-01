pacman::p_load(tidyverse,vroom,TwoSampleMR)


# exposures 


decode <- vroom("/Users/fh6520/saa/15515_2_SAA1_SAA.txt.gz")
finngen <- vroom("/Users/fh6520/data/CRP/finngen/saa.tsv.gz", col_names = F)

cis_snps <- decode %>%
  filter(Chrom == "chr11") %>%
  filter(Pos > 18266260 - 3e5) %>%
  filter(Pos < 18269977 + 3e5) %>%
  select(SNP = rsids,
         Pos,
         pval.exposure = Pval,
         beta.exposure = Beta,
         se.exposure = SE,
         eaf.exposure = ImpMAF,
         effect_allele.exposure = effectAllele,
         other_allele.exposure = otherAllele) %>%
  filter(pval.exposure < 5e-8) %>%
  arrange(pval.exposure) %>%
  filter(SNP %in% finngen$X5) %>%
  clump_data(clump_r2 = 0.01)

cis_snps %>%
  mutate(exposure = "SAA1") -> cis_snps


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
  mutate(id.outcome = outcome) %>%
  filter(SNP %in% cis_snps$SNP)

cis_d <- cis_snps %>%
  filter(SNP != "rs11024662")

outcomes_infection <- outcomes %>%
  filter(str_detect(outcome, "SEPS"))

dat <- harmonise_data(cis_d, outcomes)
res <- mr(dat, method = "mr_ivw")
pneu <- extract_outcome_data(cis_d$SNP, "ieu-b-4976")
dat <- harmonise_data(cis_d, pneu)
mr(dat)
qqman::qq(res$pval)
