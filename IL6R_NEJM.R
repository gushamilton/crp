pacman::p_load(tidyverse, ggforestplot, meta, patchwork, TwoSampleMR, vroom, extrafont)
x <- vroom("https://github.com/gushamilton/il6-sepsis/raw/main/data/final_mr_results.tsv")
exps <- vroom("https://raw.githubusercontent.com/gushamilton/il6-sepsis/main/data/harmonised_data_final.tsv")
conversions <- read_csv("~/R/il6-toci/conversions.csv")

ivw <- function(df) {
  TE = df$b
  SE = df$se
  m1 <- metagen(TE, SE) 
  tibble(estimate = m1$TE.fixed,
         std.error= m1$seTE.fixed,
         het = m1$pval.Q,
         pval = m1$pval.fixed,
         lower = m1$lower.fixed,
         upper = m1$upper.fixed)
  
}


d <- vroom("~/data/CRP/GWAS/GCST90029070_buildGRCh37.tsv.gz")
scores <-d %>%
  filter(p_value < 5E-8) %>%
  # filter(chromosome == 2 & p_value < 5E-8) %>%
  # filter(base_pair_location > 113832333 - 3E5) %>%
  # filter(base_pair_location < 113832333 + 3E5) %>%
  rename(SNP = variant_id, pval.exposure = p_value, beta.exposure = beta, se.exposure = standard_error, effect_allele.exposure = effect_allele, other_allele.exposure = other_allele) %>%
  clump_data(clump_r2 = 0.01) %>%
  mutate(eaf.exposure = NA) %>%
  arrange(pval.exposure) %>%
  mutate(exposure = "cisCRP", id.exposure = "cisCRP")


dat <- harmonise_data(scores, geno_d)
mr(dat)
geno <- vroom("/Users/fh6520/Downloads/cap/GenOSept.CAP.snptest.stats.gz")

geno_d <- geno %>%
  select(SNP = rsid,
         effect_allele.outcome =alleleB,
         other_allele.outcome = alleleA,
         info,
         eaf.outcome = all_maf,
         beta.outcome = frequentist_add_beta_1,
         se.outcome = frequentist_add_se_1,
         pval.outcome = frequentist_add_pvalue) %>%
  mutate(outcome = "Geno", id.outcome = "Geno")

exposure <- exp %>%
  select(SNP, contains("exposure")) %>%
  filter(exposure == "cisIL6R") %>%
  distinct()




outcome <- extract_outcome_data(scores$SNP, "ieu-b-4980")
dat <- harmonise_data(scores, geno_d)
mr(dat)
pneumo <- mr(dat) %>%
  filter(method == "Inverse variance weighted") %>%
  mutate(name = "Pneumonia (28 day death)")



d <- x %>%
  filter(exposure == "cisIL6R") %>%
  filter(method == "Inverse variance weighted") %>%
  
  left_join(conversions) %>%
  mutate(name = if_else(id.outcome == "finngen_R6_J10_PNEUMONIA.gz", "Pneumonia (FinnGen)", name)) %>%
  
  filter(str_detect(name, "CAP")) 





name2 <- c("Hospitalised pneumonia (FinnGen)", "Death from hospitalised pneumonia (UKB)", "Hospitalised pneumonia (UKB)", "Critical care pneumonia (UKB)", "Death from critical care pneumonia (UKB)", "Death from critical care pneumonia (GenOSept)", "Death from critical care pneumonia (GAiNS)", "")
p1 <- x %>%
  filter(exposure == "cisIL6R") %>%
  filter(method == "Inverse variance weighted") %>%

  left_join(conversions) %>%
  mutate(name = if_else(id.outcome == "finngen_R6_J10_PNEUMONIA.gz", "Pneumonia (FinnGen)", name)) %>%

  
  filter(str_detect(name, "Pneum|CAP|Dea")) %>%
  mutate(name = str_remove(name, "\\(CAP subset\\)")) %>%
  bind_rows(pneumo) %>%
  arrange(-b) %>%
  bind_rows(blank) %>%
  mutate(upper = signif(exp(b + 1.96*se), 2),
         lower = signif(exp(b - 1.96*se), 2),
         bx= signif(exp(b), 2)
         ) %>%
  mutate(name = paste0(name2, "\n OR: ", bx, " (", lower, " - ", upper, ")")) %>%
  ggforestplot::forestplot(name = name, estimate = b, se = se, logodds = T) +
  theme_bw() +
  xlab("Odds ratio for each outcome with increasing IL6R antagonism (95% CI)") +
  scale_x_log10() +
  theme(axis.text = element_text(face="bold"))


