myfolder=$1
reg=$2

file=all10_auto
regfile=$myfolder/results/LW_summary_2pop.regions

# define region
chro=$(cut -d" " -f1 $regfile | head -n $[$reg+1] | tail -n 1)
deb=$(cut -d" " -f2 $regfile | head -n $[$reg+1] | tail -n 1)
fin=$(cut -d" " -f3 $regfile | head -n $[$reg+1] | tail -n 1)

# flk and hapflk scores for each snp
hapflk --bfile $myfolder/plink_files/${file}_chro$[chro]_$[deb]-$[fin] -K=10 --nfit=10 --prefix $myfolder/results/regions/hapflk_2pop/${file}_chro$[chro]_$[deb]-$[fin] --kinship  $myfolder/results/FLK/LW_fij.txt --outgroup 1977

# missing rates
plink --bfile $myfolder/plink_files/${file}_chro$[chro]_$[deb]-$[fin] --out $myfolder/results/regions/missing/${file}_chro$[chro]_$[deb]-$[fin] --missing

# cleaning
rm $myfolder/results/regions/missing/*.imiss
rm $myfolder/results/regions/missing/*.log
rm $myfolder/results/regions/missing/*.nosex
rm $myfolder/results/regions/hapflk_2pop/*.frq

