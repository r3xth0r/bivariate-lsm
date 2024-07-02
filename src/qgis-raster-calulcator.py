processing.run(
    "qgis:rastercalculator",
    {
        "EXPRESSION": 'if(("susceptibility@1" < 0.4481) AND ("susceptibility@2" < 0.0297), 0,\nif(("susceptibility@1" < 0.6096) AND ("susceptibility@2" < 0.0297), 1,\nif(("susceptibility@1" < 999) AND ("susceptibility@2" < 0.0297), 2,\nif(("susceptibility@1" < 0.4481) AND ("susceptibility@2" < 0.0416), 3,\nif(("susceptibility@1" < 0.6096) AND ("susceptibility@2" < 0.0416), 4,\nif(("susceptibility@1" < 999) AND ("susceptibility@2" < 0.0416), 5,\nif(("susceptibility@1" < 0.4481) AND ("susceptibility@2" < 999), 6,\nif(("susceptibility@1" < 0.6096) AND ("susceptibility@2" < 999), 7,\n8))))))))',
        "LAYERS": ["C:/path/susceptibility.tif"],
        "CELLSIZE": 0,
        "EXTENT": None,
        "CRS": None,
        "OUTPUT": "TEMPORARY_OUTPUT",
    },
)
