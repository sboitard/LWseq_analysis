import sys
name=sys.argv[1]

f=open(name+'_AT.pos','w')
for line in open(name+'.bim'):
    buf=line.split()
    a1=buf[4]
    a2=buf[5]
    if a1=='A' and a2=='T' or a1=='T' and a2=='A' or a1=='C' and a2=='G' or a1=='G' and a2=='C':
    	f.write(buf[1]+'\n')
