# Detection and characterization of recent selection signatures in the Large White pig breed using NGS data

All commands used for the genetic data analyzes performed in Boitard et al (under revision) can be found in main.sh.

These commands call python, bash and R scripts, which can be found in directory 'scripts'.

Directory 'compareHMM' should contain the code allowing to detect selection from genomic time series (Paris et al, 2020), downloaded from https://github.com/CyrielParis/compareHMM.

Other public software (plink1.9,hapfLK) are needed for some commands and should be installed before running main.sh.

The raw NGS data (fastq files) used in these analyzes are public but not provided here (url is provided in the manuscript). Genotype files at plink format, which result from the pre-processing of NGS data, are also public but not provided here (url is provided in the manuscript)

The following input or intermediate result files can be found in the directory 'input_files':
- a list of the genes included in selection signatures (gene_names.txt, sel_genes.csv)
- a list of QTLs overlapping selection signatures (QTL_list.csv)
- lists of functions found significantly enriched within selection signatures (MGI.csv, GOBP.csv, KEGG.csv). 
- A summary table of selection signatures including their category (LW_summary_annot_type_2pop.regions).
- A summary table of selection signatures with cleaned gene names (LW_summary_annot_2pop_v2.regions).
