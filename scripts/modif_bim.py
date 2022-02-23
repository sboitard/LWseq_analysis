# names each snp as chr:pos

import sys
name=sys.argv[1]

f=open(name+'2','w')

for line in open(name):
    buf=line.split()
    f.write(buf[0]+'\t'+buf[0]+':'+buf[3]+'\t'+buf[2]+'\t'+buf[3]+'\t'+buf[4]+'\t'+buf[5]+'\n')
