rm(list = ls())
############## PLOT 3D Profile and Calculate Angle ###########################################

library(raster)
library(rgdal)
library(GISTools)
library(rgl)


setwd("D:/00_NatGef_Steinschlag_Modellierung/basics")    ###pfad zum ordner mit dem DGM setzen

############## IMPORT Raster ###########################################
##### DGM laden
f <- c("dem_1m.tif")    ##namen des DGM ersetzen
g <- readGDAL(f)
dgm <- raster(g)
proj4string(dgm)=CRS("+init=epsg:31254") #GK WEST

##### Raster plotten
slo <- terrain(dgm,opt='slope')
asp <- terrain(dgm,opt='aspect')
hsd <- hillShade(slo,asp,40,270)

plot(dgm, col=topo.colors(100)) 
plot(hsd,col=grey(0:100/100), alpha=0.35, legend=FALSE, add=TRUE) # transparenz 35%


########## PROFIL erzeugen  ####################################################
cat("PLEASE CLICK n TIMES for PROFILE LINE DEFINITION\n") 
click.cells.xy <- click(dgm,xy=T,cell=T,show=F); click.cells.xy
cat('mit esc beenden\n')

###########################
#WINKEL
###########################
#GEOM_GRADIENT



#build 3 points from graph data for 'rechtwinklig'
A = cbind(head(click.cells.xy$x, n=1),head(click.cells.xy$y, n=1), head(click.cells.xy$value, n=1)) #x1,y1,z1
B = cbind(tail(click.cells.xy$x, n=1),tail(click.cells.xy$y, n=1),tail(click.cells.xy$value, n=1)) #x2,y2,z,2
C = cbind(A[1], A[2], B[3]) #x1,y1,z2


b = A[3]-C[3] # nur Hoehen Diff


dist = function (x1, y1, x2, y2) {
  dx = (x2 - x1)
  dy = (y2 - y1)
  d1 = sqrt(dx**2 + dy**2)
  return(d1)
}

a = dist(C[1],C[2],B[1],B[2]) 

###winkel
c = sqrt(a**2+b**2) #pythagoras



winkel_beta = atan(b/a)*(180/pi) #rad to degree

winkel_alpha = 90-winkel_beta #weil rechtwinklig


winkel_gamma = 180 - winkel_alpha - winkel_beta #weil rechtwinklig


#plot3d
plot3d(click.cells.xy$x,click.cells.xy$y, click.cells.xy$value, top=T, axes=F, box=F)
title3d(main='Winkel')
points3d(A, pch=4, col='red',cex=2)
points3d(B, pch=4, col='red',cex=2)
points3d(C, pch=4, col='red',cex=2)
lines3d(rbind(A,B), lwd='1', col = 'red')
lines3d(rbind(B,C), lwd='1', col = 'red')
lines3d(rbind(A,C), lwd='1', col = 'red')
text3d(tail(click.cells.xy$x, n=1),tail(click.cells.xy$y, n=1),tail(click.cells.xy$value, n=1),paste('Winkel beta = ',winkel_beta), adj = c(0.5,0.5), col = 'blue')
text3d(head(click.cells.xy$x, n=1),head(click.cells.xy$y, n=1),head(click.cells.xy$value, n=1),'A', adj = c(1,1), col = 'darkgreen')
text3d(tail(click.cells.xy$x, n=1),tail(click.cells.xy$y, n=1),tail(click.cells.xy$value, n=1),'B', adj = c(1,1), col = 'darkgreen')
text3d(head(click.cells.xy$x, n=1),head(click.cells.xy$y, n=1),tail(click.cells.xy$value, n=1),'C', adj = c(1,1), col = 'darkgreen')


