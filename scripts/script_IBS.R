library(dplyr)
library(tidyr)
library(ggplot2)
library(gridExtra)

args <- commandArgs(TRUE)
filename=args[1]
mydir=args[2]

# loads IBR matrix and individual names
matrice_IBS=1-read.table(paste(mydir,'/plink_files/',filename,'.mibs',sep=""),stringsAsFactors=F)
ped=read.table(paste(mydir,'/plink_files/',filename,'.mibs.id',sep=""),stringsAsFactors=F)

# MDS analysis
mds=cmdscale(matrice_IBS,k=2)
res=cbind(ped,mds)
colnames(res)=c('population','indiv',paste('C',1:2,sep=''))

# plot first two components
p=ggplot(res,aes(x=C1,y=C2,colour=population))+geom_point(alpha=0.5)+theme_bw()
ggsave(paste(mydir,'/results/diversity/',filename,'.png',sep=''), plot = p, width = 5, height = 4)


