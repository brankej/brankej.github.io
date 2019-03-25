rm(list=ls())
graphics.off()


#############################
### Rocky 4 3D
#############################


library(raster)
library(rgdal)
library(GISTools)

##setwd
cwd =  "D:/00_NatGef_Steinschlag_Modellierung/Rockyfor3D_KG6B/"
setwd(cwd)

terrain = "simulation+_anriss_sm/5m/30/terrain.shp"

jhrl_30_energy = "simulation+_anriss_sm/5m/30/OUTPUT/500sims-Forest-x_m3/E_95.asc"
jhrl_30_el_angle = "simulation+_anriss_sm/5m/30/OUTPUT/500sims-Forest-x_m3/EL_angles.asc"
jhrl_30_reach_prob = "simulation+_anriss_sm/5m/30/OUTPUT/500sims-Forest-x_m3/Reach_probability.asc"

jhrl_100_energy = "simulation+_anriss_sm/5m/100/OUTPUT/500sims-Forest-x_m3/E_95.asc"
jhrl_100_el_angle = "simulation+_anriss_sm/5m/100/OUTPUT/500sims-Forest-x_m3/EL_angles.asc"
jhrl_100_reach_prob = "simulation+_anriss_sm/5m/100/OUTPUT/500sims-Forest-x_m3/Reach_probability.asc"

jhrl_300_energy = "simulation+_anriss_sm/5m/300/OUTPUT/500sims-Forest-x_m3/E_95.asc"
jhrl_300_el_angle = "simulation+_anriss_sm/5m/300/OUTPUT/500sims-Forest-x_m3/EL_angles.asc"
jhrl_300_reach_prob = "simulation+_anriss_sm/5m/300/OUTPUT/500sims-Forest-x_m3/Reach_probability.asc"

#read poly
terrain_poly = readOGR(terrain)

#### 30
#read in raster
rast_energy_30 = raster(jhrl_30_energy)
rast_el_angle_30 = raster(jhrl_30_el_angle)
rast_reach_prob_30 = raster(jhrl_30_reach_prob)
plot(rast_el_angle_30)

#### 100
#read in raster
rast_energy_100 = raster(jhrl_100_energy)
rast_el_angle_100 = raster(jhrl_100_el_angle)
rast_reach_prob_100 = raster(jhrl_100_reach_prob)


#### 300
#read in raster
rast_energy_300 = raster(jhrl_300_energy)
rast_el_angle_300 = raster(jhrl_300_el_angle)
rast_reach_prob_300 = raster(jhrl_300_reach_prob)



##Reclassify
rcl_el_angle = c(-30000, 27.0,0,27.0,+Inf,1) # ausreißer
rcl_reach_prob = c(-30000, 1,1,1,+Inf,0)   #ausreißer <1 // norm >2


rcl_el_angle_30 = reclassify(rast_el_angle_30, rcl_el_angle)
rcl_el_angle_100 = reclassify(rast_el_angle_100, rcl_el_angle)
rcl_el_angle_300 = reclassify(rast_el_angle_300, rcl_el_angle)


plot(rcl_el_angle_30)
plot(terrain_poly, add=T)

rcl_reach_prob_30 = reclassify(rast_reach_prob_30, rcl_reach_prob)
rcl_reach_prob_100 = reclassify(rast_reach_prob_100, rcl_reach_prob)
rcl_reach_prob_300 = reclassify(rast_reach_prob_300, rcl_reach_prob)


plot(rcl_reach_prob_30)
plot(terrain_poly, add=T)



### one mask
one_mask_30 = rcl_el_angle_30 + rcl_reach_prob_30
one_mask_100 = rcl_el_angle_100 + rcl_reach_prob_100
one_mask_300 = rcl_el_angle_300 + rcl_reach_prob_300
plot(one_mask_30)

## one mask reclass
one_mask_rcl_30 = one_mask_30 == 0
one_mask_rcl_100 = one_mask_100 == 0
one_mask_rcl_300 =one_mask_300 == 0
plot(one_mask_rcl_30)
plot(one_mask_rcl_100)
plot(one_mask_rcl_300)

## final masking
rast_energy_30_1 = mask(rast_energy_30, one_mask_rcl_30, maskvalue=0)
rast_energy_100_1 = mask(rast_energy_100, one_mask_rcl_100, maskvalue=0)
rast_energy_300_1 = mask(rast_energy_300, one_mask_rcl_300, maskvalue=0)


plot(rast_energy_30, main="30 jhrl")
plot(terrain_poly, add=T)
plot(rast_energy_30_1, main="30 jhrl edit")
plot(terrain_poly, add=T)


plot(rast_energy_100, main="100 jhrl")
plot(terrain_poly, add=T)
plot(rast_energy_100_1, main="100 jhrl edit")
plot(terrain_poly, add=T)



plot(rast_energy_300, main="300 jhrl")
plot(terrain_poly, add=T)
plot(rast_energy_300_1, main="300 jhrl edit")
plot(terrain_poly, add=T)


  
## write out raster

writeRaster(rast_energy_30_1, filename = paste(cwd,"/edit_luuk/rocky30_energy.tif",sep = ""), drivers ="GTiff",  overwrite=TRUE )

writeRaster(rast_energy_100_1, filename = paste(cwd,"/edit_luuk/rocky100_energy.tif",sep = ""), drivers ="GTiff",  overwrite=TRUE )

writeRaster(rast_energy_300_1, filename = paste(cwd,"/edit_luuk/rocky300_energy.tif",sep = ""), drivers ="GTiff",  overwrite=TRUE )