import numpy as np
import sys
mydir=sys.argv[1]

catreg={}
for line in open(mydir+'/results/LW_summary_annot_type_2pop.regions'):
    buf=line.split()
    catreg[buf[0]+':'+buf[1]+'-'+buf[2]]=buf[5]

outfile=open(mydir+'/results/LW_summary_full.txt','w')
outfile.write('Id Chr Start End L(kb) WGtests Category Genes \n')
for line in open(mydir+'/results/LW_summary_annot_2pop_v2.regions'):
    buf=line.split()
    outfile.write('SSC'+buf[0]+':'+str(int(float(buf[1])/1000000))+' '+buf[0]+' '+buf[1]+' '+buf[2]+' ')
    L=int((int(buf[2])-int(buf[1]))/1000)
    outfile.write(str(L)+' '+buf[3]+' ')
    try:
	outfile.write(catreg[buf[0]+':'+buf[1]+'-'+buf[2]])
    except KeyError:
	outfile.write('Missing')
    if len(buf)>4:
	outfile.write(' ')
	outfile.write(buf[4])
	if len(buf)>5:
    	    for i in range(5,len(buf)):
	    	outfile.write(','+buf[i])
        outfile.write('\n')
    else:
	outfile.write(' None\n')
