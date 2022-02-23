import numpy as np
import sys
mydir=sys.argv[1]

# load candidate regions
regions=np.loadtxt(mydir+'/results/LW_summary_2pop.regions',skiprows=1)
n=regions.shape[0]

# initialize annotation for each region
annot=[]
for i in range(n):
    annot.append([])

outfile=open(mydir+'/results/LW_candidate_genes_2pop.txt','w') # all genes included in candidate regions
# goes over genes in the gtf file
for line in open(mydir+'/input_files/Sus_scrofa.Sscrofa11.1.96.gtf'):
    buf=line.split()
    try:
	if buf[2]=='gene':
    	    for i in range(n):
		try:
		    chro=int(buf[0])
		    deb=int(buf[3])
		    fin=int(buf[4])	
		    if chro==regions[i,0] and regions[i,2]>=deb and regions[i,1]<=fin:
			if buf[12]=='gene_name':
			    gene=buf[13].split('\"')[1]		    
			else:
		    	    gene=buf[9].split('\"')[1]		    
		    	annot[i].append(gene)
			outfile.write(gene+' '+str(chro)+' '+str(deb)+' '+str(fin)+'\n')
		except ValueError:
		    pass
    except IndexError:
	pass

outfile=open(mydir+'/results/LW_summary_annot_2pop.regions','w')
for i in range(n):
    outfile.write(str(int(regions[i,0]))+' '+str(int(regions[i,1]))+' '+str(int(regions[i,2])))
    temp=''
    if int(regions[i,3])==1:
	temp=temp+'LWD,'
    if int(regions[i,4])==1:
	temp=temp+'LWS,'
    if int(regions[i,5])==1:
	temp=temp+'hapFLK,'
    outfile.write(' '+temp[:(len(temp)-1)]+' ')
    for gene in annot[i]:
	outfile.write(gene+' ')
    outfile.write('\n')

