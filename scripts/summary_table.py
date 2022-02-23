import numpy as np
import sys
mydir=sys.argv[1]

catreg={}
for line in open(mydir+'/results/LW_summary_annot_type_2pop.regions'):
    buf=line.split()
    catreg[buf[0]+':'+buf[1]+'-'+buf[2]]=buf[5]

outfile=open(mydir+'/results/LW_summary.tex','w')
outfile.write('Id&Chr&Start (Mb)&End (Mb)&L (kb)&WG tests&Category&Genes\\\\ \n')
outfile.write('\\hline\n')
for line in open(mydir+'/results/LW_summary_annot_2pop_v2.regions'):
    buf=line.split()
    # coord modif
    deb=float(int(float(buf[1])/10000))/100
    fin=float(int(float(buf[2])/10000))/100
    outfile.write('SSC'+buf[0]+':'+str(int(deb))+'&'+buf[0]+'&'+str(deb)+'&'+str(fin)+'&')
    L=int((int(buf[2])-int(buf[1]))/1000)
    outfile.write(str(L)+'&'+buf[3]+'&')
    try:
	outfile.write(catreg[buf[0]+':'+buf[1]+'-'+buf[2]]+'&')
    except KeyError:
	outfile.write('Missing&')
    if len(buf)>4:
    	nb_genes=0
    	nb_ens=0
    	aux=''
    	for i in range(4,len(buf)):
	    if buf[i][0:3]=='ENS':
	    	nb_ens+=1
	    else:
	    	nb_genes+=1
	    	aux=aux+' '+buf[i]
    	if nb_genes<=2:
	    outfile.write(aux)
	    if nb_ens>0:
		outfile.write(' (+'+str(nb_ens)+')')
	    outfile.write('\\\\')
    	else:
	    outfile.write(str(nb_ens+nb_genes)+'\\\\')
    	outfile.write('\n')
    else:
	outfile.write('0 \\\\ \n')
outfile.write('\\hline\n')
