##########
## Dendro
##########

rm(list=ls())
graphics.off()

source('read_fh_special.R')


############################################################
### PLOT
############################################################
#load library
library(dplR)
library(utils)
library(stringr)
library(Hmisc)

#set working directory
#setwd('D:/OneDrive - uibk.ac.at/dendro/')
setwd('E:/OneDrive - uibk.ac.at/dendro/')

#load data_s
data_s = read.fh.special('ihbd_uebung_dat_udat_i_a_final_wtht_undated.fh') #manipulated by hand

#data_s$species = as.character(data_s$species)

##define color lines

color.fi <- rgb(62, 193, 71, max=255)
color.lade <- rgb(255, 0, 0, max=255)

data_s$color = "#FFFFFF"
for (i in seq(nrow(data_s))) {
  if (data_s$species[i] == "LADE"){
    data_s$color[i] = color.lade
  } 
  if (data_s$species[i] == "PCAB") {
    data_s$color[i] = color.fi
  }
}


####define color points WK
data_s$colorwk = "#FFFFFF"
for (i in seq(nrow(data_s))) {
  if (data_s$waldkante[i] == "WKE"){
    data_s$colorwk[i] = "#b10026"
  } 
  if (data_s$waldkante[i] == "WKL") {
    data_s$colorwk[i] ="#3182bd"
  }
}

####define color points P
data_s$colorp = "#FFFFFF"
for (i in seq(nrow(data_s))) {
  if (is.na(data_s$pith[i]) == F && data_s$pith[i] =="P") {
    data_s$colorp[i] = "#c51b8a"
  } 
}



#sort for better viewability
data_s_sort = data_s[order(data_s$end.years),]

NAMES = as.character(rownames(data_s_sort))
NAMES = str_sub(NAMES, end=-3)
seq.col <- seq_len(nrow(data_s_sort))




######
## PLOT LINE DIAGRAMM
#plot version ii labels front
######
jpeg(filename = "lineplot_series.jpeg",
     width = 1200, height = 800, units = "px", pointsize = 20,
     quality = 100)

par(mar=c(5.1,4.1, 10,2.1),oma=c(1,2,1,2))  #3  4.1
plot(0, type="n", xlab="", ylab="", xlim=c(min(data_s$start.years-12), max(data_s$end.years)+8), ylim=c(1, nrow(data_s_sort)), yaxt='n', ann=FALSE, bty="n", xaxt="n")
axis(1, at=c(seq(1570,1780,1)), cex.axis=0.9,tck=-0.02, labels=F )
axis(1, at=c(seq(1570,1780,10)), cex.axis=0.9,tck=-0.04, labels=T )
axis(2, labels = F, tick = F)
axis(3, at=c(seq(1570,1780,1)), cex.axis=0.9,tck=-0.02, labels=F )
axis(3, at=c(seq(1570,1780,10)), cex.axis=0.9,tck=-0.04, labels=T )

for (i in seq(1,nrow(data_s_sort))){ 
  segments(x0 = data_s_sort$start.years[i], x1 = data_s_sort$end.years[i], y0 = i, y1 = i, lwd = 8, col =data_s_sort$color[i])
  points(x=data_s_sort$end.years[i]+3, y=i,  pch = 17,cex=1.5, col =data_s_sort$colorwk[i]) #wk
  points(x=data_s_sort$start.years[i]-3, y=i,  pch = 16,cex=1.5, col =data_s_sort$colorp[i]) #p
  text(x=data_s_sort$end.years[i]+10, y=i, labels = data_s_sort$end.years[i], cex = 0.9)
  text(x=data_s_sort$start.years[i]-11, y=i, labels=NAMES[i], cex= 0.9)
}

legend(x=c(1560,1595),y=c(25,24), legend=c("Fichte", "Lärche"),
       col=c(color.fi, color.lade), lty=1:1, lwd = 8, cex=0.8, bg="transparent",box.lty=0) #, x.intersp = 0.5, y.intersp = 0.5
legend(x=c(1560,1595),y=c(22,21), legend=c("WK Sommer", "WK Winter", "Kern"), col=c("#b10026","#3182bd","#c51b8a" ), pch = c(17,17,16),pt.cex = c(1.5,1.5,1.5), cex=0.8, bg="transparent",box.lty=0) # , x.intersp = 0.5, y.intersp = 0.5

