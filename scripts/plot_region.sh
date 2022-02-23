myfolder=$1
reg=$2

file=all10_auto
regfile=$myfolder/results/LW_summary_2pop.regions

# define region
chro=$(cut -d" " -f1 $regfile | head -n $[$reg+1] | tail -n 1)
deb=$(cut -d" " -f2 $regfile | head -n $[$reg+1] | tail -n 1)
fin=$(cut -d" " -f3 $regfile | head -n $[$reg+1] | tail -n 1)

# standard plot
R -f $myfolder/scripts/plot_hapflk_vs_time_region.R --args $myfolder $file $chro $deb $fin

# main figure plot
#grep ENS $myfolder/results/LW_candidate_genes_2pop_v2.txt > $myfolder/results/LW_candidate_genes_2pop_ENS.txt
#grep -v ENS $myfolder/results/LW_candidate_genes_2pop_v2.txt > $myfolder/results/LW_candidate_genes_2pop_noENS.txt
#R -f $myfolder/scripts/plot_hapflk_vs_time_region_mainfig.R --args $myfolder $file $chro $deb $fin
