myfolder=$1
reg=$2

file=all10_auto
regfile=$myfolder/results/LW_summary_annot_type_2pop.regions
annotfile=$myfolder/input_files/all_variations.annot.vcf.gz

# define region
chro=$(cut -d" " -f1 $regfile | head -n $reg | tail -n 1)
deb=$(cut -d" " -f2 $regfile | head -n $reg | tail -n 1)
fin=$(cut -d" " -f3 $regfile | head -n $reg | tail -n 1)
type=$(cut -d" " -f6 $regfile | head -n $reg | tail -n 1)

## weak filtering
#R -f $myfolder/scripts/find_candi_weak.R --args $myfolder $file $chro $deb $fin $type
# associate annotation to candidates
#cut -d" " -f1 $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_weak.txt > $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_weak_temp.chr
#cut -d" " -f2 $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_weak.txt > $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_weak_temp.pos
#paste $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_weak_temp.chr $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_weak_temp.pos | grep -v chr > $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_weak_temp.candi
#bcftools view -H -R $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_weak_temp.candi $annotfile | cut -f1-8 > $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_weak.annot
# functionnal variants
#grep HIGH $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_weak.annot > $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_weak.func
#grep MODERATE $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_weak.annot >> $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_weak.func
#grep LOW $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_weak.annot >> $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_weak.func

## stringent filtering
#R -f $myfolder/scripts/find_candi_strong.R --args $myfolder $file $chro $deb $fin $type
# associate annotation to candidates
cut -d" " -f1 $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_strong.txt > $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_strong_temp.chr
cut -d" " -f2 $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_strong.txt > $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_strong_temp.pos
paste $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_strong_temp.chr $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_strong_temp.pos | grep -v chr > $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_strong_temp.candi
bcftools view -H -R $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_strong_temp.candi $annotfile | cut -f1-8 > $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_strong.annot
# functionnal variants
grep HIGH $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_strong.annot > $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_strong.func
grep MODERATE $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_strong.annot >> $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_strong.func
grep LOW $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_strong.annot >> $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_strong.func

# cleaning
rm $myfolder/results/regions/causal/${file}_chro${chro}_${deb}-${fin}_*temp*



