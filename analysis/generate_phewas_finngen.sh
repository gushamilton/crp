wget https://storage.googleapis.com/finngen-public-data-r8/summary_stats/R8_manifest.tsv
cut -f 7 R8_manifest.tsv  > to_download
tabix -H https://storage.googleapis.com/finngen-public-data-r8/summary_stats/finngen_R8_AB1_ACTINOMYCOSIS.gz > crp_finngen.tab



while read p; do
  filename=$(basename "$p" .gz)

  tabix $p 1:159714024-159714024 | awk -v fname="$filename" '{print $0 "\t" fname}' >> crp_finngen.tab
  rm *.tbi
done < to_download