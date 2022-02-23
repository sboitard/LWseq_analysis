import sys
mydir=sys.argv[1]

# load gene names
genes={}
for line in open(mydir+'/input_files/gene_names.txt'):
    #buf=line[:-1].split('&')
    #genes[buf[0].split('.')[0]]=buf[1] # ENS name
    buf=line[:-1].split('&')
    if buf[0]!=buf[1] and buf[1]!='' and buf[0][:2]!='RF' and buf[1][:3]!='ENS':
	genes[buf[0]]=buf[1] # original name, final name
print genes

infile_name=mydir+'/results/LW_candidate_genes_2pop.txt'
outfile=open(mydir+'/results/LW_candidate_genes_2pop_v2.txt','w')
for line in open(infile_name):
    buf=line.split()
    if genes.has_key(buf[0]):
	outfile.write(genes[buf[0]]+' '+buf[1]+' '+buf[2]+' '+buf[3]+'\n')
    else:
	outfile.write(buf[0]+' '+buf[1]+' '+buf[2]+' '+buf[3]+'\n')

infile_name=mydir+'/results/LW_summary_annot_2pop.regions'
outfile=open(mydir+'/results/LW_summary_annot_2pop_v2.regions','w')
for line in open(infile_name):
    buf=line.split()
    outfile.write(buf[0]+' '+buf[1]+' '+buf[2]+' '+buf[3])
    for i in range(4,len(buf)):
	if genes.has_key(buf[i]):
	    outfile.write(' '+genes[buf[i]])
	else:
	    outfile.write(' '+buf[i])
    outfile.write('\n')










