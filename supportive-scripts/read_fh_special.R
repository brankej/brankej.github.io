##########
## Dendro
##########

rm(list=ls())
graphics.off()


read.fh.special <- function(fname) {
  inp <- readLines(fname, ok=TRUE, warn=FALSE)
  
  ## Get start and end positions of headers and data blocks
  header.begin <- grep("^HEADER:$", inp)
  header.end <- grep("^DATA:(Tree|Single)$", inp)
  n <- length(header.end)
  if(n == 0) {
    stop('file has no data in "Tree" or "Single" formats')
  }
  ## For each data block in one of the supported formats, find the
  ## corresponding header block
  header.taken <- logical(length(header.begin))
  for (i in seq_len(n)) {
    n.preceding <- sum(header.begin < header.end[i] - 1)
    if (n.preceding == 0 || header.taken[n.preceding]) {
      stop("invalid file: HEADER and DATA don't match")
    } else {
      header.taken[n.preceding] <- TRUE
    }
  }
  if (!all(header.taken)) {
    warning("more HEADER blocks than DATA blocks in supported formats")
  }
  ## For each data block in one of the supported formats, find the
  ## following header block (or end of file)
  data.end <- numeric(n)
  for (i in seq_len(n-1)) {
    tmp <- header.begin[header.begin > header.end[i]]
    data.end[i] <- tmp[1]
  }
  tmp <- header.begin[header.begin > header.end[n]]
  if (length(tmp) > 0) {
    data.end[n] <- tmp[1]
  } else {
    data.end[n] <- length(inp) + 1
  }
  ## Forget headers that are not used by the data blocks
  header.begin <- header.begin[header.taken]
  
  ## Get essential metadata from headers
  species = character(n)
  pith = character(n)
  waldkante = character(n)
  Comment = character(n)
  
  keycodes <- character(n)
  start.years <- numeric(n)
  end.years <- numeric(n)
  
  for (i in seq_len(n)) {
    this.header <- inp[(header.begin[i]+1):(header.end[i]-1)]
    ##############
    #extended
    ## get species
    this.species <- sub("Species=", "", fixed=TRUE,
                        x=grep("^Species=", this.header, value=TRUE))
    if (length(this.species) != 1) {
      string2 <- gettext('number of "Species" lines is not 1',
                         domain="R-dplR")
      stop(gettextf("in series %s: ", as.character(i), domain="R-dplR"),
           string2, domain=NA)
    } else {
      species[i] <- this.species
    }
    
    ## get pith
    this.pith <- sub("Pith=", "", fixed=TRUE,
                        x=grep("^Pith=", this.header, value=TRUE))
    if (length(this.pith) != 1) {
      string2 <- gettext('number of "Pith" lines is not 1',
                         domain="R-dplR")
      pith[i] = NA
      #stop(gettextf("in series %s: ", as.character(i), domain="R-dplR"),
       #    string2, domain=NA)
    } else {
      pith[i] <- this.pith
    }
    
    ## get waldkante
    this.waldkante <- sub("WaldKante=", "", fixed=TRUE,
                        x=grep("^WaldKante=", this.header, value=TRUE))
    if (length(this.waldkante) != 1) {
      string2 <- gettext('number of "waldkante" lines is not 1',
                         domain="R-dplR")
      stop(gettextf("in series %s: ", as.character(i), domain="R-dplR"),
           string2, domain=NA)
    } else {
      waldkante[i] <- this.waldkante
    }
    
    ## get comment
    this.Comment <- sub("Comment=", "", fixed=TRUE,
                          x=grep("^Comment=", this.header, value=TRUE))
    if (length(this.Comment) != 1) {
      string2 <- gettext('number of "Comment" lines is not 1',
                         domain="R-dplR")
      Comment[i] = NA
      #stop(gettextf("in series %s: ", as.character(i), domain="R-dplR"),
           #string2, domain=NA)
    } else {
      Comment[i] <- this.Comment
    }
    
    
    ##############
    #standard
    ## get keycode (= series id)
    this.keycode <- sub("KeyCode=", "", fixed=TRUE,
                        x=grep("^KeyCode=", this.header, value=TRUE))
    if (length(this.keycode) != 1) {
      string2 <- gettext('number of "KeyCode" lines is not 1',
                         domain="R-dplR")
      stop(gettextf("in series %s: ", as.character(i), domain="R-dplR"),
           string2, domain=NA)
    } else {
      keycodes[i] <- this.keycode
    }
    ## get start year
    this.start.year <- sub("DateBegin=", "", fixed=TRUE,
                           x=grep("^DateBegin=", this.header, value=TRUE))
    if (length(this.start.year) != 1) {
      string2 <- gettext('number of "DateBegin" lines is not 1',
                         domain="R-dplR")
      stop(gettextf("in series %s: ", keycodes[i], domain="R-dplR"),
           string2, domain=NA)
    } else {
      start.years[i] <- as.numeric(this.start.year)
    }
    ## get end year
    this.end.year <- sub("DateEnd=", "", fixed=TRUE,
                         x=grep("^DateEnd=", this.header, value=TRUE))
    if (length(this.end.year) != 1) {
      string2 <- gettext('number of "DateEnd" lines is not 1',
                         domain="R-dplR")
      stop(gettextf("in series %s: ", keycodes[i], domain="R-dplR"),
           string2, domain=NA)
    } else {
      end.years[i] <- as.numeric(this.end.year)
    }
  }

  
  ####
  #extend data
  ## get info data to data.frame
  #span <- c(1:6)
  #info.df <- data.frame(NA, nrow = length(keycodes), ncol = length(span))
  #rownames(info.df) <- keycodes
  #colnames(info.df) <- c("species", "pith","waldkante", "Comment", "start.years", "end.years")
  
  info.df = data.frame(species, pith, waldkante, Comment, start.years, end.years)
  rownames(info.df) = keycodes
  info.df
}


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
data_s$color = "#FFFFFF"
for (i in seq(nrow(data_s))) {
  if (data_s$species[i] == "LADE"){
    data_s$color[i] = "#31a354"
  } 
  if (data_s$species[i] == "PCAB") {
    data_s$color[i] ="#f03b20"
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
#plot version i
######
# par(mar=c(5.1,4.1,4.1,2.1),oma=c(1,0,1,2)) #par(oma=c(2,2,2,2), mar=c(5.1,4.1,4.1,2.1)) 
# plot(0, type="n", xlab="", ylab="", xlim=c(min(data_s$start.years), max(data_s$end.years)+5), ylim=c(1, nrow(data_s_sort)), yaxt='n', ann=FALSE)
# axis(1, at=c(seq(1575,1775,25)))
# axis(2, labels = F, tick = F)
# axis(3, at=c(seq(1575,1775,25)))
# axis(4, at=seq.col, labels=NAMES, srt=45, tick=FALSE, las=2, line=-0.8)
# 
# for (i in seq(1,nrow(data_s_sort))){ #seq(1,nrow(data_s))
#   segments(x0 = data_s_sort$start.years[i], x1 = data_s_sort$end.years[i], y0 = i, y1 = i, lwd = 5, col =data_s_sort$color[i])
#   points(x=data_s_sort$end.years[i], y=i,  pch = 17, col =data_s_sort$colorwk[i]) #wk
#   points(x=data_s_sort$start.years[i], y=i,  pch = 18, col =data_s_sort$colorp[i]) #p
#   text(x=data_s_sort$end.years[i]+7, y=i, labels = data_s_sort$end.years[i])
#   }
# legend(x=c(1575,1600),y=c(26,24), legend=c("PCAB", "LADE"),
#        col=c("#f03b20", "#31a354"), lty=1:1, lwd = 3, cex=0.8, bg="transparent",box.lty=0, x.intersp = 0.5, y.intersp = 0.5)
# legend(x=c(1575,1600),y=c(24,21), legend=c("WKE", "WKL", "P"), col=c("#fc4e2a","#3182bd","#c51b8a" ), pch = c(17,17,18), cex=0.8, bg="transparent",box.lty=0 , x.intersp = 0.5, y.intersp = 0.5)
# 
# mtext(text="Jahre", side=1, line=2)




######
#plot version ii labels front
######
par(mar=c(5.1,4.1,4.1,2.1),oma=c(1,0,1,2)) 
plot(0, type="n", xlab="", ylab="", xlim=c(min(data_s$start.years-22), max(data_s$end.years)+8), ylim=c(1, nrow(data_s_sort)), yaxt='n', ann=FALSE, bty="n", xaxt="n")
axis(1, at=c(seq(1550,1780,10)), cex.axis=0.7)
axis(2, labels = F, tick = F)
#axis(3, at=c(seq(1550,1775,25)))

for (i in seq(1,nrow(data_s_sort))){ 
  segments(x0 = data_s_sort$start.years[i], x1 = data_s_sort$end.years[i], y0 = i, y1 = i, lwd = 8, col =data_s_sort$color[i])
  points(x=data_s_sort$end.years[i], y=i,  pch = 17,cex=1.5, col =data_s_sort$colorwk[i]) #wk
  points(x=data_s_sort$start.years[i], y=i,  pch = 16,cex=1.5, col =data_s_sort$colorp[i]) #p
  text(x=data_s_sort$end.years[i]+7, y=i, labels = data_s_sort$end.years[i], cex = 0.9)
  text(x=data_s_sort$start.years[i]-11, y=i, labels=NAMES[i], cex= 0.9)
}
legend(x=c(1550,1575),y=c(25,24), legend=c("Fichte", "Lärche"),
       col=c("#f03b20", "#31a354"), lty=1:1, lwd = 8, cex=0.8, bg="transparent",box.lty=0, x.intersp = 0.5, y.intersp = 0.5)
legend(x=c(1550,1575),y=c(23.5,22.5), legend=c("WK Sommer", "WK Winter", "Kern"), col=c("#b10026","#3182bd","#c51b8a" ), pch = c(17,17,16),pt.cex = c(1.5,1.5,1.5), cex=0.8, bg="transparent",box.lty=0 , x.intersp = 0.5, y.intersp = 0.5)

mtext(text="Jahre", side=1, line=2)
minor.tick(nx=10, ny=1, tick.ratio=0.5) #, x.args = list(), y.args = list()


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

color.fi <- "#f03b20"
color.fi.tr <- adjustcolor(color.fi, alpha.f = 0.5)

color.lade <- "#31a354"
color.lade.tr <- adjustcolor(color.lade, alpha.f = 0.5)

######
# #plot all // dif lade / fi
# ######
# 
# #####test
# par(mfrow=c(2,1))
# 
# par(mar=c(5.1,4.1,4.1,2.1),oma=c(1,0,1,2)) #par(oma=c(2,2,2,2), mar=c(5.1,4.1,4.1,2.1)) 
# plot(0, type="n", xlab="", ylab="", xlim=c(min(dates)-20, max(dates)), ylim=c(0,2), yaxt='n', ann=FALSE)
# axis(1, at=c(seq(1575,1775,25)))
# axis(2, labels = F, tick = F)
# 
# for (i in seq(1,ncol(data.rwi.fi))){ #seq(1,nrow(data))
#   lines(dates_,data.rwi.fi[,i], col =color.fi.tr, lwd=1.3)
# }
# for (i in seq(1,ncol(data.rwi.lade))){ #seq(1,nrow(data))
#   lines(dates_,data.rwi.lade[,i], col=color.lade.tr, lwd=1.3)
# }
# 
# 
# legend(x=c(1575,1600),y=c(2,1.9), legend=c("PCAB", "LADE"),
#        col=c("#f03b20", "#31a354"), lty=1:1, lwd = 1, cex=0.8, bg="transparent",box.lty=0, x.intersp = 0.5, y.intersp = 0.5)
# 
# mtext(text="Jahre", side=1, line=2)
# mtext(text="Jahrringbreite [index.]", side = 2, line = 1)
# 
# ######
# #plot fi // ref fi
# ######
# 
# data.crn <- chron(data.rwi.fi, prefix = "ihb")
# 
# par(mar=c(5.1,4.1,4.1,2.1),oma=c(1,0,1,2)) 
# plot(0, type="n", xlab="", ylab="", xlim=c(min(dates)-20, max(dates)), ylim=c(0.7,1.5), yaxt='n', ann=FALSE)
# axis(1, at=c(seq(1575,1775,25)))
# axis(2, labels = F, tick = F)
# lines(dates,data_fi$fi_tirol, type = "l", col="blue", lwd=2)
# lines(dates_,data.crn$ihbstd, type = "l", col=color.fi, lwd=2)
# 
# legend(x=c(1675,1725),y=c(0.8,0.7), legend=c("Referenzchronologie Fichte", "Mittelkurve ihbd-Fichten"),
#        col=c("blue", color.fi), lty=1:1, lwd = 2, cex=0.8, bg="transparent",box.lty=0, x.intersp = 0.5, y.intersp = 0.5)
# 
# mtext(text="Jahre", side=1, line=2)
# mtext(text="Jahrringbreite [index.]", side = 2, line = 1)



#################newplot


######
#plot all // dif lade / fi
######

#####test
#c(bottom,left,top,right) mai = ; oma = outer margin; mar = margin; 
par(mfrow=c(2,1), mai = c(1, 0.1, 0.1, 0.1),oma=c(2,0,1,2),mar=c(1,4.1,1,2.1))

plot(0, type="n", xlab="", ylab="", xlim=c(min(dates)-15, max(dates)+2), ylim=c(0,2), yaxt='n', ann=FALSE, xaxt="n", bty="n")
axis(2, labels = F, tick = F)

for (i in seq(1,ncol(data.rwi.fi))){ #seq(1,nrow(data))
  lines(dates_,data.rwi.fi[,i], col =color.fi.tr, lwd=1.3)
}
for (i in seq(1,ncol(data.rwi.lade))){ #seq(1,nrow(data))
  lines(dates_,data.rwi.lade[,i], col=color.lade.tr, lwd=1.3)
}


legend(x=c(1550,1575),y=c(1.9,1.8), legend=c("Fichte", "Lärche"),
       col=c("#f03b20", "#31a354"), lty=1:1, lwd = 1, cex=0.8, bg="transparent",box.lty=0, x.intersp = 0.5, y.intersp = 0.5, horiz=F)

mtext(text="Jahrringbreite [index.]", side = 2, line = 1)
mtext(text="---------------------------------------------------------------------", side = 2, line = 0)

######
#plot fi // ref fi
######

data.crn <- chron(data.rwi.fi, prefix = "ihb")

plot(0, type="n", xlab="", ylab="", xlim=c(min(dates)-15, max(dates)+4), ylim=c(0.7,1.5), yaxt='n', ann=FALSE, bty="n", xaxt="n")
axis(1,at=c(seq(1550,1780,10)), cex.axis=0.7)
axis(2, labels = F, tick = F)
lines(dates_,data.crn$ihbstd, type = "l", col=color.fi, lwd=2)
lines(dates,data_fi$fi_tirol, type = "l", col="blue", lwd=2)


legend(x=c(1700,1725),y=c(1.4,1.3), legend=c("Referenzchronologie Fichte", "Mittelkurve ihbd-Fichten"),
       col=c("blue", color.fi), lty=1:1, lwd = 2, cex=0.8, bg="transparent",box.lty=0, x.intersp = 0.5, y.intersp = 0.5, horiz=F)

mtext(text="Jahre", side=1, line=2)
mtext(text="Jahrringbreite [index.]", side = 2, line = 1)
mtext(text="---------------------------------------------------------------------", side = 2, line = 0)
minor.tick(nx=10, ny=1, tick.ratio=0.5) #, x.args = list(), y.args = list()

