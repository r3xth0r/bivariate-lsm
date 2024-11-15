# Data

The structure of the `dat` directory is loosely based on the [Cookiecutter Data Science](https://github.com/drivendataorg/cookiecutter-data-science), with the general structure being:

```
.
├── interim        <- Intermediate data that has been transformed.
├── processed      <- The final, canonical output data sets.
└── raw            <- The original, immutable data dump.
```

The `raw` subdirectory containins (1) the susceptibility maps, (2) the full AOI for which the model has been developed as well as two sub AOIs for demonstration purposes, and (3) lakes within the larger sub-AOI.

```
.
└── raw
    ├── aoi
    │   ├── aoi_carinthia.gpkg         <- Full area for which the model has been developed.
    │   ├── aoi_large.geojson          <- Larger sub-AOI for demonstration purposes.
    │   └── aoi_small.geojson          <- Smaller sub-AOI for demonstration purposes.
    ├── dtm
    │   └── dtm_carinthia.tif          <- Digital terrain model of Carinthia.
    ├── lakes
    │   └── stehendeGewaesser.shp      <- Lakes within the full AOI of Carinthia
    └── susceptibility_map
        ├── susceptibility_mean.tif    <- ensemble mean (susceptibility)
        └── susceptibility_sd.tif      <- ensemble sd (uncertainty)
```

Notes:
- `./raw/lakes/stehendeGewaesser.shp` is the official lake data set provided by the Austrian Federal Ministry of Agriculture, Forestry, Regions and Water Management. The full data set is avialable as Open Government Data from https://www.data.gv.at/katalog/de/dataset/gesamtgewssernetzstehendegewsser ("Gesamtgewässernetz - Stehende Gewässer"). `src/prepare_lake_data.sh` can be used for downloading, unzipping an clipping the data set.
- `./raw/susceptibility_map/susceptibility_mean.tif` and `./raw/susceptibility_mapsusceptibility_sd.tif` are GeoTIFFs of the susceptibility (ensemble mean) and uncertainty (ensemble standard deviation) for the full AOI in Carinthia. A subset clipped to the smaller sub-AOI is avialable in `processed/susceptibility.tif`, with mean as first layer and the standard deviation as second layer.
- `./raw/dtm/dtm_carinthia.tif ` is the official digital terrain model of Carinthia. The data set is avialable as Open Government Data from https://www.data.gv.at/katalog/de/dataset/digitales-gelandemodell-5m-karnten ("Digitales Gelände- und Oberflächenmodell (5m) Kärnten").
