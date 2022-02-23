myfolder=$1

# compute allele frequencies at each marker
plink --bfile $myfolder/plink_files/snp20_auto_cr_maf10_100000 --freq --family --out $myfolder/plink_files/snp20_auto_cr_maf10_100000

# prepare NB input files for the LWD analysis
R -f scripts/format_NB.R --args $myfolder snp20_auto_cr_maf10_100000 LWD
python scripts/cat_generations.py $myfolder snp20_auto_cr_maf10_100000

# estimate Ne for the LWD analysis
nb_snp=$(wc -l plink_files/snp20_auto_cr_maf10_100000_NB_input_G1.txt | cut -d" " -f1) 
R -f scripts/estim_NB.R --args $myfolder $nb_snp # output in estim_NB.Rout

# prepare NB input files for the LWS analysis
R -f scripts/format_NB.R --args $myfolder snp20_auto_cr_maf10_100000 LWS
python scripts/cat_generations.py $myfolder snp20_auto_cr_maf10_100000

# estimate Ne for the LWS analysis
nb_snp=$(wc -l plink_files/snp20_auto_cr_maf10_100000_NB_input_G1.txt | cut -d" " -f1) 
R -f scripts/estim_NB.R --args $myfolder $nb_snp # output in estim_NB.Rout

# cleaning
rm $myfolder/plink_files/*.log
rm $myfolder/plink_files/*.nosex
rm $myfolder/plink_files/*NB*.txt


