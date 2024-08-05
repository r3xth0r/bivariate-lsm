#!/usr/bin/zsh

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# clip the original full files to a smaller AOI for plotting demonstration
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

aoi_size="small" # "small" or "large"
var="mean"       # "mean" or "sd"

echo "$(date +"%Y-%m-%d %H:%M:%S") » Clipping susceptibility map"
gdalwarp -s_srs EPSG:3416 -t_srs EPSG:3416 -of GTiff \
    -cutline dat/raw/aoi/aoi_${aoi_size}.geojson -crop_to_cutline \
    -dstnodata -1.0 \
    dat/raw/susceptibility_map/susceptibility_${var}.tif \
    dat/interim/susceptibility_${var}.tif

echo "$(date +"%Y-%m-%d %H:%M:%S") » Clipping DTM"
gdalwarp -s_srs EPSG:3416 -t_srs EPSG:3416 -of GTiff \
    -cutline dat/raw/aoi/aoi_${aoi_size}.geojson -crop_to_cutline \
    -dstnodata -1.0 \
    dat/raw/dtm/dtm_carinthia.tif \
    dat/interim/dtm.tif
    
echo "$(date +"%Y-%m-%d %H:%M:%S") » DONE"
