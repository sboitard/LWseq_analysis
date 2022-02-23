myfolder=$1
# these variables need to be replaced by the name of input file
myvcf_snp=/work/sboitard/LWseq/vcf/all_snp.vcf.gz
myvcf_indel=/work/sboitard/LWseq/vcf/all_indel.vcf.gz

# load SNPs
plink --vcf $myvcf_snp --vcf-min-gq 10 --chr-set 18 --allow-extra-chr --chr 1-18 --make-bed --out $myfolder/input_files/snp10_auto
python $myfolder/scripts/modif_bim.py $myfolder/input_files/snp10_auto.bim
mv $myfolder/input_files/snp10_auto.bim2 $myfolder/input_files/snp10_auto.bim
# load indels
plink --vcf $myvcf_indel --vcf-min-gq 10 --chr-set 18 --allow-extra-chr --chr 1-18 --make-bed --out $myfolder/input_files/indel10_auto
python $myfolder/scripts/modif_bim.py $myfolder/input_files/indel10_auto.bim
mv $myfolder/input_files/indel10_auto.bim2 $myfolder/input_files/indel10_auto.bim
# merge both
plink --bfile $myfolder/input_files/snp10_auto --bmerge $myfolder/input_files/indel10_auto --make-bed --out $myfolder/input_files/all10_auto # 26,530,986 variants
# change individual and family (population) names
python $myfolder/scripts/modif_fam.py $myfolder/input_files/all10_auto.fam
mv $myfolder/input_files/all10_auto.fam2 $myfolder/input_files/all10_auto.fam

# cleaning
rm $myfolder/input_files/snp10*
rm $myfolder/input_files/indel10*
rm $myfolder/input_files/all10_auto.log
rm $myfolder/input_files/all10_auto.nosex

