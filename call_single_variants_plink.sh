UKB RAP

plink --vcf ukb23352_c1_b3194_v1.vcf.gz --make-bed --out ex3


plink --vcf ukb23157_c1_b61_v1.vcf.gz --chr 1 --from-bp 159714024 --to-bp 159714024 --recode AD --out called_rare_var 
file-G9806VjJykJf2vJ1KKGg6bgx

plink --vcf ukb23157_c1_b62_v1.vcf.gz --chr 1 --from-bp 159714024 --to-bp 159714024 --recode AD --out called_rare_var 

plink --bfile ukb23158_c1_b0_v1 --chr 1 --from-bp 159714023 --to-bp 159714025 --recode AD --out called_rare_var 
# First generate a set of merged files


# cat ex,ex2,ex3
module load apps/plink/1.90
plink --merge-list merge_list --make-bed --out merged_crp_il6r_rare_variants

#Then use the genebass data to

plink --bfile merged_crp_il6r_rare_variants \
      --extract range CRP_rare_variants \
      --recode AD --out called_rare_var 