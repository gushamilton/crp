pacman::p_load(tidyverse, data.table, TwoSampleMR, vroom)
SAA <- vroom("~/saa/15515_2_SAA1_SAA.txt.gz", col_select = c(rsids, Chrom, Pos, effectAllele, otherAllele,Beta,Pval,SE,ImpMAF)) %>%
  as_tibble()
exposure <- SAA %>%
  select(SNP = rsids,
         effect_allele.exposure = effectAllele,
         other_allele.exposure = otherAllele,
         beta.exposure = Beta,
         pval.exposure = Pval,
         se.exposure = SE,
         eaf.exposure = ImpMAF,
         Chrom,
         Pos,
         ) %>%
  filter(Chrom == "chr11") %>%
  filter(pval.exposure <5e-8) %>%
  clump_data(clump_r2 = 0.1) 

exposure <- exposure %>% mutate(exposure = "SAA")
exposure %>%
  view()
outcomes <- extract_outcome_data(exposure$SNP, "met-d-M_HDL_C")
dat <- harmonise_data(exposure, outcomes)
mr(dat)
