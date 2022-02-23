import sys
mydir=sys.argv[1]
filename=sys.argv[2]

outfile=open(mydir+'/plink_files/NB_input.txt','w')
for i in [1,21]:
    for line in open(mydir+'/plink_files/'+filename+'_NB_input_G'+str(i)+'.txt'):
	outfile.write(line)
    outfile.write('\n')
