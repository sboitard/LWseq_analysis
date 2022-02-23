library(dplyr)
library(data.table)

args <- commandArgs(TRUE)
mydir=args[1]
filename=args[2]
pop=args[3]

# load frequency file
df <- fread(paste0(mydir,'/plink_files/',filename,'.frq.strat'), header = T)
df = df %>% filter(CLST==pop | CLST=='1977')

# overall maf
dfsnp = df %>% group_by(SNP) %>% summarise(mean = mean(MAF)) %>% filter(mean > 0 & mean < 1)
df = df %>% filter(SNP %in% dfsnp$SNP)

df$CLST[df$CLST=='1977']=1
df$CLST[df$CLST==pop]=21

# put at NB format and export
df$CAM <- df$NCHROBS - df$MAC
df = df %>% arrange(CLST,SNP)

for (i in c(1,21)){
	infileNB=paste0(mydir,'/plink_files/',filename,'_NB_input_G',i,'.txt')
	dftemp= df %>% filter(CLST==as.character(i))
	print(head(dftemp))
	print(tail(dftemp))	
 	dftemp = dftemp %>% select(MAC,CAM)
	write.table(dftemp,infileNB,col.names = FALSE,row.names = FALSE)
}






