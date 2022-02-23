myfolder=$1

# build FLK/hapFLK kinship matrix
hapflk --bfile $myfolder/plink_files/snp20_auto_cr_maf10_100000 --prefix $myfolder/results/FLK/LW --outgroup 1977
R -f $myfolder/scripts/global_tree.R --args $myfolder/results/FLK/LW

# build FLK/hapFLK kinship matrix including 1977
# not used here but for the detailed analysis of regions
hapflk --bfile $myfolder/plink_files/snp20_auto_cr_maf10_100000 --prefix $myfolder/results/FLK/LW_3pop --outgroup 1977 --keep-outgroup

# FLK and hapFLK analysis: this part must be run for each chromosome, here 18 for instance
chro=18
plink -bfile $myfolder/plink_files/snp20_auto_cr_maf10 --chr $chro --make-bed --out $myfolder/plink_files/snp20_auto_cr_maf10_chro$chro
hapflk --bfile $myfolder/plink_files/snp20_auto_cr_maf10_chro$chro --prefix $myfolder/results/FLK/snp20_auto_cr_maf10_2pop_chro$chro --kinship $myfolder/results/FLK/LW_fij.txt -K 10 --nfit 10 --outgroup 1977

# merge results from all chromosomes and compute p-values
cat $myfolder/results/FLK/snp20_auto_cr_maf10_2pop_chro*.hapflk > $myfolder/results/FLK/snp20_auto_cr_maf10_2pop.hapflk
head -n 1 $myfolder/results/FLK/snp20_auto_cr_maf10_2pop.hapflk > $myfolder/results/FLK/temp.head
grep -v chr $myfolder/results/FLK/snp20_auto_cr_maf10_2pop.hapflk > $myfolder/results/FLK/temp.data
cat $myfolder/results/FLK/temp.head $myfolder/results/FLK/temp.data > $myfolder/results/FLK/snp20_auto_cr_maf10_2pop.hapflk
rm $myfolder/results/FLK/temp*
python $myfolder/scripts/scaling_chi2_hapflk.py $myfolder/results/FLK/snp20_auto_cr_maf10_2pop.hapflk 10 2

# detect significant regions
R -f $myfolder/scripts/signif_hapflk.R --args snp20_auto_cr_maf10_2pop $myfolder

# plot genome-wide p-values (with significant threshold)
R -f $myfolder/scripts/plot_hapflk.R --args snp20_auto_cr_maf10_2pop $myfolder

# cleaning
rm $myfolder/plink_files/*.log
rm $myfolder/plink_files/*.nosex
rm $myfolder/results/FLK/LW.*
rm $myfolder/results/FLK/LW_reynolds.txt
rm $myfolder/results/FLK/snp20_auto_cr_maf10_2pop_chro*.frq
rm $myfolder/results/FLK/snp20_auto_cr_maf10_2pop_chro*.flk
#rm $myfolder/results/FLK/snp20_auto_cr_maf10_2pop_chro*.hapflk?
#rm $myfolder/results/FLK/snp20_auto_cr_maf10_2pop.hapflk
rm $myfolder/results/FLK/LW_3pop.*


