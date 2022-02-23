myfolder=$1
reg=$2

file=all10_auto
regfile=$myfolder/results/LW_summary_2pop.regions

# define region
chro=$(cut -d" " -f1 $regfile | head -n $[$reg+1] | tail -n 1)
deb=$(cut -d" " -f2 $regfile | head -n $[$reg+1] | tail -n 1)
fin=$(cut -d" " -f3 $regfile | head -n $[$reg+1] | tail -n 1)

# frequency file for the region
#plink --bfile $myfolder/plink_files/${file}_chro$[chro]_$[deb]-$[fin] --maf 0.01 --freq --family --out $myfolder/plink_files/${file}_chro$[chro]_$[deb]-$[fin]

# LWD line
#grep -v LWS $myfolder/plink_files/${file}_chro$[chro]_$[deb]-$[fin].frq.strat > $myfolder/plink_files/${file}_chro$[chro]_$[deb]-$[fin]_LWD.frq.strat
#python2 $myfolder/scripts/replace_col.py $myfolder/plink_files/${file}_chro$[chro]_$[deb]-$[fin]_LWD.frq.strat 1977,LWD 0,20 2
#mv $myfolder/plink_files/${file}_chro$[chro]_$[deb]-$[fin]_LWD.frq.strat2 $myfolder/plink_files/${file}_chro$[chro]_$[deb]-$[fin]_LWD.frq.strat
python3 $myfolder/compareHMM/src/run_rd_analyzer.py -N 160 --infile $myfolder/plink_files/${file}_chro$[chro]_$[deb]-$[fin]_LWD.frq.strat --outfile $myfolder/results/regions/time/${file}_chro$[chro]_$[deb]-$[fin]_LWD.csv --times 0 20

# LWS line
#grep -v LWD $myfolder/plink_files/${file}_chro$[chro]_$[deb]-$[fin].frq.strat > $myfolder/plink_files/${file}_chro$[chro]_$[deb]-$[fin]_LWS.frq.strat
#python2 $myfolder/scripts/replace_col.py $myfolder/plink_files/${file}_chro$[chro]_$[deb]-$[fin]_LWS.frq.strat 1977,LWD 0,20 2
#mv $myfolder/plink_files/${file}_chro$[chro]_$[deb]-$[fin]_LWS.frq.strat2 $myfolder/plink_files/${file}_chro$[chro]_$[deb]-$[fin]_LWS.frq.strat
python3 $myfolder/compareHMM/src/run_rd_analyzer.py -N 160 --infile $myfolder/plink_files/${file}_chro$[chro]_$[deb]-$[fin]_LWS.frq.strat --outfile $myfolder/results/regions/time/${file}_chro$[chro]_$[deb]-$[fin]_LWS.csv --times 0 20

# cleaning
rm $myfolder/plink_files/*.log
rm $myfolder/plink_files/*.nosex


