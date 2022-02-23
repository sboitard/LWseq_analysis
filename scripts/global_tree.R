args <- commandArgs(TRUE)
filename=args[1]


library(ape)
mytree=read.tree(paste(filename,'_tree.txt',sep=''))
pdf(paste(filename,'_tree.pdf',sep=''))
plot(mytree,align=T)
axis(1,line=1.5)
title(xlab='F')
dev.off()
