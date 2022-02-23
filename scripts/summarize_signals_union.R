library(dplyr)
library(tidyr)

args <- commandArgs(TRUE)
mydir=args[1]

# import test names
tests=c('LWD','LWS','hapflk')
ntests=length(tests)

# imports sweeps
hapflk=read.table(paste(mydir,'/results/FLK/snp20_auto_cr_maf10_2pop_fdr20_hapflk.regions',sep=''))
colnames(hapflk)=c('Chr','Start','End')
hapflk=hapflk %>% mutate(test='hapflk') %>% select(test,Chr,Start,End)
df_LWD=read.table(paste(mydir,'/results/time/snp20_auto_cr_LWD_SL_xi3_signif1.regions',sep=''),head=T)
df_LWD=df_LWD %>% mutate(test='LWD') %>% select(test,Chr,Start,End)
df_LWS=read.table(paste(mydir,'/results/time/snp20_auto_cr_LWS_SL_xi3_signif1.regions',sep=''),head=T)
df_LWS=df_LWS %>% mutate(test='LWS') %>% select(test,Chr,Start,End)
tab1=rbind(df_LWD,df_LWS,hapflk)

# fusion of overlapping sweeps - union approach
tab2=array(data=0,dim=c(1,3+ntests)) # Chr Start End test1 ... test12
colnames(tab2)=c('Chr','Start','End',tests)
for (chro in 1:18){
	tab2_temp=array(dim=c(100,3+ntests),data=0)
	colnames(tab2_temp)=c('Chr','Start','End',tests)
	ind=which(tab1[,2]==chro)
	nb_loc=length(ind)
	if (nb_loc>0){
		# first sweep of the chromosome
		k=1
		tab1_temp=tab1[ind,]
		tab2_temp[1,1]=chro
		tab2_temp[1,2]=tab1_temp[1,3]
		tab2_temp[1,3]=tab1_temp[1,4]
		tab2_temp[1,tab1_temp[1,1]]=1
		# other sweeps of the chromosome
		if (nb_loc>1){
			for (i in 2:nb_loc){
				# look for overlapping sweeps in tab2_temp
				deb_new=tab1_temp[i,3]
				fin_new=tab1_temp[i,4]
				test_new=tab1_temp[i,1]
				ind=which((fin_new >= tab2_temp[1:k,2])&(deb_new <= tab2_temp[1:k,3]))
				S=length(ind)
				# no overlapping sweep
				if (S==0){
					k=k+1;
					tab2_temp[k,1]=chro
					tab2_temp[k,2]=tab1_temp[i,3]
					tab2_temp[k,3]=tab1_temp[i,4]
					tab2_temp[k,test_new]=1
				}
				# overlapping sweeps
				else {
					# creates a new 'union' swepp
					k=k+1
					tab2_temp[k,1]=chro
					tab2_temp[k,2]=min(c(tab2_temp[ind,2],deb_new))
					tab2_temp[k,3]=max(c(tab2_temp[ind,3],fin_new))
					for (itest in 1:ntests){
						tab2_temp[k,3+itest]=max(tab2_temp[ind,3+itest])
					}
					tab2_temp[k,test_new]=1	
					# puts old sweeps to NA
					tab2_temp[ind,1]=0				
				}
			}
		}
		tab2_temp=tab2_temp[1:k,]
		if (k>1){
			ind=which(tab2_temp[,1]==0)
			if (length(ind)>0){
				tab2_temp=tab2_temp[-ind,]
				k=k-length(ind)
			}
		}
		if (k>1){
			tab2_temp=tab2_temp[order(tab2_temp[,2]),]
		}
		tab2=rbind(tab2,tab2_temp)
	}
}
tab2=tab2[-1,]

write.table(tab2,file=paste(mydir,'/results/LW_summary_2pop.regions',sep=''),quote=F,col.names=T,row.names=F)







