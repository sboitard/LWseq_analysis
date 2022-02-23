library(dplyr)
library(tidyr)
library(ggplot2)

args <- commandArgs(TRUE)
filename=args[1]
mydir=args[2]
pop=args[3]

# load data
u=read.table(file=paste(mydir,'/results/time/',filename,'_SL_xi3.txt',sep=''),head=T)
u = u %>% select(chr,pos,pvalue)

# pvalue distribution
p=ggplot(u,aes(x=pvalue))+geom_histogram()+theme_bw() +xlab('p-value')+ylab('number of SNPs')+ggtitle(pop)+theme(plot.title=element_text(hjust = 0.5)) 
ggsave(paste(mydir,'/results/time/',filename,'_hist.png',sep=''),plot = p, width = 4, height = 4)

# single SNP significance - FDR 20%
#library(qvalue)
#q=qvalue(u$pvalue,fdr.level=0.2)
#print(summary(q$qval))
#l=sum(q$significant)
#if (l>0){
#	write.table(cbind(u[q$significant,],q$qval[q$significant]),file=paste(mydir,'/results/time/',filename,'_fdr20.txt',sep=''),col.names=c(colnames(u),'qvalue'),row.names=F,quote=F)
#}
