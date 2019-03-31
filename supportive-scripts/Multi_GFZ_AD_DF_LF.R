rm(list=ls())
graphics.off()


#############################
### GFZ
#############################

library(raster)
library(rgdal)
library(GISTools)



##-->select MODE by abbreviation

##avalanche                                   = AD
##debrisflow                                  = DF
##rockfall                                    = LF
##rockfall extended (Abbruzzese et al., 2009) = LF_ext


###############
MODE = "LF_ext" #-->fill
###############

##setwd
cwd =  "D:/00_NatGef_Steinschlag_Modellierung" ##--> set drive
setwd(cwd)


## make folder
if (dir.exists(paste(cwd, "/OUTPUT", sep = "")) == FALSE){
  dir.create(paste(cwd, "/OUTPUT", sep = ""))
}


##############
###Input data

## only fill path if mode AD
input_ad_30 = "OUTPUT/lawine_test_jakob/Rel4_30_MaxPressure.asc"  #-->pressure 30 jhrl
input_ad_100= "OUTPUT/lawine_test_jakob/Rel4_100_MaxPressure.asc" #-->pressure 100 jhrl
input_ad_300= "OUTPUT/lawine_test_jakob/RelAll_300muXi_MaxPressure.asc" #-->pressure 300 jhrl

## only fill path if mode LF & LF_ext
input_lf_30= 'RAMMS_KG6B/kgb6b_2m_large/kgb6b_2m_large/output/kgb6b_2m_large_30j/kgb6b_2m_large_30j_Kinetic Rock Energy.asc' #-->kin-energy 30 jhrl
input_lf_100=  'RAMMS_KG6B/kgb6b_2m_large/kgb6b_2m_large/output/kgb6b_2m_large_100j/kgb6b_2m_large_100j_Kinetic Rock Energy.asc'  #-->kin-energy 100 jhrl
input_lf_300= 'RAMMS_KG6B/kgb6b_2m_large/kgb6b_2m_large/output/kgb6b_2m_large_300j/kgb6b_2m_large_300j_Kinetic Rock Energy.asc' #-->kin-energy 300 jhrl

## fill path if mode LF_ext
input_lf_30_reach = "OUTPUT/KGB6B/kgb6b_2m_large_30j_Source Reach Probability.asc" #-->Reach Probability 30 jhrl
input_lf_100_reach = "OUTPUT/KGB6B/kgb6b_2m_large_100j_Source Reach Probability.asc" #-->Reach Probability 100 jhrl
input_lf_300_reach = "OUTPUT/KGB6B/kgb6b_2m_large_300j_Source Reach Probability.asc" #-->Reach Probability 300 jhrl

## only fill path if mode DF
input_df_30m= "OUTPUT/Test_script_gzp/07_03_finalspeeed_MaxHeight.asc" #-->maxheight 30 jhrl
input_df_100m= "OUTPUT/Test_script_gzp/07_100_final_speed_MaxHeight.asc" #-->maxheight 100 jhrl
input_df_300m= "OUTPUT/Test_script_gzp/07_300_final_MaxHeight.asc"  #-->maxheight 300 jhrl

input_df_30v= "OUTPUT/Test_script_gzp/07_03_finalspeeed_MaxVelocity.asc" #-->maxvelocity 30 jhrl
input_df_100v= "OUTPUT/Test_script_gzp/07_100_final_speed_MaxVelocity.asc" #-->maxvelocity 100 jhrl
input_df_300v= "OUTPUT/Test_script_gzp/07_300_final_MaxVelocity.asc"  #-->maxvelocity 300 jhrl


