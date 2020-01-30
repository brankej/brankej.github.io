# -*- coding: utf-8 -*-

'''
INFO
Script for Terrain-Data Preparation for Rockyfor3D with SAGA_CMD
Required Data in Subfolder pre_data in Working Directory = dem.asc; terrain.shp (with col names:  rockdensit;d1;d2;d3;blshape;rg70;rg20;rg10;soiltype); forest.shp (with col names:  nrtrees;dbhmean;dbhstd;conif_percent)

Script adapted and corrected from Guillaume Favre-Bulle, GeoVal (CH).
J.Branke 2018
'''

##MODULES
import os

##Variables
resamp_5m = 5.0
working_path = 'D:/Steinschlag_Modellierung/Rockyfor3D_KG6B/simulation+_anriss_sm'
#working_path = 'D:/Steinschlag_Modellierung/Rockyfor3D_KG6B/simulation+'

#do DATA 5m
#________________________
path = '5m/30'
os.chdir(path)

print path

cmd = 'python saga_rockyfor_terrain_parse.py -resamp_val %s' % (resamp_5m)
os.system(cmd)
cmd = 'python saga_rockyfor_forest_parse.py -resamp_val %s' % (resamp_5m)
os.system(cmd)

os.chdir(working_path)

#________________________
path = '5m/100'
os.chdir(path)

print path

cmd = 'python saga_rockyfor_terrain_parse.py -resamp_val %s' % (resamp_5m)
os.system(cmd)
cmd = 'python saga_rockyfor_forest_parse.py -resamp_val %s' % (resamp_5m)
os.system(cmd)

os.chdir(working_path)

#________________________
path = '5m/300'
os.chdir(path)

print path

cmd = 'python saga_rockyfor_terrain_parse.py -resamp_val %s' % (resamp_5m)
os.system(cmd)
cmd = 'python saga_rockyfor_forest_parse.py -resamp_val %s' % (resamp_5m)
os.system(cmd)

os.chdir(working_path)


print  '=================='
print  '5m done'
print  '=================='

print  '=================='
print 'Script finished succesfully'
print  '=================='