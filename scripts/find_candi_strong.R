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
# add a column indicating functionnal SNPs
funcname=paste(mydir,'/results/regions/causal/',filename,'_chro',chro,'_',deb,'-',fin,'_weak.func',sep='')
if (file.size(funcname)>0){
	func=read.table(funcname,head=F)
	funcpos=func[,2]
	taba=tab %>% filter (pos %in% funcpos) %>% mutate(func=T)
	tabb=tab %>% filter (!pos %in% funcpos) %>% mutate(func=F)
	tab=rbind(taba,tabb)
	print(taba)
} else {
	tab=tab %>% mutate(func=F)
}
# save this unfiltered table and computes missing rates of sliding windows
tab0=tab
tab0=tab0 %>% mutate(av_miss=0)
for (i in 1:dim(tab0)[1]){
	temp=tab0%>% filter(pos>=(tab0$pos[i]-1000)&pos<=(tab0$pos[i]+1000))
	tab0$av_miss[i]=mean(temp$F_MISS)
}
# selects valid candidates
print(dim(tab)[1])
ind_conv=which(tab$s_LWD*tab$s_LWS>=0)
ind_div=which(tab$s_LWD*tab$s_LWS<=0)
if ((type=='conv(LWD)') | (type=='conv(LWS)') | (type=='conv')){
	tab=tab[ind_conv,]
}
if (type=='div'){
	tab=tab[ind_div,]
}
tab = tab %>% filter(F_MISS <= 0.2)
print(dim(tab)[1])
# adapts the number of variants selected
r0=0.01
p=round(r0*dim(tab)[1])
p=max(min(p,10),2)
if ((type=='div') | (type=='conv')){
	p=p/2
}
print(p)	
# p best candidates of each test
tab_temp=tab[order(tab$flk,decreasing=T),]
flk_th=tab_temp$flk[p]
tab_temp=tab[order(tab$hapflk,decreasing=T),]
hapflk_th=tab_temp$hapflk[p]
tab_temp=tab[order(tab$df_LWD,decreasing=T),]
df_LWD_th=tab_temp$df_LWD[p]
tab_temp=tab[order(tab$df_LWS,decreasing=T),]
df_LWS_th=tab_temp$df_LWS[p]
tab=cbind(chro,tab)
colnames(tab)[1]='chr'
# filter
png(paste(mydir,'/results/regions/causal/',filename,'_chro',chro,'_',deb,'-',fin,'_strong.png',sep=''),width=960)
if (type=='div'){	
	yM=max(max(tab$flk),max(tab$hapflk))	
	# passing filters
	plot(tab$pos,tab$flk,pch=20,ylim=c(-1,yM+2),col='purple',xlab='position',ylab='statistic')
	points(tab$pos,tab$hapflk,pch=20,col='red')
	tabtemp=tab %>% filter(func==T)
	points(tabtemp$pos,tabtemp$hapflk,pch=20,cex=1.5)
	points(tabtemp$pos,tabtemp$flk,pch=20,cex=1.5)
	# candidates
	tabtemp=tab %>% filter(flk >= flk_th)
	points(tabtemp$pos,tabtemp$flk,pch=17,col='purple',cex=1.5)
	tabtemp=tab %>% filter(hapflk >= hapflk_th)
	points(tabtemp$pos,tabtemp$hapflk,pch=17,col='red',cex=1.5)
	tabtemp=tab %>% filter(func==T & (flk >= flk_th | hapflk >= hapflk_th))
	points(tabtemp$pos,tabtemp$hapflk,pch=17,cex=1.5)
	points(tabtemp$pos,tabtemp$flk,pch=17,cex=1.5)
	# call rate
	points(tab0$pos,-tab0$av_miss,pch=20,cex=0.5)
	# not passing filters
	tab0=tab0 %>% filter(!pos %in% tab$pos)
	points(tab0$pos,tab0$flk,pch=4,col='purple',cex=1) # previously 0.5
	points(tab0$pos,tab0$hapflk,pch=4,col='red',cex=1)
	tab0=tab0 %>% filter(func==T)
	points(tab0$pos,tab0$flk,pch=4,cex=1)
	points(tab0$pos,tab0$hapflk,pch=4,cex=1)
	legend("topleft",pch=c(20,20,20),col=c('purple','red','black'),legend=c('FLK','hapFLK','functional'),ncol=3)
	legend("topright",pch=c(4,20,17),legend=c('invalid','valid','candidate'),ncol=3)
	tab=tab %>% filter(flk >= flk_th | hapflk >= hapflk_th)
}
if (type=='conv'){
	yM=max(max(tab$df_LWD),max(tab$df_LWS))
	# passing filters	
	plot(tab$pos,tab$df_LWD,pch=20,ylim=c(-1,yM+2),col='blue',xlab='position',ylab='statistic')
	points(tab$pos,tab$df_LWS,pch=20,col='green')
	tabtemp=tab %>% filter(func==T)
	points(tabtemp$pos,tabtemp$df_LWD,pch=20,cex=1.5)
	points(tabtemp$pos,tabtemp$df_LWS,pch=20,cex=1.5)
	# candidates
	tabtemp=tab %>% filter(df_LWD >= df_LWD_th)	
	points(tabtemp$pos,tabtemp$df_LWD,pch=17,col='blue',cex=1.5)
	tabtemp=tab %>% filter(df_LWS >= df_LWS_th)	
	points(tabtemp$pos,tabtemp$df_LWS,pch=17,col='green',cex=1.5)
	tabtemp=tab %>% filter(func==T & (df_LWD >= df_LWD_th | df_LWS >= df_LWS_th))
	points(tabtemp$pos,tabtemp$df_LWD,pch=17,cex=1.5)
	points(tabtemp$pos,tabtemp$df_LWS,pch=17,cex=1.5)
	# call rate
	points(tab0$pos,-tab0$av_miss,pch=20,cex=0.5)
	# not passing filters
	tab0=tab0 %>% filter(!pos %in% tab$pos)
	points(tab0$pos,tab0$df_LWD,pch=4,col='blue',cex=1) # previously 0.5
	points(tab0$pos,tab0$df_LWS,pch=4,col='green',cex=1)
	tab0=tab0 %>% filter(func==T)
	points(tab0$pos,tab0$df_LWD,pch=4,cex=1)
	points(tab0$pos,tab0$df_LWS,pch=4,cex=1)
	legend("topleft",pch=c(20,20,20),col=c('blue','green','black'),legend=c('LWD','LWS','functional'),ncol=3)
	legend("topright",pch=c(4,20,17),legend=c('invalid','valid','candidate'),ncol=3)
	tab=tab %>% filter(df_LWD >= df_LWD_th | df_LWS >= df_LWS_th)
}
if ((type=='conv(LWD)')|(type=='LWD')){
	# passing filters
	plot(tab$pos,tab$df_LWD,pch=20,ylim=c(-1,max(tab$df_LWD)+2),col='blue',xlab='position',ylab='statistic')
	tabtemp=tab %>% filter(func==T)
	points(tabtemp$pos,tabtemp$df_LWD,pch=20,cex=1.5)
	# candidates
	tab=tab %>% filter(df_LWD >= df_LWD_th)
	points(tab$pos,tab$df_LWD,pch=17,col='blue',cex=1.5)
	tabtemp=tab %>% filter(func==T & df_LWD >= df_LWD_th)
	points(tabtemp$pos,tabtemp$df_LWD,pch=17,cex=1.5)
	# call rate
	points(tab0$pos,-tab0$av_miss,pch=20,cex=0.5)
	# not passing filters
	tab0=tab0 %>% filter(!pos %in% tab$pos)
	points(tab0$pos,tab0$df_LWD,pch=4,col='blue',cex=1) # previously 0.5
	tab0=tab0 %>% filter(func==T)
	points(tab0$pos,tab0$df_LWD,pch=4,cex=1)
	legend("topleft",pch=c(20,20),col=c('blue','black'),legend=c('LWD','functional'),ncol=2)
	legend("topright",pch=c(4,20,17),legend=c('invalid','valid','candidate'),ncol=3)
}
if ((type=='conv(LWS)')|(type=='LWS')){
	# passing filters
	plot(tab$pos,tab$df_LWS,pch=20,ylim=c(-1,max(tab$df_LWS)+2),col='green',xlab='position',ylab='statistic')
	tabtemp=tab %>% filter(func==T)
	points(tabtemp$pos,tabtemp$df_LWS,pch=20,cex=1.5)
	# candidates
	tab=tab %>% filter(df_LWS >= df_LWS_th)
	points(tab$pos,tab$df_LWS,pch=17,col='green',cex=1.5)
	tabtemp=tab %>% filter(func==T & df_LWS >= df_LWS_th)
	points(tabtemp$pos,tabtemp$df_LWS,pch=17,cex=1.5)
	# call rate
	points(tab0$pos,-tab0$av_miss,pch=20,cex=0.5)
	# not passing filters
	tab0=tab0 %>% filter(!pos %in% tab$pos)
	points(tab0$pos,tab0$df_LWS,pch=4,col='green',cex=1) # previously 0.5
	tab0=tab0 %>% filter(func==T)
	points(tab0$pos,tab0$df_LWS,pch=4,cex=1)
	legend("topleft",pch=c(20,20),col=c('green','black'),legend=c('LWS','functional'),ncol=2)
	legend("topright",pch=c(4,20,17),legend=c('invalid','valid','candidate'),ncol=3)
}
abline(h=-0.5,lwd=0.5,lty=2)
abline(h=-1,lty=2)
dev.off()
res=rbind(res,tab %>% select(-func))

# write results
write.table(res[-1,],file=paste(mydir,'/results/regions/causal/',filename,'_chro',chro,'_',deb,'-',fin,'_strong.txt',sep=''),col.names=T,row.names=F,quote=F)





