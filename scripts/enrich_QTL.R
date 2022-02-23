library(tidyverse)
library(GDAtools)

args <- commandArgs(TRUE)
mydir=args[1]

# load and format data
qtl=read.table(paste0(mydir,'/input_files/QTL_list.csv'),head=T,sep=';')
qtl = qtl %>% select(-Ordre,-Caractère)
qtl = qtl %>% distinct() # filter redundant qtls
qtl=qtl %>% select(Region,Femelle,BothM,M.F,No) %>% arrange(Region)
qtl=qtl %>% group_by(Region) %>% summarize(Both.Sire=sum(BothM),Dam=sum(Femelle),Both=sum(M.F),None=sum(No))
sel=read.table(paste0(mydir,'/results/LW_summary_full.txt'),head=T)
sel=sel %>% select(Id,Category) %>% rename(Region=Id)
qtl=inner_join(qtl,sel) # add region category
qtl = qtl %>% select(Region,Category,Both.Sire,Dam,Both,None)
qtl=qtl %>% gather(Line,Weight,3:6)

# contingency table
qtl=qtl%>%filter(Line!='None')
tab=wtable(qtl$Category,qtl$Line,weights=qtl$Weight)
tab=tab[-7,-4]
res=chisq.test(tab)
qtl=qtl %>% group_by(Line,Category) %>% summarize(Weight=sum(Weight))
qtl = qtl %>% mutate(residuals=0)
for (i in 1:dim(tab)[1]){
	sel.type=row.names(tab)[i]
	for (j in 1:dim(tab)[2]){
		qtl.type=colnames(tab)[j]
		k=which((qtl$Category==sel.type)&(qtl$Line==qtl.type))
		qtl$residuals[k]=res$residuals[i,j]
	}
}

# plot
qtl$Line<-factor(qtl$Line,c("Dam","Both.Sire","Both"))
qtl$Category<-factor(qtl$Category,c("LWD","LWS","conv(LWD)","conv(LWS)","conv","div"))

p=ggplot(data = qtl, aes(x = Category, y = Line)) +
  geom_tile(aes(fill = residuals)) +
  geom_text(aes(label = Weight), color = "black", fontface = "bold", size = 6) +
  scale_fill_gradient("Chi-square \n residuals \n", low = "lightblue", high = "blue") +
  theme_bw() + 
  labs(x = "\n Selection category", y = "Trait selected in", 
       title = "Weighted number of QTLs \n",
       fill = "Answer \n")
ggsave(paste0(mydir,'/results/enrich/enrich_QTL.jpg'),plot = p, width = 6, height = 4)



