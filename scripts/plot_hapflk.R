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

# significance threshold for a FDR of 15%
q.hapflk=read.table(paste(mydir,'/results/FLK/',filename,'_fdr15_hapflk.txt',sep=''),head=T)
s.hapflk=max(q.hapflk$pval)

# p-value plots
hapflk = hapflk %>% mutate(log10_pvalue=-log10(pvalue))
M=max(hapflk$log10_pvalue)
p=ggplot(hapflk,aes(x=pos,y=log10_pvalue))+geom_point()+theme_bw()+scale_y_continuous(limits=c(0,M)) +facet_wrap(~chr,scales='free',nrow=6,ncol=3)
p=p+geom_hline(aes(yintercept=-log10(s.hapflk)),color='red')
ggsave(paste(mydir,'/results/FLK/',filename,'_fdr15_hapflk_pval.png',sep=''), plot = p, width = 18, height = 18)


