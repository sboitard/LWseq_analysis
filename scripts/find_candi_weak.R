rm(list=ls())

library(dplyr)
library(tidyr)
library(data.table)

args <- commandArgs(TRUE)
mydir=args[1]
filename=args[2]
chro=as.integer(args[3])
deb=as.integer(args[4])
fin=as.integer(args[5])
type=args[6]

res=array(dim=c(1,9),data=0) 
colnames(res)=c('chr','pos','flk','hapflk','df_LWD','s_LWD','df_LWS','s_LWS','F_MISS')

# load FLK
flk=read.table(paste(mydir,'/results/regions/hapflk_2pop/',filename,'_chro',chro,'_',deb,'-',fin,'.flk',sep=''),header=T)
flk = flk %>% select(pos,flk)
# load hapFLK
hapflk=read.table(paste(mydir,'/results/regions/hapflk_2pop/',filename,'_chro',chro,'_',deb,'-',fin,'.hapflk',sep=''),header=T)
hapflk = hapflk %>% select(pos,hapflk)
# load time_LWD
res_LWD = fread(paste(mydir,'/results/regions/time/',filename,'_chro',chro,'_',deb,'-',fin,'_LWD.csv',sep=''),head=T,select=c('ID','LMLE','L0','sMLE'))
res_LWD = res_LWD %>% separate(ID,into=c('CHR','pos'))
res_LWD$CHR = as.integer(res_LWD$CHR)
res_LWD$pos = as.integer(res_LWD$pos)
res_LWD = res_LWD %>% mutate(df_LWD=2*(LMLE-L0)) %>% select(pos,df_LWD,sMLE) %>% rename(s_LWD=sMLE)
# load time_LWS
res_LWS = fread(paste(mydir,'/results/regions/time/',filename,'_chro',chro,'_',deb,'-',fin,'_LWS.csv',sep=''),head=T,select=c('ID','LMLE','L0','sMLE'))
res_LWS = res_LWS %>% separate(ID,into=c('CHR','pos'))
res_LWS$CHR = as.integer(res_LWS$CHR)
res_LWS$pos = as.integer(res_LWS$pos)
res_LWS = res_LWS %>% mutate(df_LWS=2*(LMLE-L0)) %>% select(pos,df_LWS,sMLE) %>% rename(s_LWS=sMLE)
# merge
tab1=full_join(flk,hapflk,by='pos')
tab2=full_join(res_LWD,res_LWS,by='pos')
tab=full_join(tab1,tab2,by='pos')
# add missing rate
fmiss=read.table(paste(mydir,'/results/regions/missing/',filename,'_chro',chro,'_',deb,'-',fin,'.lmiss',sep=''),header=T)
fmiss = fmiss %>% select(SNP,F_MISS) %>% separate(SNP,into=c('CHR','pos')) %>% select(pos,F_MISS)
fmiss$pos = as.integer(fmiss$pos)
tab=left_join(tab,fmiss,by='pos')
	
# 10 best candidates of each test
p=min(10,dim(tab)[1])
tab_temp=tab[order(tab$flk,decreasing=T),]
flk_th=tab_temp$flk[p]
tab_temp=tab[order(tab$hapflk,decreasing=T),]
hapflk_th=tab_temp$hapflk[p]
tab_temp=tab[order(tab$df_LWD,decreasing=T),]
df_LWD_th=tab_temp$df_LWD[p]
tab_temp=tab[order(tab$df_LWS,decreasing=T),]
df_LWS_th=tab_temp$df_LWS[p]
tab=tab %>% filter(flk >= flk_th | hapflk >= hapflk_th | df_LWD >= df_LWD_th | df_LWS >= df_LWS_th)
tab=cbind(chro,tab)
colnames(tab)[1]='chr'
res=rbind(res,tab)

# write results
write.table(res[-1,],file=paste(mydir,'/results/regions/causal/',filename,'_chro',chro,'_',deb,'-',fin,'_weak.txt',sep=''),col.names=T,row.names=F,quote=F)





