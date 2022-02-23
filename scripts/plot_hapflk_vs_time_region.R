rm(list=ls())

library(dplyr)
library(tidyr)
library(ggplot2)
library(data.table)
library(gridExtra)

args <- commandArgs(TRUE)
mydir=args[1]
filename=args[2]
chro=as.integer(args[3])
deb=as.integer(args[4])
fin=as.integer(args[5])

# load FLK
flk=read.table(paste(mydir,'/results/regions/hapflk_2pop/',filename,'_chro',chro,'_',deb,'-',fin,'.flk',sep=''),header=T)
flk = flk %>% select(pos,flk)
# load hapFLK
hapflk=read.table(paste(mydir,'/results/regions/hapflk_2pop/',filename,'_chro',chro,'_',deb,'-',fin,'.hapflk',sep=''),header=T)
hapflk = hapflk %>% select(pos,hapflk)
# load time LWD
res_LWD = fread(paste(mydir,'/results/regions/time/',filename,'_chro',chro,'_',deb,'-',fin,'_LWD.csv',sep=''),head=T,select=c('ID','LMLE','L0'))
res_LWD = res_LWD %>% separate(ID,into=c('CHR','pos'))
res_LWD$CHR = as.integer(res_LWD$CHR)
res_LWD$pos = as.integer(res_LWD$pos)
res_LWD = res_LWD %>% filter(CHR==chro & pos >= deb & pos <=fin) %>% mutate(LWD=2*(LMLE-L0)) %>% select(pos,LWD)
res_LWD$LWD=-res_LWD$LWD
# load time LWS
res_LWS = fread(paste(mydir,'/results/regions/time/',filename,'_chro',chro,'_',deb,'-',fin,'_LWS.csv',sep=''),head=T,select=c('ID','LMLE','L0'))
res_LWS = res_LWS %>% separate(ID,into=c('CHR','pos'))
res_LWS$CHR = as.integer(res_LWS$CHR)
res_LWS$pos = as.integer(res_LWS$pos)
res_LWS = res_LWS %>% filter(CHR==chro & pos >= deb & pos <=fin) %>% mutate(LWS=2*(LMLE-L0)) %>% select(pos,LWS)
res_LWS$LWS=-res_LWS$LWS
# merge
tab1=full_join(flk,hapflk,by='pos')
tab2=full_join(res_LWD,res_LWS,by='pos')
tab=full_join(tab1,tab2,by='pos')
tab = tab %>% gather(flk,hapflk,LWD,LWS,key=Test,value=score)
M=max(tab$score,na.rm=T)
m=min(tab$score,na.rm=T)

# genes in the region
genes=read.table(paste(mydir,'/results/LW_candidate_genes_2pop_v2.txt',sep=''),stringsAsFactors=F)
colnames(genes)=c('gene','chr','start','end')
genes = genes %>% filter(chr==chro & end >= deb & start <=fin)
n=dim(genes)[1]
if (n>0){
	genes = genes %>% mutate(x0=0,x1=0,pos=0,y=0)
	for (i in 1:n){
		genes$x0[i]=max(deb,genes[i,3])
		genes$x1[i]=min(fin,genes[i,4])
		genes$pos[i]=mean(c(genes$x0[i],genes$x1[i]))
		genes$y[i]=i-1
	}
}

# change factor order of test
tab$Test=factor(tab$Test,levels=c('hapflk','LWS','LWD','flk'))

# plot
if (n>0){
	p1=ggplot(tab,aes(x=pos,y=score,color=Test))+geom_point()+theme(legend.position='top')+scale_x_continuous(limits=c(deb,fin))+xlab('position')
	p2=ggplot(genes)+scale_x_continuous(limits=c(deb,fin))+scale_y_continuous(limits=c(0,n))+theme_bw()+xlab('position')+ylab('')
	p2=p2+geom_text(aes(x=pos,y=y+0.5,label=gene),color='black')+geom_segment(aes(x=x0,y=y+0.1,xend=x1,yend=y+0.1),lwd=2,color='black')
	p=grid.arrange(p1,p2,nrow=2,ncol=1,heights=c(6,2))
	ggsave(paste(mydir,'/results/regions/stat_profiles/',filename,'_chro',chro,'_',deb,'-',fin,'_scores.png',sep=''), plot = p, width = 6, height = 6)
} else {
	p1=ggplot(tab,aes(x=pos,y=score,color=Test))+geom_point()+theme(legend.position='top')+scale_x_continuous(limits=c(deb,fin))+xlab('position')
	ggsave(paste(mydir,'/results/regions/stat_profiles/',filename,'_chro',chro,'_',deb,'-',fin,'_scores.png',sep=''), plot = p1, width = 6, height = 4)
}

