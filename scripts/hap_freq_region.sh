myfolder=$1
reg=$2

file=all10_auto
regfile=$myfolder/results/LW_summary_2pop.regions

# define region
chro=$(cut -d" " -f1 $regfile | head -n $[$reg+1] | tail -n 1)
deb=$(cut -d" " -f2 $regfile | head -n $[$reg+1] | tail -n 1)
fin=$(cut -d" " -f3 $regfile | head -n $[$reg+1] | tail -n 1)

# plink file for the region
#plink --bfile $myfolder/input_files/${file} --make-bed --out $myfolder/plink_files/${file}_chro$[chro]_$[deb]-$[fin] --chr $chro --from-bp $deb --to-bp $fin 

# hapflk
hapflk --bfile $myfolder/plink_files/${file}_chro$[chro]_$[deb]-$[fin]  -K=10 --nfit=3 --prefix $myfolder/results/regions/hapflk_plots/${file}_chro$[chro]_$[deb]-$[fin] --annot --kinship $myfolder/results/FLK/LW_3pop_fij.txt

# cluster plots
i=0
while [ $i -le 2 ]
do 
	$myfolder/scripts/hapflk-clusterplot-mainfig.R $myfolder/results/regions/hapflk_plots/${file}_chro$[chro]_$[deb]-$[fin].kfrq.fit_$i.bz2
	i=$[$i+1]
done

# cleaning
rm $myfolder/results/regions/hapflk_plots/${file}_chro$[chro]_$[deb]-$[fin].eig
rm $myfolder/results/regions/hapflk_plots/${file}_chro$[chro]_$[deb]-$[fin].flk*
rm $myfolder/results/regions/hapflk_plots/${file}_chro$[chro]_$[deb]-$[fin].frq
rm $myfolder/results/regions/hapflk_plots/${file}_chro$[chro]_$[deb]-$[fin].hapflk*
rm $myfolder/results/regions/hapflk_plots/${file}_chro$[chro]_$[deb]-$[fin].rey
rm $myfolder/results/regions/hapflk_plots/${file}_chro$[chro]_$[deb]-$[fin].kfrq*.bz2
rm $myfolder/plink_files/*.log
rm $myfolder/plink_files/*.nosex


