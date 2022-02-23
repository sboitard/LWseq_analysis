# replaces elements of string1 by elements of string2 in column col

import sys
name=sys.argv[1]
string1=sys.argv[2].split(',')
string2=sys.argv[3].split(',')
col=int(sys.argv[4])

f=open(name+'2','w')
n=len(string1)

for line in open(name):
    buf=line.split()
    for i in range(n):
	if buf[col]==string1[i]:
	    buf[col]=string2[i]
    for j in range(col):
	f.write(buf[j]+'\t')
    f.write(buf[col])
    for j in range(col+1,len(buf)):
	f.write('\t'+buf[j])
    f.write('\n')

