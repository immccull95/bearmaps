################### North Cascades Grizzly Model applied to NorCal #########################
# Author: Ian McCullough, immccull@gmail.com 
# Date: 6-13-17
# Updated:
############################################################################################

#### R libraries ####
# if get big brother Bren error about not being able to install packages, use
# install.packages('package name', dependencies=T, repos='http://cran.rstudio.com/')
library(raster)

#### input data ####
# NOTE: assumes same projection and spatial resolution for all rasters

# study area outline (vector)
study_area = shapefile("H:/Ian_GIS/Cal_boundary/shapefiles/cnty24k09_1_state_poly.shp")

# mosaic of greenness (raster)
greenness = raster("")

# canopy openness raster
canopy_openness = raster("")

# alpine vegetation (raster) 1=alpine, all else=NoData
alpine = raster("")

# elevation (raster)
elevation = raster("")

# riparian vegetation raster
riparian = raster("")

#### d-fine functions ####
# coefficients from Proctor, M. F., Nielsen, S. E., Kasworm, W. F., Servheen, C., Radandt, T. G., Machutchon, A. G., & Boyce, M. S. (2015). Grizzly bear connectivity mapping in the Canada-United States trans-border region. The Journal of Wildlife Management, 79(4), 544-558.
NCE_grizzly = function(greenness,canopy_openness,alpine,elevation,riparian,constant){
  #greenness: tasseled cap transformation greenness from Landsat 8 imagery
  #canopy_openness: % canopy from NLCD 2001: http://frap.fire.ca.gov/assessment/2010/data
  #alpine: from CalVeg, Mixed alpine scrub alliance (AX), alpine grasses and forbs alliance (AC). Raster with 1=alpine,all else=NoData
  #elevation: 30 m digital elevation model
  #riparian: 1 is riparian habtiat from percent canopy, otherwise NoData
  #constant: model intercept
  habitat = ((greenness*14.597) + (canopy_openness*0.014) + (alpine*0.801) + (elevation*0.108) +
    (riparian*1.091) - 11.524)
  return(habitat)
}

################### Main program ######################
# clip raster layers to study area
greenness = mask(greenness, mask=study_area, inverse=F) #inverse=F retains areas with data within mask
canopy_openness = mask(canopy_openness, mask=study_area, inverse=F)
alpine = mask(alpine, mask=study_area, inverse=F)
elevation = mask(elevation, mask=study_area, inverse=F)
riparian = mask(riparian, mask=study_area, inverse=F)

# run function to create grizzly habitat map
CA_grizzly = NCE_grizzly(greenness=greenness, canopy_openness=canopy_openness,
                         alpine=alpine, elevation=elevation, riparian=riparian)

plot(CA_grizzly, main='CA Grizzly')
writeRaster(CA_grizzly, filename="H:/Ian_GIS/Grizzly/NCE_CA_grizzly_habitat.tif", overwrite=T)
