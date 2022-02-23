myfolder=$1

# cut the genome into 10Mb segments
sh $myfolder/scripts/cut_genome.sh $myfolder/input_files/snp20_auto_cr $myfolder/plink_files/snp20_auto_cr 10000000

## Next steps must be run for each segment, here 1 for instance
seg=1

# computes allele frequencies
plink --bfile $myfolder/plink_files/snp20_auto_cr_seg$seg --freq --family --out $myfolder/plink_files/snp20_auto_cr_seg$seg

# LWD line
grep -v LWS $myfolder/plink_files/snp20_auto_cr_seg$seg.frq.strat > $myfolder/plink_files/snp20_auto_cr_LWD_seg$seg.frq.strat
python $myfolder/scripts/replace_col.py $myfolder/plink_files/snp20_auto_cr_LWD_seg$seg.frq.strat 1977,LWD 0,20 2
mv $myfolder/plink_files/snp20_auto_cr_LWD_seg$seg.frq.strat2 $myfolder/plink_files/snp20_auto_cr_LWD_seg$seg.frq.strat 
python3 $myfolder/compareHMM/src/run_rd_analyzer.py -N 160 --infile $myfolder/plink_files/snp20_auto_cr_LWD_seg$seg.frq.strat --outfile $myfolder/results/time/snp20_auto_cr_LWD_seg$seg.csv --times 0 20

# LWS line
grep -v LWD $myfolder/plink_files/snp20_auto_cr_seg$seg.frq.strat > $myfolder/plink_files/snp20_auto_cr_LWS_seg$seg.frq.strat
python $myfolder/scripts/replace_col.py $myfolder/plink_files/snp20_auto_cr_LWS_seg$seg.frq.strat 1977,LWS 0,20 2
mv $myfolder/plink_files/snp20_auto_cr_LWS_seg$seg.frq.strat2 $myfolder/plink_files/snp20_auto_cr_LWS_seg$seg.frq.strat 
python3 $myfolder/compareHMM/src/run_rd_analyzer.py -N 146 --infile $myfolder/plink_files/snp20_auto_cr_LWS_seg$seg.frq.strat --outfile $myfolder/results/time/snp20_auto_cr_LWS_seg$seg.csv --times 0 20

# cleaning
rm $myfolder/plink_files/*seg*