if (MODE == "AD"){
  #read in raster
  rast_ad_30 = raster(input_ad_30)
  rast_ad_100 = raster(input_ad_100)
  rast_ad_300 = raster(input_ad_300)

  ##Reclassify
  rcl_ad = c(0,3,1,3,30,2,30,Inf,3)
  rcl_ad_30 = reclassify(rast_ad_30, rcl_ad)
  rcl_ad_100 = reclassify(rast_ad_100, rcl_ad)
  rcl_ad_300 = reclassify(rast_ad_300, rcl_ad)

  plot(rcl_ad_30)
  plot(rcl_ad_100)
  plot(rcl_ad_300)

  data_ad_30 = values(rcl_ad_30)
  data_ad_100 =values(rcl_ad_100)
  data_ad_300 = values(rcl_ad_300)

  ##empty data
  data_ad_gfz=raster(nrow=rcl_ad_30@nrows, ncol=rcl_ad_30@ncols)
  data_ad_gfz[] = 0
  data_ad_gfz = values(data_ad_gfz)

  #xy[reihe,spalte]

  for (i in 1:length(values(rcl_ad_30))) {
    if  (data_ad_300[i]== 1) {
      data_ad_gfz[i] = 1
    }	#1
    if  (data_ad_100[i]== 1) {
      data_ad_gfz[i] = 2
    }	#2
    if  (data_ad_30[i]== 1) {
      data_ad_gfz[i] = 3
    }	#3

    if  (data_ad_300[i]== 2) {
      data_ad_gfz[i] = 4
    }	#4
    if  (data_ad_100[i]== 2) {
      data_ad_gfz[i] = 5
    }	#5
    if  (data_ad_30[i]== 2) {
      data_ad_gfz[i] = 6
    }	#6

    if  (data_ad_300[i]== 3) {
      data_ad_gfz[i] = 7
    }	#7
    if  (data_ad_100[i]== 3) {
      data_ad_gfz[i] = 8
    }	#8
    if  (data_ad_30[i]== 3) {
      data_ad_gfz[i] = 9
    }	#9

  }


  ## fill new raster

  ad_gfz = raster(nrow=rcl_ad_30@nrows, ncol=rcl_ad_30@ncols)
  ad_gfz = setExtent(ad_gfz,extent(rast_ad_30))
  ad_gfz[] = data_ad_gfz
  #ad_gfz[ad_gfz == 0] <- NA
  proj4string(ad_gfz)=CRS("+init=epsg:31254")

  plot(ad_gfz)


  ### Save Raster
  writeRaster(ad_gfz, filename = paste(cwd,"/OUTPUT/AD_GFZ.tif",sep = ""), drivers ="GTiff",  overwrite=TRUE )


  ##### Polygonize
  ad_gfz_poly = rasterToPolygons(ad_gfz,fun=function(x){x>0},n=4,dissolve=T)
  plot(ad_gfz_poly, col=rainbow(10))

  writeOGR(ad_gfz_poly, dsn="OUTPUT",  layer = "Poly_AD_GFZ", driver="ESRI Shapefile", overwrite_layer = T)

}

if (MODE == "DF"){
  #read in raster
  rast_df_30m = raster(input_df_30m)
  rast_df_100m = raster(input_df_100m)
  rast_df_300m = raster(input_df_300m)

  rast_df_30v = raster(input_df_30v)
  rast_df_100v = raster(input_df_100v)
  rast_df_300v = raster(input_df_300v)



  data_df_30m = values(rast_df_30m)
  data_df_100m =values(rast_df_100m)
  data_df_300m = values(rast_df_300m)

  data_df_30v = values(rast_df_30v)
  data_df_100v =values(rast_df_100v)
  data_df_300v = values(rast_df_300v)


  ##empty data
  data_df_gfz=raster(nrow=rast_df_30m@nrows, ncol=rast_df_30m@ncols)
  data_df_gfz[] = 0
  data_df_gfz = values(data_df_gfz)

  #xy[reihe,spalte]


  for (i in 1:length(values(rast_df_30m))) {
    if (data_df_300v[i] <= 1.0 && data_df_300v[i] > 0 || data_df_300m[i] <= 1.0 && data_df_300m[i] > 0){
      data_df_gfz[i] = 4
    }	#4

    if (data_df_100v[i]<= 1.0 && data_df_100v[i] > 0 || data_df_100m[i] <= 1.0 && data_df_100m[i] > 0){
      data_df_gfz[i] = 5
    }	#5

    if (data_df_30v[i]<= 1.0 && data_df_30v[i] > 0 || data_df_30m[i] <= 1.0 && data_df_30m[i] > 0){
      data_df_gfz[i] = 6
    }	#6

    if (data_df_300v[i]> 1.0 && data_df_300m[i] > 1.0){
      data_df_gfz[i] = 7
    }	#7

    if (data_df_100v[i]> 1.0 && data_df_100m[i] > 1.0){
      data_df_gfz[i] = 8
    }	#8

    if (data_df_30v[i]> 1.0 && data_df_30m[i] > 1.0){
      data_df_gfz[i] = 9
    }	#9

  }


  ## fill new raster

  df_gfz = raster(nrow=rast_df_30m@nrows, ncol=rast_df_30m@ncols)
  df_gfz = setExtent(df_gfz,extent(rast_df_30m))
  df_gfz[] = data_df_gfz
  #df_gfz[df_gfz == 0] <- NA
  proj4string(df_gfz)=CRS("+init=epsg:31254")

  plot(df_gfz)


  ### Save Raster
  writeRaster(df_gfz, filename = paste(cwd,"/OUTPUT/DF_GFZ.tif",sep = ""), drivers ="GTiff",  overwrite=TRUE )



  ##### Polygonize
  df_gfz_poly = rasterToPolygons(df_gfz,fun=function(x){x>0},n=4,dissolve=T)
  plot(df_gfz_poly, col=rainbow(10))

  writeOGR(df_gfz_poly, dsn="OUTPUT",  layer = "Poly_DF_GFZ", driver="ESRI Shapefile", overwrite_layer = T)

}

