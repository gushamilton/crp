pacman::p_load(tidyverse, vroom, TwoSampleMR)
d <- vroom("~/data/CRP/GWAS/GCST90029070_buildGRCh37.tsv.gz")
scores <-d %>%
  filter(chromosome == 1 & p_value < 5E-8) %>%
  filter(base_pair_location > 159682079 - 3E5) %>%
  filter(base_pair_location < 159684379 + 3E5) %>%
  rename(SNP = variant_id, pval.exposure = p_value, beta.exposure = beta, se.exposure = standard_error, effect_allele.exposure = effect_allele, other_allele.exposure = other_allele) %>%
  clump_data(clump_r2 = 0.01) %>%
  mutate(eaf.exposure = NA) %>%
  arrange(pval.exposure) %>%
  mutate(exposure = "cisCRP", id.exposure = "cisCRP")

ao <- available_outcomes()
outcomes <- extract_outcome_data(scores$SNP, c("ieu-b-4976", "ieu-b-4977", "ieu-b-4978", "ieu-b-4979"))

scores %>%
  select(SNP, effect_allele, beta) %>%
  write_tsv("~/data/CRP/GWAS/common_variants.tsv", col_names = F)

dat <- harmonise_data(scores, outcomes)
res <- mr(dat, method = "mr_ivw")
res
snps <- c("rs3093077","rs1205","rs1130864","rs1800947")

d %>%
  filter(variant_id %in% snps) %>%
  rename(SNP = variant_id, pval.exposure = p_value) %>%
  select(SNP, effect_allele, beta) %>%
  write_tsv("~/data/CRP/GWAS/common_variants_PROMOTER.tsv", col_names = F)


scores <-d %>%
  filter(p_value < 1E-8) %>%
  rename(SNP = variant_id, pval.exposure = p_value) %>%
  clump_data(clump_r2 = 0.01) %>%
  arrange(pval.exposure)


scores %>%
  select(SNP, effect_allele, beta) %>%
  view()
  write_tsv("~/data/CRP/GWAS/common_variants_GENOME.tsv", col_names = F)



# plink2 --bgen $UKBIOBANK_DATA/data.chr01.bgen --sample $UKBIOBANK_DATA/data.chr1-22_plink.sample --score common_variants.tsv
 # plink2 --bgen $UKBIOBANK_DATA/data.chr01.bgen --sample $UKBIOBANK_DATA/data.chr1-22_plink.sample --score common_variants_PROMOTER.tsv