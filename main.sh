myfolder=/work/sboitard/LWseq/final_analyzes # to be replaced by the path where this file is located

mkdir plink_files
mkdir results

## 0: Data preparation

# 0a: creates plink files for variant sets HQSNP and AV
# this step should be run from vcf files, not provided here
sh scripts/create_HQSNP.sh $myfolder
sh scripts/create_AV.sh $myfolder
# 0b: filters on MAF in the 1977 population (used in several analyzes below)
sh scripts/filter_MAF_1977.sh $myfolder
# 0c: selects a random subset of 100,000 SNPs; will be used for several analyzes
plink --bfile $myfolder/plink_files/snp20_auto_cr_maf10 --out $myfolder/plink_files/snp20_auto_cr_maf10_100000 --thin-count 100000 --make-bed

## 1: Genetic diversity
mkdir results/diversity

# PCA
plink --bfile input_files/snp20_auto_cr --ibs-matrix --out plink_files/snp20_auto_cr
R -f scripts/script_IBS.R --args snp20_auto_cr $myfolder
# total and private SNPs per population
plink --bfile input_files/snp20_auto_cr --freq --family --out plink_files/snp20_auto_cr
R -f scripts/snp_stat.R --args snp20_auto_cr # results in snp_stat.Rout

# effective population sizes
sh scripts/estim_Ne.sh $myfolder

## 2: Detection of selection signatures (HQSNP set)

# 2a: hapFLK analysis
mkdir results/FLK/
sh scripts/hapFLK_WG_2pop.sh $myfolder

# 2b: temporal analysis
mkdir results/time/
sh scripts/time.sh $myfolder

# 2c: local score
nb_seg=$(ls plink_files/snp20_auto_cr_seg*.frq.strat | wc -l)
R -f scripts/time_SL.R --args snp20_auto_cr_LWD $myfolder 1 $nb_seq
R -f scripts/time_SL.R --args snp20_auto_cr_LWS $myfolder 1 $nb_seq

# 2d: merging and annotating candidate regions
R -f scripts/summarize_signals_union.R --args $myfolder
python scripts/annot_regions.py $myfolder
python scripts/refine_annot.py $myfolder

# 2e: summary plot with all tests genome-wide
R -f scripts/plot_hapflk_vs_time.R --args $myfolder
R -f scripts/plot_hapflk_vs_time_chro.R --args $myfolder $chro # for a single chromosome

## 3: Characterisation of selection signatures (AV set)
## All following steps (unless specified) must be run for one region, here for instance region 1
mkdir results/regions/
reg=1

# 3a: hapltoype frequency plots
mkdir results/regions/hapflk_plots
sh scripts/hap_freq_region.sh $myfolder $reg

# 3b: FLK/hapFLK analysis by region
mkdir results/regions/hapflk_2pop
mkdir results/regions/missing
sh scripts/flk_region.sh $myfolder $reg

# 3c: temporal analysis
mkdir results/regions/time
sh scripts/time_region.sh $myfolder $reg

# 3d: summary plots for each region
mkdir results/regions/stat_profiles
sh scripts/plot_region.sh $myfolder $reg

# 3e: type of selection signature
# determined by visual inspection of results from 3a and 3d, provided here in directory input_files
# cp input_files/LW_summary_annot_type_2pop.regions results

# 3f: summary tables - one single analysis (not by region)
python scripts/summary_table.py $myfolder # produces Table 1 in latex format
python scripts/summary_table_full.py $myfolder # produces Additional File 2
python scripts/summary_table_nbgenes.py $myfolder # produces a table with the number of genes in each region

# 3d: candidate causal variants for each region
mkdir results/regions/causal
sh scripts/causal_variants.sh $myfolder $reg

## 4: QTL enrichment
mkdir results/enrich
R -f scripts/enrich_QTL.R --args $myfolder

## 5: functional enrichment (example with MGI)
python scripts/term_score.py $myfolder MGI
R -f scripts/enrich_func.R --args $myfolder MGI

