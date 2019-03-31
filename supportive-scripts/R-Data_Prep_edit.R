rm(list=ls())
graphics.off()

####LIBRARYS
library(raster)
library(rgdal)


#set path to scenario run
cwd='E:/OneDrive - uibk.ac.at/AlpHydro/VU Amundsen/amundsen/amundsen/Results/Gepatschalm_Assign_III/' ##--> set your path
setwd(cwd)

##set path to basin raster!
basin = "E:/OneDrive - uibk.ac.at/AlpHydro/VU Amundsen/amundsen/amundsen/Images/Gepatschalm/WS_Gepatschalm_100.asc"  ###--> fill path
basin.rast = raster(basin)

#folderseq
#seq_time = seq(2000, 2050, 1)
dirs = list.dirs(cwd)


###############
## ICE-WE
###############
pat = 'IceWE.*\\.txt$'
name.matches = list.files(dirs[-c(1,2)],pattern = pat, recursive = T, full.names =  T)
print(name.matches)


icewe_stack = stack(name.matches)

### stats
r_name = list.files(dirs[-c(1,2)],pattern = pat, recursive = T, full.names =  F)
rList = list() # to save raster values
statList = list() # to save data.frame with statistics

for(i in 1:length(name.matches)){
  temp = raster(name.matches[i])
  temp = mask(temp, basin.rast==0) ##remove out of AOI values, thx martin for tipp
  rList[[i]] = values(temp) # extract values for each raster

  # name
  Name = r_name[i]

  mx=raster::cellStats(temp, 'max', na.rm=T)
  mn=raster::cellStats(temp, 'min', na.rm=T)
  avg=raster::cellStats(temp,'mean',na.rm=T)
  stdev=raster::cellStats(temp,'sd',na.rm=T)
  summ = raster::cellStats(temp, 'sum', na.rm=T)


  rc = reclassify(temp, c(-Inf,1,0, 1,Inf,1))
  sum_rc = raster::cellStats(rc, 'sum', na.rm=T)

  statList[[i]] = data.frame(Name,mx,mn,avg,stdev,summ, sum_rc) # create a data.frame to save statistics
}

df_icewe = do.call(rbind.data.frame,statList) # final data.frame with all statistics

#######
# VOL %

#ice_we
icewe_2000 = df_icewe$summ[1]

#new col for %
df_icewe$vol_perc2k = (df_icewe$summ / icewe_2000) *100



########
### REAL PLOTS
########

dates = seq(2000, 2050, 1)

par(mfrow = c(1,1))
plot(dates, df_icewe$vol_perc2k, type='b',lty =2,pch = 18,col = 'blue', ylim =c(0,100), xlab = 'Jahre', ylab = 'Gletscher Volumen [% Vol 2000]')
title(main = 'Einzugsgebiet Gepatschalm Gletscher Volumen Rückgang (1999 - 2050)')
title(sub = 'Temperatur Anstieg von + 0.48 °C/Jahrzehnt (AAR 2014)')
grid()

plot(dates, df_icewe$sum_rc, col = 'red', lty = 1, xlab = 'Jahre', ylab = 'Gletscher Flächen Rückgang [ha]')
title(main = 'Einzugsgebiet Gepatschalm Gletscher Flächen Rückgang (1999 - 2050)')
title(sub = 'Temperatur Anstieg von + 0.48 °C/Jahrzehnt (AAR 2014)')
grid()
