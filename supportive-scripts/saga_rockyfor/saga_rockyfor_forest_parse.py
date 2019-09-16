# -*- coding: utf-8 -*-

'''
INFO
Script for Forest-Data Preparation for Rockyfor3D with SAGA_CMD
Required Data in Working Directory = dem.asc; terrain.shp; forest.shp (with col names:  nrtrees;dbhmean;dbhstd;conif_percent)

Script adapted and corrected from Guillaume Favre-Bulle, GeoVal (CH).
'''

print  ' INFO \n Script for Forest-Data Preparation for Rockyfor3D with SAGA_CMD \n Required Data in Working Directory = dem.asc; terrain.shp; forest.shp (with col names:  nrtrees;dbhmean;dbhstd;conif_percent) \n Script adapted and corrected from Guillaume Favre-Bulle, GeoVal (CH).'

##MODULES
import os
import argparse

#PARSER====================================================================
parser = argparse.ArgumentParser(description='This Script autmomatically does the Rocky PreProcessing')
parser.add_argument('-resamp_val', type=float, help='Input of Resampling Value')

args = parser.parse_args()

resamp_val = args.resamp_val


##
#raw_input('Be sure to have dem.asc, terrain.shp & forest.shp in this directory! \n Press ENTER if ready.')
#cwd=os.getcwd()

#make folders
if not os.path.exists('TEMP'):
	os.mkdir('TEMP')
if not os.path.exists('OUTPUT'):
	os.mkdir('OUTPUT')

##VARIABLES
grid = 'dem.asc'
forest = 'forest.shp'
terrain = 'terrain.shp'

####SAGA CMD####

#dem resampling
cmd='saga_cmd io_grid 16 -FILES %s -GRIDS TEMP/dem.sgrd -CLIP %s -RESAMPLE 1 -CELLSIZE %f' % (grid, terrain, resamp_val)
os.system(cmd)
cmd='saga_cmd io_grid 0 -GRID TEMP/dem.sgrd -FILE OUTPUT/dem.asc -FORMAT 1 -GEOREF 0 -PREC 3 -DECSEP 0'
os.system(cmd)
grid = 'OUTPUT/dem.asc'
print  'resampling done'

	
#nrtrees
cmd='saga_cmd grid_gridding 0 -INPUT %s -FIELD nrtrees -MULTIPLE 1 -LINE_TYPE 1 -TARGET_DEFINITION 1 -TARGET_TEMPLATE %s -GRID TEMP/nrtrees.sgrd' % (forest, grid)
os.system(cmd)
cmd='saga_cmd io_grid 0 -GRID TEMP/nrtrees.sgrd -FILE OUTPUT/nrtrees.asc -FORMAT 1 -GEOREF 0 -PREC 0 -DECSEP 0'
os.system(cmd)
print  'nrtrees done'

#dbhmean
cmd='saga_cmd grid_gridding 0 -INPUT %s -FIELD dbhmean -MULTIPLE 1 -LINE_TYPE 1 -TARGET_DEFINITION 1 -TARGET_TEMPLATE %s -GRID TEMP/dbhmean.sgrd' % (forest, grid)
os.system(cmd)
cmd='saga_cmd io_grid 0 -GRID TEMP/dbhmean.sgrd -FILE OUTPUT/dbhmean.asc -FORMAT 1 -GEOREF 0 -PREC 3 -DECSEP 0'
os.system(cmd)
print  'dbhmean done'

#dbhstd
cmd='saga_cmd grid_gridding 0 -INPUT %s -FIELD dbhstd -MULTIPLE 1 -LINE_TYPE 1 -TARGET_DEFINITION 1 -TARGET_TEMPLATE %s -GRID TEMP/dbhstd.sgrd' % (forest, grid)
os.system(cmd)
cmd='saga_cmd io_grid 0 -GRID TEMP/dbhstd.sgrd -FILE OUTPUT/dbhstd.asc -FORMAT 1 -GEOREF 0 -PREC 3 -DECSEP 0'
os.system(cmd)
print  'dbhstd done' 

#conif_percent
cmd='saga_cmd grid_gridding 0 -INPUT %s -FIELD conif_perc -MULTIPLE 1 -LINE_TYPE 1 -TARGET_DEFINITION 1 -TARGET_TEMPLATE %s -GRID TEMP/conif_percent.sgrd' % (forest, grid)
os.system(cmd)
cmd='saga_cmd io_grid 0 -GRID TEMP/conif_percent.sgrd -FILE OUTPUT/conif_percent.asc -FORMAT 1 -GEOREF 0 -PREC 3 -DECSEP 0'
os.system(cmd)
print  'conif_perc done'

#raw_input(' ==> TEMP Directory can now be deleted! ASC Generation Finished ! \n Press ENTER to finish.')
print ' ==> TEMP Directory can now be deleted! ASC Generation Finished !'