library(dplyr)
library(tidyr)
library(ggplot2)
library(data.table)

args <- commandArgs(TRUE)
filename=args[1]
mydir=args[2]

# load hapFLK results
hapflk=fread(paste(mydir,'/results/FLK/',filename,'.hapflk_sc',sep=''),header=T)
hapflk = hapflk %>% select(chr,pos,pvalue) %>% filter(!is.na(pvalue))

# p-value distribution
p=ggplot(hapflk,aes(x=pvalue))+geom_density()+theme_bw()
ggsave(paste(mydir,'/results/FLK/',filename,'_hist_hapflk.pdf',sep=''), plot = p, width = 4, height = 4)

# Significant regions for a FDR of 20%
source(paste(mydir,'/qvalue/R/qvalue.R',sep=''))
q.hapflk=qvalue(hapflk$pvalue,fdr.level=0.2)
l=sum(q.hapflk$significant)
min(q.hapflk$qval)
if (l>0){
	# list of significant SNPs
	hapflk_signif=cbind(hapflk[q.hapflk$significant,],q.hapflk$qval[q.hapflk$significant])
	colnames(hapflk_signif)=c(colnames(hapflk),'qvalue')
	head(hapflk_signif)
	write.table(hapflk_signif,file=paste(mydir,'/results/FLK/',filename,'_fdr15_hapflk.txt',sep=''),col.names=T,row.names=F,quote=F)
	# list of significant regions (merged if less than 1Mb apart)
	hapflk_signif=hapflk_signif %>% mutate(region=1)
	reg_temp=1
	for (i in 2:dim(hapflk_signif)[1]){
		d=hapflk_signif$pos[i]-hapflk_signif$pos[i-1]
		if ((hapflk_signif$chr[i]!=hapflk_signif$chr[i-1])|(d>1000000)){
			reg_temp=reg_temp+1	
		}
		hapflk_signif$region[i]=reg_temp
	}
	reg=hapflk_signif %>% filter(region>0) %>%  group_by(region) %>% summarize(chr=mean(chr),start=min(pos),end=max(pos)) %>% select(chr,start,end)
	write.table(reg,file=paste(mydir,'/results/FLK/',filename,'_fdr20_hapflk.regions',sep=''),quote=F,row.names=F,col.names=F)
}



