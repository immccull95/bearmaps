################### Reproject Landsat greenness rasters #########################
# Author: Ian McCullough, immccull@gmail.com 
# Date: 6-14-17
# Updated:
################################################################################

#### R libraries ####
library(raster)

#### set ups ####
setwd('E:/Grizzly/Landsat')

############ Main program ################
raster_list = list.files(pattern='.tif$')
name_vector = paste0('r',seq(1,length(raster_list),1))

for(i in 1:length(raster_list)) { 
  ras = raster(raster_list[i])
  assign(name_vector[i], ras)
  ras=NULL
}

# get desired coordinate system from other file that has that crs
alpine = shapefile("E:/Grizzly/CalVeg/statewide/alpine/CA_alpine.shp")
desired_crs = crs(alpine)

# make list of all raster layers in current R environment
list_env = Filter(function(x) is(x, "RasterLayer"), mget(ls()))
list_env[which(names(list_env) %in% c("alpine"))] = NULL # remove raster names that might be in there by accident
names(list_env)

for(i in 1:length(list_env)) {
  x = projectRaster(from=list_env[[i]], crs=desired_crs, method='bilinear')
  assign(name_vector[i], x)
  x = NULL
}

###### SCRATCH AREA #####
# mosaic doesnt work for files with different origins
# merge raster has "tolerance" argument to adjust for different origins, but has no argument
# for overlapping rasters (just uses first layer)
# haven't found solution yet

# make list of all raster layers in current R environment
list_env = Filter(function(x) is(x, "RasterLayer"), mget(ls()))
list_env[which(names(list_env) %in% c("alpine"))] = NULL # remove raster names that might be in there by accident
names(list_env)

x <- list_env
names(x)[1:2] <- c('x', 'y')
x$fun <- max
x$na.rm <- TRUE
x$filename = 'E:/Grizzly/Landsat/greenness/mosaic_greenness.tif'

y <- do.call(mosaic, x)

mosaic_greenness = mosaic(list_env, fun=max, filename='E:/Grizzly/Landsat/greenness/mosaic_greenness.tif')

x = projectRaster(x, crs=desired_crs, method='bilinear')

r1[r1==0.044140]=NA
