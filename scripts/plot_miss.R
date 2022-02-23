library(ggplot2)

args <- commandArgs(TRUE)
filename=args[1]

u=read.table(paste(filename,'.imiss',sep=''),head=T)
p=ggplot(u,aes(x=F_MISS,fill=FID))+geom_density(alpha=0.5)+theme_bw()
ggsave(paste(filename,'_imiss.pdf',sep=''), plot = p, width = 4, height = 4)

