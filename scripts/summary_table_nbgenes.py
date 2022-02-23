import numpy as np
import sys
mydir=sys.argv[1]

catreg={}
for line in open(mydir+'/results/LW_summary_annot_type_2pop.regions'):
    buf=line.split()
    catreg[buf[0]+':'+buf[1]+'-'+buf[2]]=buf[5]

outfile=open(mydir+'/results/LW_summary_nbgenes.txt','w')
outfile.write('Chr Start End L(kb) WGtests Type Genes \n')
for line in open(mydir+'/results/LW_summary_annot_2pop.regions'):
    buf=line.split()
    outfile.write(buf[0]+' '+buf[1]+' '+buf[2]+' ')
    L=int((int(buf[2])-int(buf[1]))/1000)
    outfile.write(str(L)+' '+buf[3]+' ')
    try:
	outfile.write(catreg[buf[0]+':'+buf[1]+'-'+buf[2]])
    except KeyError:
	outfile.write('Missing')
    nb_genes=len(buf)-4
    outfile.write(' '+str(nb_genes)+'\n')