if (MODE == "LF") {
  #read in raster
  rast_lf_30 = raster(input_lf_30)
  rast_lf_100 = raster(input_lf_100)
  rast_lf_300 = raster(input_lf_300)

  ##Reclassify
  rcl_lf = c(0,30.0,1,30.0,300.0,2,300,Inf,3)
  rcl_lf_30 = reclassify(rast_lf_30, rcl_lf)
  rcl_lf_100 = reclassify(rast_lf_100, rcl_lf)
  rcl_lf_300 = reclassify(rast_lf_300, rcl_lf)

  plot(rcl_lf_30)
  plot(rcl_lf_100)
  plot(rcl_lf_300)


  data_lf_30 = values(rcl_lf_30)
  data_lf_100 =values(rcl_lf_100)
  data_lf_300 = values(rcl_lf_300)


  ##empty data
  data_lf_gfz=raster(nrow=rcl_lf_30@nrows, ncol=rcl_lf_30@ncols)
  data_lf_gfz[] = 0
  data_lf_gfz = values(data_lf_gfz)

  #xy[reihe,spalte]


  for (i in 1:length(values(rcl_lf_30))) {
    if  (data_lf_300[i]== 1) {
      data_lf_gfz[i] = 1
    }	#1
    if  (data_lf_100[i]== 1) {
      data_lf_gfz[i] = 2
    }	#2
    if  (data_lf_30[i]== 1) {
      data_lf_gfz[i] = 3
    }	#3

    if  (data_lf_300[i]== 2) {
      data_lf_gfz[i] = 4
    }	#4
    if  (data_lf_100[i]== 2) {
      data_lf_gfz[i] = 5
    }	#5
    if  (data_lf_30[i]== 2) {
      data_lf_gfz[i] = 6
    }	#6

    if  (data_lf_300[i]== 3) {
      data_lf_gfz[i] = 7
    }	#7
    if  (data_lf_100[i]== 3) {
      data_lf_gfz[i] = 8
    }	#8
    if  (data_lf_30[i]== 3) {
      data_lf_gfz[i] = 9
    }	#9

  }


  ## fill new raster

  lf_gfz = raster(nrow=rcl_lf_30@nrows, ncol=rcl_lf_30@ncols)
  lf_gfz = setExtent(lf_gfz,extent(rast_lf_30))
  lf_gfz[] = data_lf_gfz
  #lf_gfz[lf_gfz == 0] <- NA
  proj4string(lf_gfz)=CRS("+init=epsg:31254")

  plot(lf_gfz)


  ### Save Raster
  writeRaster(lf_gfz, filename = paste(cwd,"/OUTPUT/LF_GFZ.tif",sep = ""), drivers ="GTiff",  overwrite=TRUE )



  ##### Polygonize
  lf_gfz_poly = rasterToPolygons(lf_gfz,fun=function(x){x>0},n=4,dissolve=T)
  plot(lf_gfz_poly, col=rainbow(10))

  writeOGR(lf_gfz_poly, dsn="OUTPUT",  layer = "Poly_LF_GFZ", driver="ESRI Shapefile", overwrite_layer = T)




  }

