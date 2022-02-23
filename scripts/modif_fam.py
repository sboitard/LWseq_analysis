import sys
name=sys.argv[1]

f=open(name+'2','w')
for line in open(name):
    buf=line.split()
    buf2=buf[0].split('-')
    pop=buf2[1]
    if pop=='LC110':
	pop='LWD'
    elif pop=='LC220':
	pop='LWS'
    anim=buf2[len(buf2)-1]
    f.write(pop+' '+pop+':'+anim+' 0 0 0 -9\n')

