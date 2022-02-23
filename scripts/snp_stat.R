args <- commandArgs(TRUE)
filename=args[1]

u=read.table(paste('plink_files/',filename,'.frq.strat',sep=""),header=T,stringsAsFactors=F)
pops=unique(u[,3])
npops=length(pops)
p=dim(u)[1]/npops
print(npops)
print(p)
freq=t(array(dim=c(npops,p),data=u[,6]))
obs=t(array(dim=c(npops,p),data=u[,8]))
colnames(freq)=pops
colnames(obs)=pops

# removes SNPs missing in at least one pop
cmin=apply(obs,1,min)
ind=which(cmin>=9)
p2=length(ind)
freq=freq[ind,]

# proportion of total and private SNPs population
for (i in 1:3){
	print(pops[i])
	# all SNPs
	print("nb snps")
	ind=which((freq[,i]>0)&(freq[,i]<1))	
	print(length(ind)/p2)
	# private alleles
	print("nb private alleles")
	s=apply(freq[,-i],1,sum)
	ind=which((freq[,i]>0)&(s==0))
	print(length(ind)/p2)	
}

# SNPs polymorphic in both modern lines but not in 1977
print("alleles absent only in 1977")
ind1=which((freq[,'LWD']>0)&(freq[,'LWS']>0)&(freq[,'1977']==0))
ind2=which((freq[,'LWD']<1)&(freq[,'LWS']<1)&(freq[,'1977']==1))
print((length(ind1)+length(ind2))/p2)

# SNPs lost in LWF (living animals)
print("lost in LWD")
ind1=which((freq[,'LWD']==0)&(freq[,'1977']>0))
ind2=which((freq[,'LWS']==1)&(freq[,'1977']>1))
print((length(ind1)+length(ind2))/p2)


