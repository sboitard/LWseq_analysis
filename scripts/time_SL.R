library(dplyr)
library(tidyr)
library(ggplot2)

args <- commandArgs(TRUE)
filename=args[1]
mydir=args[2]
seg1=as.integer(args[3])
segf=as.integer(args[4])

# load data from all segments
u=read.table(paste(mydir,'/results/time/',filename,'_seg',seg1,'.csv',sep=''),head=T,stringsAsFactors=F,sep=',')
f=read.table(paste(mydir,'/plink_files/',filename,'_seg',seg1,'.frq.strat',sep=''),head=T,stringsAsFactors=F)
for (i in (seg1+1):segf){
	utemp=read.table(paste(mydir,'/results/time/',filename,'_seg',i,'.csv',sep=''),head=T,stringsAsFactors=F,sep=',')
	u=rbind(u,utemp)
	ftemp=read.table(paste(mydir,'/plink_files/',filename,'_seg',i,'.frq.strat',sep=''),head=T,stringsAsFactors=F)
	f=rbind(f,ftemp)
}

# filter on MAF (averaged over the 2 pops)
f=f%>% select(SNP,MAF) %>% group_by(SNP) %>% rename(ID=SNP) %>% summarize(MAF.m=mean(MAF)) %>% filter(MAF.m>0.1)
u=inner_join(u,f)

# compute chi-square test
u = u %>% mutate(LR=2*(LMLE-L0)) %>% mutate(pval=pchisq(LR,lower.tail=F,df=1)) %>% mutate(log10_pval=-log10(pval))

# pvalue distribution
p=ggplot(u,aes(x=pval))+geom_histogram()+theme_bw() +xlab('p-value')+ylab('number of SNPs') 
ggsave(paste(mydir,'/results/time/',filename,'_hist.png',sep=''),plot = p, width = 4, height = 4)

# add position
u = u %>% separate(ID,into=c('chr','pos'))
u$chr=as.integer(u$chr)
u$pos=as.integer(u$pos)

# select useful columns and save results
u = u %>% select(CHR,pos,sMLE,LR,pval,log10_pval) %>% arrange(CHR,pos) 
#write.table(u,file=paste(mydir,'/results/time/',filename,'_all.txt',sep=''),quote=F,col.names=T,row.names=F)

# single SNP significance - FDR 20%
library(qvalue)
q=qvalue(u$pval,fdr.level=0.2)
print(summary(q$qval))
l=sum(q$significant)
if (l>0){
	write.table(cbind(u[q$significant,],q$qval[q$significant]),file=paste(mydir,'/results/time/',filename,'_fdr20.txt',sep=''),col.names=c(colnames(u),'qvalue'),row.names=F,quote=F)
}

# manhattan plots
M=max(u$log10_pval)
p=ggplot(u,aes(x=pos,y=log10_pval))+geom_point(alpha=0.5)+theme_bw()+facet_wrap(~CHR,scales='free')+ylim(0,M)
ggsave(paste(mydir,'/results/time/',filename,'_pval.png',sep=''),plot = p, width = 18, height = 18)

## local score

# import source code from Fariello et al (2017) and convert data into relevant format
library(data.table)
source(paste(mydir,'/scripts/scorelocalfunctions_vf.R',sep=''))
mydata=u %>% select(CHR,pos,pval) %>% rename(chr=CHR,pvalue=pval)
mydata=data.table(mydata)
setkey(mydata,chr)
Nchr=length(mydata[,unique(chr)])

# add cumulated positions
chrInf=mydata[,.(L=.N,cor=autocor(pvalue)),chr]
setkey(chrInf,chr)
tmp=data.table(chr=mydata[,unique(chr),], S=cumsum(c(0,chrInf$L[-Nchr])))
setkey(tmp,chr)
mydata[tmp,posT:=pos+S]

# compute scores from p-values
xi=3
mydata[,score:= -log10(pvalue)-xi]
mean(mydata$score)
mydata[,lindley:=lindley(score),chr]

# compute significnce thresholds for each chromosome
chrInf[,th:=thresUnif(L, cor, xi,0.01),]
mydata=mydata[chrInf]
head(mydata)
write.table(mydata,file=paste(mydir,'/results/time/',filename,'_SL_xi3.txt',sep=''),quote=F,col.names=T,row.names=F)

# plot lindley process
M=max(max(chrInf$th),max(mydata$lindley))
p=ggplot(mydata,aes(x=pos,y=lindley))+geom_line()+theme_bw()+facet_wrap(~chr,scales='free',nrow=6,ncol=3)+ylim(0,M)+xlab('genomic position')+ylab('Lindley process')
p=p+geom_hline(aes(yintercept=th),color='red')
#ggsave(paste(mydir,'/results/time/',filename,'_SL_xi3_signif1.png',sep=''),plot = p, width = 18, height = 18)
ggsave(paste(mydir,'/results/time/',filename,'_SL_xi3_signif1.png',sep=''),plot = p, width = 6, height = 4)

# significant regions
sigZones=mydata[chrInf,sig_sl(lindley, pos, unique(th)),chr]
sigZones = sigZones %>% filter(beg>0) %>% select(chr,beg,end) %>% mutate(L=end-beg) %>% mutate(nb_snp=0)
for (i in 1:(dim(sigZones)[1])){
	reg=mydata %>% filter((chr==sigZones$chr[i])&(pos>=sigZones$beg[i])&(pos<=sigZones$end[i]))	
	print(reg)
	sigZones$nb_snp[i]=dim(reg)[1]
}
write.table(sigZones,file=paste(mydir,'/results/time/',filename,'_SL_xi3_signif1.txt',sep=''),quote=F,col.names=c('Chr','Start','End','L','nb_snp'),row.names=F)

# merge significant regions less than 1Mb apart
u = sigZones %>% arrange(chr,beg)
v=u[1,]
for (i in 1:18){
	utemp=u %>% filter(chr==i)
	n=dim(utemp)[1]
	vtemp=utemp
	if (n>1){
		jref=1
		j=2
		while (j<=n){
			if ((utemp[j,'beg']-vtemp[jref,'end'])<=1000000){
				vtemp[jref,'end']=utemp[j,'end']
				vtemp[jref,'nb_snp']=utemp[j,'nb_snp']+vtemp[jref,'nb_snp']			
			} else {
				jref=jref+1
				vtemp[jref,]=utemp[j,]
			}
			j=j+1
		}
	v=rbind(v,vtemp[1:jref,])	
	} else if (n==1){
		v=rbind(v,vtemp)
	}
} 
v=v[-1,]
v = v %>% mutate(L=end-beg)
write.table(v,file=paste(mydir,'/results/time/',filename,'_SL_xi3_signif1.regions',sep=''),quote=F,col.names=c('Chr','Start','End','L','nb_snp'),row.names=F)


