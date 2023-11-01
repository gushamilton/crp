wget https://storage.googleapis.com/finngen-public-data-r8/summary_stats/R8_manifest.tsv
cut -f 7 R8_manifest.tsv  > to_download
tabix -H https://storage.googleapis.com/finngen-public-data-r8/summary_stats/finngen_R8_AB1_ACTINOMYCOSIS.gz > crp_finngen.tab


regions=(
  "1:159012443-160112443"
  "1:200000000-200100000"
  "2:10000000-20000000"
)



while read p; do
  filename=$(basename "$p" .gz)

  tabix $p 1:159012443-159912443  | awk -v fname="$filename" '{print $0 "\t" fname}'| gzip >> crp_finngen_whole_region_every.tab.gz
  rm *.tbi
done < to_download



#just the regiom

while read p; do
  filename=$(basename "$p" .gz)

  tabix $p 1:159714024-159714024 | awk -v fname="$filename" '{print $0 "\t" fname}'| gzip >> crp_finngen_rare_var_only.tab.gz
  rm *.tbi
  
  done < to_download
done < to_download



while read p; do
  filename=$(basename "$p" .gz)

  tabix $p 1:65642834-65642834  | awk -v fname="$filename" '{print $0 "\t" fname}'| gzip >> crp_other_region.tab.gz
  rm *.tbi
done < to_download