mtext(text="Jahre", side=1, line=2)
#minor.tick(nx=10, ny=1, tick.ratio=0.5) #, x.args = list(), y.args = list()
abline(v = seq(1600,1750,50), lty=2, lwd=1)

dev.off()


#############################################
####plots ext
#############################################

######################################
data_fi = read.fh('fi_tirol_vergleichsreihe.fh') #fi_tirol
dates = row.names(data_fi)
dates  = as.numeric(as.character(unlist(dates)))

data = read.fh('ihbd_uebung_dat_udat_i_a_final_wtht_undated.fh') #manipulated by hand
dates_ = row.names(data)
dates_  = as.numeric(as.character(unlist(dates_)))

data.rwi <- detrend(rwl = data, method = "ModNegExp")

data.rwi.fi = data.rwi[-c(13,14)]  # only data fichte
data.rwi.lade = data.rwi[c(13,14)]  # only data lade



####
#color

color.fi.tr <- adjustcolor(color.fi, alpha.f = 0.5)
color.lade.tr <- adjustcolor(color.lade, alpha.f = 0.5)


######
#plot all // dif lade / fi
######

#####test
#c(bottom,left,top,right) mai = ; oma = outer margin; mar = margin; 
jpeg(filename = "chronoplot.jpeg",
     width = 1200, height = 800, units = "px", pointsize = 20,
     quality = 100)



par(mfrow=c(2,1), mai = c(1, 0.1, 0.1, 0.1),oma=c(2,0,1,2),mar=c(1,4.1,1,2.1))

plot(0, type="n", xlab="", ylab="", xlim=c(min(dates), max(dates)+2), ylim=c(0,2), yaxt='n', ann=FALSE, xaxt="n", bty="n")
axis(2, labels = F, tick = F)

for (i in seq(1,ncol(data.rwi.fi))){ #seq(1,nrow(data))
  lines(dates_,data.rwi.fi[,i], col =color.fi.tr, lwd=1.3)
}
for (i in seq(1,ncol(data.rwi.lade))){ #seq(1,nrow(data))
  lines(dates_,data.rwi.lade[,i], col=color.lade.tr, lwd=1.3)
}


legend(x=c(1570,1595),y=c(1.9,1.8), legend=c("Fichte", "Lärche"),
       col=c(color.fi, color.lade), lty=1:1, lwd = 1, cex=0.8, bg="transparent",box.lty=0, horiz=F) # x.intersp = 0.5, y.intersp = 0.5,

mtext(text="Jahrringbreite [index.]", side = 2, line = 1)
mtext(text="-----------------------------------------------------", side = 2, line = 0 ,cex = 0.8)
title(main="a)", line = -1, adj=0.01)

######
#plot fi // ref fi
######

data.cr <- chron(data.rwi.fi, prefix = "ihb")

##select all where data.crn sample depth >=3
data.crn= subset(data.cr, samp.depth>2)

#x dates for shorter 
dates_sh = seq(min(rownames(data.crn)),max(rownames(data.crn)),1) 


plot(0, type="n", xlab="", ylab="", xlim=c(min(dates), max(dates)+4), ylim=c(0.7,1.5), yaxt='n', ann=FALSE, bty="n", xaxt="n")
axis(1,at=c(seq(1570,1780,1)), cex.axis=0.9,tck=-0.02, labels=F )
axis(1,at=c(seq(1570,1780,10)), cex.axis=0.9,tck=-0.04, labels=T )
axis(2, labels = F, tick = F)
lines(dates_sh,data.crn$ihbstd, type = "l", col=color.fi, lwd=2) ##mittelkurve ihbd fichten ##dates_
lines(dates,data_fi$fi_tirol, type = "l", col="blue", lwd=2) ##mittelkurve all tirol


legend(x=c(1700,1725),y=c(1.4,1.3), legend=c("Referenzchronologie Fichte", "Mittelkurve ihbd-Fichten"),
       col=c("blue", color.fi), lty=1:1, lwd = 2, cex=0.8, bg="transparent",box.lty=0, horiz=F) #x.intersp = 0.5, y.intersp = 0.5,

mtext(text="Jahre", side=1, line=2)
mtext(text="Jahrringbreite [index.]", side = 2, line = 1)
mtext(text="-----------------------------------------------------", side = 2, line = 0 ,cex = 0.8)
title(main="b)", line = -1, adj=0.01)
#minor.tick(nx=10, ny=1, tick.ratio=0.5) #, x.args = list(), y.args = list()


dev.off()