p1 

p2 <- ggplot() +
  geom_segment(aes(x=0.8, xend=0.001, y=1, yend=1), 
               arrow = arrow(length = unit(0.5, "cm"))) +
  geom_segment(aes(x=1.2, xend=4, y=1, yend=1), 
               arrow = arrow(length = unit(0.5, "cm"))) +
  theme_void()  +
  scale_x_log10()


p1/p2
ggview(height = 8, width = 9)
ggsave(height = 8, width = 9, "Figure1_nejm.tiff", bg = "white", compression = "lzw+p")
font_import()
dat_forest <- x %>%
  filter(exposure == "cisIL6R") %>%
  filter(method == "Inverse variance weighted") %>%
  
  left_join(conversions) %>%
  mutate(name = if_else(id.outcome == "finngen_R6_J10_PNEUMONIA.gz", "Pneumonia (FinnGen)", name)) %>%
  
  filter(str_detect(name, "Pneum|CAP")) %>%
  arrange(-b) %>%
  mutate(lower_ci = b-se*1.96, upper_ci = b+se*1.96) %>%
  mutate(across(c(b, lower_ci, upper_ci), exp))


dat_forest

colnames(dat_forest)

x <- c("a", "b", "c", "d", "e", "f")
dat_forest <- dat_forest %>%
  mutate(table = x, table2 = "")
p <- forester::forester(dat_forest[,c(18,17)], 
                   estimate = dat_forest$b,
                   ci_low = dat_forest$lower_ci,
                   ci_high = dat_forest$upper_ci,
                   xlim = c(0.0001,5),
                   estimate_col_name = "Odds Ratio (95% CI)",
                   display = T,
                   estimate_precision = 2, 
                   ggplot_width = 50,
    
                   x_scale_linear = F,
                   null_line_at = 1,
                   arrows = TRUE, 
                   font_family = "sans",
                   arrow_labels = c("IL-6 inhibition better", "IL-6 inhibition worse"),
                   nudge_height = 0,
                   nudge_x = 0) 
  scale_x_log10()


  ggview(width =30, height = 5)

library(forestploter)

forest(dat_forest[,c(11,12)],
       est = dat_forest$b,
       lower = dat_forest$lower_ci,
       upper = dat_forest$upper_ci,
       ci_column = 2,
       ref_line = 1,
       xlim = c(0.0001, 4),
       )
p2 <- x %>%
  filter(exposure == "cisCRP") %>%
  filter(method == "Inverse variance weighted") %>%
  left_join(conversions) %>%
  filter(group == "gains") %>%
  filter(!str_detect(name, "CAP")) %>%
  mutate(b = -b) %>%
  arrange(-b) %>%
  ggforestplot::forestplot(name = name, estimate = b, se = se, logodds = T) +
  theme_bw() +
  xlab("Odds ratio (95% CI)")


p3 <- x %>%
  filter(exposure == "cisCRP") %>%
  filter(method == "Inverse variance weighted") %>%
  left_join(conversions) %>%
  filter(group == "crit") %>%
  filter(!str_detect(name, "CAP")) %>%
  mutate(b = -b) %>%
  arrange(-b) %>%
  ggforestplot::forestplot(name = name, estimate = b, se = se, logodds = T) +
  theme_bw() +
  xlab("Odds ratio (95% CI)")

((p2/p3) | p1) + plot_annotation(tag_levels = "A")