if (MODE == "LF_ext") {
  #read in raster
  rast_lf_30 = raster(input_lf_30)
  rast_lf_100 = raster(input_lf_100)
  rast_lf_300 = raster(input_lf_300)

  rast_lf_30_reach = raster(input_lf_30_reach)
  rast_lf_100_reach = raster(input_lf_100_reach)
  rast_lf_300_reach = raster(input_lf_300_reach)

  ##Reclassify
  rcl_lf = c(0,30.0,1,30.0,300.0,2,300,Inf,3)
  rcl_lf_30 = reclassify(rast_lf_30, rcl_lf)
  rcl_lf_100 = reclassify(rast_lf_100, rcl_lf)
  rcl_lf_300 = reclassify(rast_lf_300, rcl_lf)

  plot(rcl_lf_30)
  plot(rcl_lf_100)
  plot(rcl_lf_300)


  data_lf_30 = values(rcl_lf_30)
  data_lf_100 =values(rcl_lf_100)
  data_lf_300 = values(rcl_lf_300)

  data_lf_30_reach = values(rast_lf_30_reach)
  data_lf_100_reach = values(rast_lf_100_reach)
  data_lf_300_reach = values(rast_lf_300_reach)


  ##empty data
  data_lf_gfz=raster(nrow=rcl_lf_30@nrows, ncol=rcl_lf_30@ncols)
  data_lf_gfz[] = 0
  data_lf_gfz = values(data_lf_gfz)

  #xy[reihe,spalte]


  for (i in 1:length(values(rcl_lf_30))) {
    if  (data_lf_300[i]== 1 && data_lf_300_reach[i]>0.0001 && data_lf_300_reach[i]<0.01) {
      data_lf_gfz[i] = 1
    }	#1
    if  (data_lf_100[i]== 1 && data_lf_100_reach[i]>0.0001 && data_lf_100_reach[i]<0.01) {
      data_lf_gfz[i] = 2
    }	#2
    if  (data_lf_30[i]== 1 && data_lf_30_reach[i]>0.0001 && data_lf_30_reach[i]<0.01) {
      data_lf_gfz[i] = 3
    }	#3

    if  (data_lf_300[i]== 2 && data_lf_300_reach[i]>0.01 && data_lf_300_reach[i]<1) {
      data_lf_gfz[i] = 4
    }	#4
    if  (data_lf_100[i]== 2 && data_lf_100_reach[i]>0.01 && data_lf_100_reach[i]<1) {
      data_lf_gfz[i] = 5
    }	#5
    if  (data_lf_30[i]== 2 && data_lf_30_reach[i]>0.01 && data_lf_30_reach[i]<1) {
      data_lf_gfz[i] = 6
    }	#6

    if  (data_lf_300[i]== 3 && data_lf_300_reach[i]>1) {
      data_lf_gfz[i] = 7
    }	#7
    if  (data_lf_100[i]== 3 && data_lf_100_reach[i]>1) {
      data_lf_gfz[i] = 8
    }	#8
    if  (data_lf_30[i]== 3 && data_lf_30_reach[i]>1) {
      data_lf_gfz[i] = 9
    }	#9

  }


  ## fill new raster

  lf_gfz = raster(nrow=rcl_lf_30@nrows, ncol=rcl_lf_30@ncols)
  lf_gfz = setExtent(lf_gfz,extent(rast_lf_30))
  lf_gfz[] = data_lf_gfz
  #lf_gfz[lf_gfz == 0] <- NA
  proj4string(lf_gfz)=CRS("+init=epsg:31254")

  plot(lf_gfz)


  ### Save Raster
  writeRaster(lf_gfz, filename = paste(cwd,"/OUTPUT/LF_ext_GFZ.tif",sep = ""), drivers ="GTiff",  overwrite=TRUE )



  ##### Polygonize
  lf_gfz_poly = rasterToPolygons(lf_gfz,fun=function(x){x>0},n=4,dissolve=T)
  plot(lf_gfz_poly, col=rainbow(10))

  writeOGR(lf_gfz_poly, dsn="OUTPUT",  layer = "Poly_LF_ext_GFZ", driver="ESRI Shapefile", overwrite_layer = T)


}
