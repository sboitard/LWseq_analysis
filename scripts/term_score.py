import sys
import numpy as np

mydir=sys.argv[1]
dbname=sys.argv[2]

generef={}
for line in open(mydir+'/input_files/sel_genes.csv'): # this file is a csv extraction of Additional file 7, sheet 1
    buf=line[:-1].split(';')
    generef[buf[1]]=[buf[0],buf[2]]

cat=['LWD','LWS','conv(LWD)','conv(LWS)','conv','div']

outfile=open(mydir+'/results/enrich/'+dbname+'_nbgenes.csv','w')
# header line
outfile.write('annot_id;annot;pval')
for i in range(6):
    outfile.write(';'+cat[i])
outfile.write('\n')
# other lines
for line in open(mydir+'/input_files/'+dbname+'.csv'): # this file is a csv extraction of Additional file 7, sheet 2-4 (depending on dbname)
    buf=line[:-1].split(';')
    annot=buf[0]
    annot_id=buf[1]
    pval=buf[8]
    genes=buf[9].split(',')
    #print genes
    # compute score
    score=np.zeros(6)
    for gene in genes:
	i=cat.index(generef[gene][0])
	score[i]+=1
    #print score
    # write output
    outfile.write(annot_id+';'+annot+';'+pval)
    for i in range(6):
    	outfile.write(';'+str(score[i]))
    outfile.write('\n')
