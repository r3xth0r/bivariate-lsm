#!/usr/bin/zsh

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# download and clip lake data
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

dest="dat/raw/lakes/"
zip="stehendeGewaesser_v18.zip"

wget https://docs.umweltbundesamt.at/s/qDSPQJPbJt5iarC/download/$zip -P $dest
unzip $dest/$zip -d $dest
rm $dest/$zip

ogr2ogr -clipsrc dat/raw/aoi/aoi_carinthia.gpkg dat/interim/lakes_aoi_carinthia.geojson $dest/stehendeGewaesser.shp
ogr2ogr -clipsrc dat/raw/aoi/aoi_large.geojson dat/interim/lakes_aoi_large.geojson $dest/stehendeGewaesser.shp
