UKB RAP


#Use guillaumes data - from email
#then untar and pull out the variants:

cat * | cut -f 2   > ../variants_ensembl.txt
cat * | cut -f 2   > ../variants_refseq.txt
cat variants* | sort | uniq > all_variants_to_pull.txt

cp all_variants_to_pull.txt > input.txt

while read line; do
    if [[ $line == *-* ]]; then
        chromosome=$(echo $line | cut -d':' -f1)
        start=$(echo $line | cut -d':' -f2 | cut -d'-' -f1)
        end=$(echo $line | cut -d':' -f2 | cut -d'-' -f2)
        echo -e "$chromosome\t$start\t$end\tset\tset"
    else
        chromosome=$(echo $line | cut -d':' -f1)
        position=$(echo $line | cut -d':' -f2)
        echo -e "$chromosome\t$position\t$position\tset\tset"
    fi
done < input_file.txt > output_file.txt



plink --bfile crp_gene_exome_450  --recode AD --out called_burden --extract range output_files.txt
