myfolder=$1

# creates a dataset with only 1977 individuals
grep 1977 $myfolder/input_files/snp20_auto_cr.fam | cut -d" " -f1-2 > $myfolder/plink_files/1977.cluster
plink --bfile $myfolder/input_files/snp20_auto_cr --keep $myfolder/plink_files/1977.cluster --make-bed --out $myfolder/plink_files/snp20_auto_cr_1977
# selects SNPs with MAF >= 10 in this dataset
plink --bfile $myfolder/plink_files/snp20_auto_cr_1977 --maf 0.1 --make-bed --out $myfolder/plink_files/snp20_auto_cr_1977_maf10
cut -f2 $myfolder/plink_files/snp20_auto_cr_1977_maf10.bim > $myfolder/plink_files/snp20_auto_cr_1977_maf10.snp
# extract these SNPs in the original dataset
plink --bfile $myfolder/input_files/snp20_auto_cr --extract $myfolder/plink_files/snp20_auto_cr_1977_maf10.snp --make-bed --out $myfolder/plink_files/snp20_auto_cr_maf10 # 9,009,155 SNPs

# cleaning
rm $myfolder/plink_files/snp20_auto_cr_1977*
rm $myfolder/plink_files/*.log
rm $myfolder/plink_files/*.nosex
