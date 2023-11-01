#!/bin/bash

#SBATCH --job-name=PHEWAS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --time=72:00:00
#SBATCH --mem=32G
#SBATCH --account=sscm013902

cd /user/work/fh6520/ukbpheno/PHESANT/WAS

module load lang/r


# to generate confounders - ./ukbconv ukb49504.enc_ukb csv -iphewas_confunders.txt -ofinal_confounders (54, 31, 22009)
# then remove the CSVs tr -d '"' <a.csv >b.csv
#then switch f to x... using sed magic

# this is the standard script, with genetic data, controlling for confounders (PCA, sex, assessment centre)

###OVERALLL


#run for the ALLELE

Rscript phenomeScan.r --phenofile="//user/work/fh6520/ukbpheno/ukb4904_numbers.tab" \
 --confounderfile="//user/work/fh6520/ukbpheno/confounders/final_confounders_no_assessment_centre.csv" \
 --traitofinterestfile="//user/work/fh6520/ukbpheno/final_genotype/CRP_rare_var_PHESANT.csv" \
 --variablelistfile="../variable-info/outcome-info.tsv"\
 --datacodingfile="../variable-info/data-coding-ordinal-info.txt"\
 --traitofinterest="rare_var_CRP"\
 --standardise=TRUE \
 --resDir="/user/work/fh6520/ukbpheno/results/CRP/"\
 --userId="eid" --partIdx=1 --numParts=50 --tab=TRUE --mincase=50