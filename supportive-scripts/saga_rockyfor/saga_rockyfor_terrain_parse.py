# -*- coding: utf-8 -*-

'''
INFO
Script for Terrain-Data Preparation for Rockyfor3D with SAGA_CMD
Required Data in Working Directory = dem.asc; terrain.shp (with col names:  rockdensit;d1;d2;d3;blshape;rg70;rg20;rg10;soiltype)

Script adapted and corrected from Guillaume Favre-Bulle, GeoVal (CH).
'''

print 'INFO \n Script for Terrain-Data Preparation for Rockyfor3D with SAGA_CMD \n Required Data in Working Directory = dem.asc; terrain.shp (with col names:  rockdensit;d1;d2;d3;blshape;rg70;rg20;rg10;soiltype) \n Script adapted and corrected from Guillaume Favre-Bulle, GeoVal (CH).'

##MODULES
import os
import argparse

#PARSER====================================================================
parser = argparse.ArgumentParser(description='This Script autmomatically does the Rocky PreProcessing')
parser.add_argument('-resamp_val', type=float, help='Input of Resampling Value')

args = parser.parse_args()

resamp_val = args.resamp_val

##
#raw_input('Be sure to have dem.asc & terrain.shp in this directory! \n Press ENTER if ready.')
#cwd=os.getcwd()

#make folders
if not os.path.exists('TEMP'):
	os.mkdir('TEMP')
if not os.path.exists('OUTPUT'):
	os.mkdir('OUTPUT')
	
##VARIABLES
grid = 'dem.asc'
terrain = 'terrain.shp'

####SAGA CMD####

#dem resampling
cmd='saga_cmd io_grid 16 -FILES %s -GRIDS TEMP/dem.sgrd -CLIP %s -RESAMPLE 1 -CELLSIZE %f' % (grid, terrain, resamp_val)
os.system(cmd)
cmd='saga_cmd io_grid 0 -GRID TEMP/dem.sgrd -FILE OUTPUT/dem.asc -FORMAT 1 -GEOREF 0 -PREC 3 -DECSEP 0'
os.system(cmd)
grid = 'OUTPUT/dem.asc'
print  'resampling done'

	
#rockdensity
cmd='saga_cmd grid_gridding 0 -INPUT %s -FIELD rockdensit -MULTIPLE 1 -LINE_TYPE 1 -TARGET_DEFINITION 1 -TARGET_TEMPLATE %s -GRID TEMP/rockdensity.sgrd' % (terrain, grid)
os.system(cmd)
cmd='saga_cmd io_grid 0 -GRID TEMP/rockdensity.sgrd -FILE OUTPUT/rockdensity.asc -FORMAT 1 -GEOREF 0 -PREC 0 -DECSEP 0'
os.system(cmd)
print  'rockdensit done'

#d1
cmd='saga_cmd grid_gridding 0 -INPUT %s -FIELD d1 -MULTIPLE 1 -LINE_TYPE 1 -TARGET_DEFINITION 1 -TARGET_TEMPLATE %s -GRID TEMP/D1.sgrd' % (terrain, grid)
os.system(cmd)
cmd='saga_cmd io_grid 0 -GRID TEMP/D1.sgrd -FILE OUTPUT/d1.asc -FORMAT 1 -GEOREF 0 -PREC 3 -DECSEP 0'
os.system(cmd)
print  'd1 done'

#d2
cmd='saga_cmd grid_gridding 0 -INPUT %s -FIELD d2 -MULTIPLE 1 -LINE_TYPE 1 -TARGET_DEFINITION 1 -TARGET_TEMPLATE %s -GRID TEMP/D2.sgrd' % (terrain, grid)
os.system(cmd)
cmd='saga_cmd io_grid 0 -GRID TEMP/D2.sgrd -FILE OUTPUT/d2.asc -FORMAT 1 -GEOREF 0 -PREC 3 -DECSEP 0'
os.system(cmd)
print  'd2 done'

#d3
cmd='saga_cmd grid_gridding 0 -INPUT %s -FIELD d3 -MULTIPLE 1 -LINE_TYPE 1 -TARGET_DEFINITION 1 -TARGET_TEMPLATE %s -GRID TEMP/D3.sgrd' % (terrain, grid)
os.system(cmd)
cmd='saga_cmd io_grid 0 -GRID TEMP/D3.sgrd -FILE OUTPUT/d3.asc -FORMAT 1 -GEOREF 0 -PREC 3 -DECSEP 0'
os.system(cmd)
print  'd3 done'

#blshape
cmd='saga_cmd grid_gridding 0 -INPUT %s -FIELD blshape -MULTIPLE 1 -LINE_TYPE 1 -TARGET_DEFINITION 1 -TARGET_TEMPLATE %s -GRID TEMP/blshape.sgrd' % (terrain, grid)
os.system(cmd)
cmd='saga_cmd io_grid 0 -GRID TEMP/blshape.sgrd -FILE OUTPUT/blshape.asc -FORMAT 1 -GEOREF 0 -PREC 0 -DECSEP 0'
os.system(cmd)
print  'blshape done'

#rg70
cmd='saga_cmd grid_gridding 0 -INPUT %s -FIELD rg70 -MULTIPLE 1 -LINE_TYPE 1 -TARGET_DEFINITION 1 -TARGET_TEMPLATE %s -GRID TEMP/RG70.sgrd' % (terrain, grid)
os.system(cmd)
cmd='saga_cmd io_grid 0 -GRID TEMP/RG70.sgrd -FILE OUTPUT/rg70.asc -FORMAT 1 -GEOREF 0 -PREC 3 -DECSEP 0'
os.system(cmd)
print  'rg70 done'

#rg20
cmd='saga_cmd grid_gridding 0 -INPUT %s -FIELD rg20 -MULTIPLE 1 -LINE_TYPE 1 -TARGET_DEFINITION 1 -TARGET_TEMPLATE %s -GRID TEMP/RG20.sgrd' % (terrain, grid)
os.system(cmd)
cmd='saga_cmd io_grid 0 -GRID TEMP/RG20.sgrd -FILE OUTPUT/rg20.asc -FORMAT 1 -GEOREF 0 -PREC 3 -DECSEP 0'
os.system(cmd)
print  'rg20 done'

#rg10
cmd='saga_cmd grid_gridding 0 -INPUT %s -FIELD rg10 -MULTIPLE 1 -LINE_TYPE 1 -TARGET_DEFINITION 1 -TARGET_TEMPLATE %s -GRID TEMP/RG10.sgrd' % (terrain, grid)
os.system(cmd)
cmd='saga_cmd io_grid 0 -GRID TEMP/RG10.sgrd -FILE OUTPUT/rg10.asc -FORMAT 1 -GEOREF 0 -PREC 3 -DECSEP 0'
os.system(cmd)
print  'rg10 done'

#soiltype
cmd='saga_cmd grid_gridding 0 -INPUT %s -FIELD soiltype -MULTIPLE 1 -LINE_TYPE 1 -TARGET_DEFINITION 1 -TARGET_TEMPLATE %s -GRID TEMP/Soiltype.sgrd' % (terrain, grid)
os.system(cmd)
cmd='saga_cmd io_grid 0 -GRID TEMP/Soiltype.sgrd -FILE OUTPUT/soiltype.asc -FORMAT 1 -GEOREF 0 -PREC 0 -DECSEP 0'
os.system(cmd)
print  'soiltype done'



#raw_input(' ==> TEMP Directory can now be deleted! ASC Generation Finished ! \n Press ENTER to finish.')
print ' ==> TEMP Directory can now be deleted! ASC Generation Finished !'