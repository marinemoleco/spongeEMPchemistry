sed -i '1d' phylum_samples.txt
awk -F'\t' 'NR==FNR{arr[$1]++;next}{for(i=1; i<=NF; i++) if ($i in arr){a[i]++;}} { for (i in a) printf "%s\t", $i; printf "\n"}' phylum_samples.txt <(zcat final.withtax.v14.tsv.tar.gz) > final.phylum.txt

