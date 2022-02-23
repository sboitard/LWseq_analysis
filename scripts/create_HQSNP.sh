myfolder=$1
# these variables need to be replaced by the name of input file
myvcf=/work/sboitard/LWseq/vcf/all_snp_common_filtered-simon.vcf.gz

plink --vcf $myvcf --vcf-min-gq 20 --chr-set 18 --biallelic-only strict --allow-extra-chr --chr 1-18 --vcf-filter --make-bed --out $myfolder/input_files/snp20_auto # 15,774,198 SNPs
# change individual and family (population) names
python $myfolder/scripts/modif_fam.py $myfolder/input_files/snp20_auto.fam
mv $myfolder/input_files/snp20_auto.fam2 $myfolder/input_files/snp20_auto.fam
# change marker names
python $myfolder/scripts/modif_bim.py $myfolder/input_files/snp20_auto.bim
mv $myfolder/input_files/snp20_auto.bim2 $myfolder/input_files/snp20_auto.bim
# missing data per individual
plink --bfile $myfolder/input_files/snp20_auto --missing --out $myfolder/input_files/snp20_auto # 6% on average
R -f $myfolder/scripts/plot_miss.R --args $myfolder/input_files/snp20_auto # 4-5% in modern, 12% in 1977

# filters on call rate
plink --bfile $myfolder/input_files/snp20_auto --geno 0.1 --out $myfolder/input_files/snp20_auto_cr --make-bed # 13,408,342 SNPs
# missing data per individual
plink --bfile $myfolder/input_files/snp20_auto_cr --missing --out $myfolder/input_files/snp20_auto_cr # 3.5% on average
R -f $myfolder/scripts/plot_miss.R --args $myfolder/input_files/snp20_auto_cr # 3% in modern, 7-8 in 1977

# cleaning
rm $myfolder/input_files/snp20_auto.*
rm $myfolder/input_files/snp20_auto_cr.lmiss
rm $myfolder/input_files/snp20_auto_cr.imiss
rm $myfolder/input_files/snp20_auto_cr.log
rm $myfolder/input_files/snp20_auto_cr.nosex

