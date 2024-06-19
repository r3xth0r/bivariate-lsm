#!/usr/bin/zsh

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# create elevation mask from DTM
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

aoi_size="small" # "small" or "large"

gdal_calc.py -A raw/dtm/dtm_carinthia.tif --calc="A>=1900" --type Byte --outfile dat/interim/high_elev_mask.tif

gdal_edit.py -a_nodata 0 dat/interim/high_elev_mask.tif

gdalwarp -s_srs EPSG:3416 -t_srs EPSG:3416 -of GTiff \
    -cutline dat/raw/aoi/aoi_${aoi_size}.geojson -crop_to_cutline \
    dat/interim/high_elev_mask.tif \
    dat/interim/high_elev_mask_${aoi_size}.tif

gdal_polygonize.py dat/interim/high_elev_mask_${aoi_size}.tif dat/interim/high_elev_mask.geojson

rm dat/interim/high_elev_mask.tif dat/interim/high_elev_mask_${aoi_size}.tif
