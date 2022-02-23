library(data.table)
library(dplyr)
library(tidyr)
library(ggplot2)
library(RColorBrewer)

args <- commandArgs(TRUE)
mydir=args[1]

# res LWD
res_LWD = fread(paste(mydir,'/results/time/snp20_auto_cr_LWD_SL_xi3.txt',sep=''), head=T, select=c('chr','pos','pvalue','lindley','th'))
res_LWD = res_LWD %>% mutate(signif=(lindley>=th)) %>% select(chr,pos,pvalue,signif) %>% mutate(test='LWD')

# res LWS
res_LWS = fread(paste(mydir,'/results/time/snp20_auto_cr_LWS_SL_xi3.txt',sep=''), head=T, select=c('chr','pos','pvalue','lindley','th'))
res_LWS = res_LWS %>% mutate(signif=(lindley>=th)) %>% select(chr,pos,pvalue,signif) %>% mutate(test='LWS')

# Régions hapflk significatives
hapflk_signif=read.table(paste(mydir,'/results/FLK/snp20_auto_cr_maf10_2pop_fdr20_hapflk.txt',sep=''),head=T)
hapflk_signif=hapflk_signif %>% mutate(rs=paste(chr,pos,sep=':'))

# res hapflk
flk=fread(paste(mydir,'/results/FLK/snp20_auto_cr_maf10_2pop.hapflk_sc',sep=''),header=T,select=c('rs','chr','pos','pvalue'))
flk = flk %>% filter(!is.na(pvalue))
flk1 = flk %>% filter(rs %in% hapflk_signif$rs) %>% mutate(signif=T)
flk2 = flk %>% filter(!rs %in% hapflk_signif$rs) %>% mutate(signif=F)
flk=rbind(flk1,flk2) %>% select(chr,pos,pvalue,signif) %>% mutate(test='hapflk')
rm(flk1)
rm(flk2)

# merge datasets
res=rbind(flk,res_LWD,res_LWS) %>% mutate(log10_pval=log10(pvalue))
rm(res_110)
rm(res_220)
rm(flk)
ind=which(res$test=='hapflk')
res$log10_pval[ind]=-res$log10_pval[ind]

res1 = res %>% filter(signif==T) %>% mutate(signif2='signif')
res2 = res %>% filter(signif==F) %>% mutate(signif2='')
res=rbind(res1,res2) %>% mutate(test=paste(test,signif2,sep=' '))
rm(res1)
rm(res2)

# change factor order of test
res$test=factor(res$test,levels=c('LWD ','LWD signif','LWS ','LWS signif','hapflk ','hapflk signif'))

# P-valeurs le long du génome
m=min(res$log10_pval)
res=res %>% mutate(star=0)
ind=which(res$test=='LWS signif')
res$star[ind]=m-1
ind=which(res$test=='LWD signif')
res$star[ind]=m-0.5
res$pos=res$pos/1000000
# one single file
#p=ggplot(res,aes(x=pos,y=log10_pval,colour=test))+geom_point()+theme_bw() +facet_wrap(~chr,scales='free_x',nrow=6,ncol=3) +scale_colour_manual(name='Test',values = brewer.pal(6,'Paired'))
#p=p+geom_point(aes(x=pos,y=star,colour=test),shape=17)
#ggsave(paste(mydir,'/results/LW_summary_2pop_plot.png',sep=''), plot = p, width = 18, height = 18)
# two files
M=max(res$log10_pval)
m=min(res$log10_pval)
res2 = res %>% filter(chr<10)
p=ggplot(res2,aes(x=pos,y=log10_pval,colour=test))+geom_point()+theme_bw() +facet_wrap(~chr,scales='free_x',nrow=3,ncol=3) +scale_colour_manual(name='Test',values = brewer.pal(6,'Paired'))+ylim(m,M)+xlab('position (Mb)')+ylab('log10(pvalue)')
p=p+geom_point(aes(x=pos,y=star,colour=test),shape=17)
ggsave(paste(mydir,'/results/LW_summary_2pop_plot1.png',sep=''), plot = p, width = 9, height = 6)
res2 = res %>% filter(chr>=10)
p=ggplot(res2,aes(x=pos,y=log10_pval,colour=test))+geom_point()+theme_bw() +facet_wrap(~chr,scales='free_x',nrow=3,ncol=3) +scale_colour_manual(name='Test',values = brewer.pal(6,'Paired'))+ylim(m,M)+xlab('position (Mb)')+ylab('log10(pvalue)')
p=p+geom_point(aes(x=pos,y=star,colour=test),shape=17)
ggsave(paste(mydir,'/results/LW_summary_2pop_plot2.png',sep=''), plot = p, width = 9, height = 6)

