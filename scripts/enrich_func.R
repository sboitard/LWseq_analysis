library(tidyverse)
library(GDAtools)

args <- commandArgs(TRUE)
mydir=args[1]
dbname=args[2]

# load data
GO=read.table(paste0(mydir,'/results/enrich/',dbname,'_nbgenes.csv'),head=T,sep=';')
colnames(GO)[6]='conv.LWD'
colnames(GO)[7]='conv.LWS'
GO=GO %>% mutate(annot=paste(annot,pval,sep=', pval='))

# new categories
GO = GO %>% mutate(Both=conv.LWS+conv.LWD+conv,Both.Sire=conv.LWS+LWS+conv,Dam=LWD+conv.LWD+div) %>% select(-conv.LWD,-conv.LWS,-LWD,-LWS,-conv,-div)

# compute chi2 residuals
chi2=chisq.test(GO[,4:6])
chi2.res=cbind(GO[,1:2],chi2$residuals)

# top 20 pval
GO=GO[1:20,]
chi2.res=chi2.res[1:20,]
temp=GO %>% arrange(-pval)
terms=temp$annot

# reshape and merge tables
GO=GO %>% gather(Category,Weight,4:6)
chi2.res=chi2.res %>% select(-annot) %>% gather(Category,residuals,2:4)
GO=inner_join(GO,chi2.res)

# plot
GO$Category<-factor(GO$Category,c("Both","Both.Sire","Dam"))
GO$annot=factor(GO$annot,terms)
p=ggplot(data = GO, aes(x = Category, y = annot)) + geom_tile(aes(fill = residuals)) +
  geom_text(aes(label = Weight), color = "black", fontface = "bold", size = 6) +
  scale_fill_gradient("Chi-square \n residuals \n", low = "lightblue", high = "blue") + theme_bw() + 
  labs(x = "\n Selection category", y = paste0(dbname,' term'), 
       title = "Number of genes \n",
       fill = "Answer \n")
ggsave(paste0(mydir,'/results/enrich/',dbname,'_merged.jpg'),plot = p, width = 10, height = 6)

