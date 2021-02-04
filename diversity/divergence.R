library(ggplot2)
library(dplyr)

pi <- read.table("somalense.diversity.100kb.all.windowed.pi", header=T)
piEx <- read.table("somalense.diversity.100kb.exons.windowed.pi", header=T)
piG <- read.table("somalense.diversity.100kb.gene.windowed.pi", header=T)
piI <- read.table("somalense.diversity.100kb.intron.windowed.pi", header=T)
piIg <- read.table("somalense.diversity.100kb.intergenic.windowed.pi", header=T)

pi <- pi[,c(1,2,4,5)]
names(pi) <- c("Chrom","Pos","region","pi")
pi$region <- "all"

piEx <- piEx[,c(1,2,4,5)]
names(piEx) <- c("Chrom","Pos","region","pi")
piEx$region <- "exon"

piG <- piG[,c(1,2,4,5)]
names(piG) <- c("Chrom","Pos","region","pi")
piG$region <- "gene"

piI <- piI[,c(1,2,4,5)]
names(piI) <- c("Chrom","Pos","region","pi")
piI$region <- "intron"

piIg <- piIg[,c(1,2,4,5)]
names(piIg) <- c("Chrom","Pos","region","pi")
piIg$region <- "intergenic"

piAll <- rbind(pi, piEx, piG, piI, piIg)
piAll <- piAll[,-2]

options(scipen = 999)
ggplot(piAll, aes(x=region, y=pi, fill=Chrom)) + geom_boxplot() + scale_y_log10()

summary(pi)
summary(piG)

pi %>%
  group_by(Chrom) %>%
  summarize(mean_size = mean(pi, na.rm = TRUE))


piG %>%
  group_by(Chrom) %>%
  summarize(mean_size = mean(pi, na.rm = TRUE))




Dpi <- read.table("gossypioides.diversity.100kb.all.windowed.pi", header=T)
DEx <- read.table("gossypioides.diversity.100kb.exons.windowed.pi", header=T)
DG <- read.table("gossypioides.diversity.100kb.gene.windowed.pi", header=T)
DI <- read.table("gossypioides.diversity.100kb.intron.windowed.pi", header=T)
DIg <- read.table("gossypioides.diversity.100kb.intergenic.windowed.pi", header=T)

Dpi <- Dpi[,c(1,2,4,5)]
names(Dpi) <- c("Chrom","Pos","region","pi")
Dpi$region <- "all"

DEx <- DEx[,c(1,2,4,5)]
names(DEx) <- c("Chrom","Pos","region","pi")
DEx$region <- "exon"

DG <- DG[,c(1,2,4,5)]
names(DG) <- c("Chrom","Pos","region","pi")
DG$region <- "gene"

DI <- DI[,c(1,2,4,5)]
names(DI) <- c("Chrom","Pos","region","pi")
DI$region <- "intron"

DIg <- DIg[,c(1,2,4,5)]
names(DIg) <- c("Chrom","Pos","region","pi")
DIg$region <- "intergenic"

DAll <- rbind(Dpi, DEx, DG, DI, DIg)
DAll <- DAll[,-2]



Api <- read.table("arboreum.diversity.100kb.all.windowed.pi", header=T)
AEx <- read.table("arboreum.diversity.100kb.exons.windowed.pi", header=T)
AG <- read.table("arboreum.diversity.100kb.gene.windowed.pi", header=T)
AI <- read.table("arboreum.diversity.100kb.intron.windowed.pi", header=T)
AIg <- read.table("arboreum.diversity.100kb.intergenic.windowed.pi", header=T)

Api <- Api[,c(1,2,4,5)]
names(Api) <- c("Chrom","Pos","region","pi")
Api$region <- "all"

AEx <- AEx[,c(1,2,4,5)]
names(AEx) <- c("Chrom","Pos","region","pi")
AEx$region <- "exon"

AG <- AG[,c(1,2,4,5)]
names(AG) <- c("Chrom","Pos","region","pi")
AG$region <- "gene"

AI <- AI[,c(1,2,4,5)]
names(AI) <- c("Chrom","Pos","region","pi")
AI$region <- "intron"

AIg <- AIg[,c(1,2,4,5)]
names(AIg) <- c("Chrom","Pos","region","pi")
AIg$region <- "intergenic"

AAll <- rbind(Api, AEx, AG, AI, AIg)
AAll <- AAll[,-2]




DAll$species <- "D"
AAll$species <- "A"
piAll$species <- "E"



both <- rbind(piAll,DAll,AAll)

ggplot(both, aes(x=region, y=pi, fill=species)) + geom_boxplot() + scale_y_log10()
