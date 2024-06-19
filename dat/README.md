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
    │   ├── aoi_full.geojson           <- Full area for which the model has been developed.
    │   ├── aoi_large.geojson          <- Larger sub-AOI for demonstration purposes.
    │   └── aoi_small.geojson          <- Smaller sub-AOI for demonstration purposes.
    ├── lakes
    │   └── lakes_aoi_l.geojson        <- Lakes within the larger sub-AOI
    └── susceptibility_map
        ├── susceptibility_mean.tif    <- ensemble mean (susceptibility)
        └── susceptibility_sd.tif      <- ensemble sd (uncertainty)
```

Notes:
- `lakes_aoi_l.geojson` is a subset (clipped to the large sub-AOI) of the official lake data set provided by the Austrian Federal Ministry of Agriculture, Forestry, Regions and Water Management. The full data set is avialable as Open Government Data from https://www.data.gv.at/katalog/de/dataset/gesamtgewssernetzstehendegewsser ("Gesamtgewässernetz - Stehende Gewässer").
- `susceptibility_mean.tif` and `susceptibility_sd.tif` are GeoTIFFs of the susceptibility (ensemble mean) and uncertainty (ensemble standard deviation) for the full AOI in Carinthia. A subset clipped to the smaller sub-AOI is avialable in `processed/susceptibility.tif`, with mean as first layer and the standard deviation as second layer.
