<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis styleCategories="Symbology" version="3.34.2-Prizren">
  <pipe-data-defined-properties>
    <Option type="Map">
      <Option type="QString" name="name" value=""/>
      <Option name="properties"/>
      <Option type="QString" name="type" value="collection"/>
    </Option>
  </pipe-data-defined-properties>
  <pipe>
    <provider>
      <resampling enabled="false" zoomedOutResamplingMethod="nearestNeighbour" zoomedInResamplingMethod="nearestNeighbour" maxOversampling="2"/>
    </provider>
    <rasterrenderer type="paletted" nodataColor="" opacity="1" alphaBand="-1" band="1">
      <rasterTransparency/>
      <minMaxOrigin>
        <limits>None</limits>
        <extent>WholeRaster</extent>
        <statAccuracy>Estimated</statAccuracy>
        <cumulativeCutLower>0.02</cumulativeCutLower>
        <cumulativeCutUpper>0.98</cumulativeCutUpper>
        <stdDevFactor>2</stdDevFactor>
      </minMaxOrigin>
      <colorPalette>
        <paletteEntry alpha="255" color="#cabed0" value="0" label="0"/>
        <paletteEntry alpha="255" color="#bc7c8f" value="1" label="1"/>
        <paletteEntry alpha="255" color="#ae3a4e" value="2" label="2"/>
        <paletteEntry alpha="255" color="#89a1c8" value="3" label="3"/>
        <paletteEntry alpha="255" color="#806a8a" value="4" label="4"/>
        <paletteEntry alpha="255" color="#77324c" value="5" label="5"/>
        <paletteEntry alpha="255" color="#4985c1" value="6" label="6"/>
        <paletteEntry alpha="255" color="#425786" value="7" label="7"/>
        <paletteEntry alpha="255" color="#3f2949" value="8" label="8"/>
      </colorPalette>
      <colorramp type="randomcolors" name="[source]">
        <Option/>
      </colorramp>
    </rasterrenderer>
    <brightnesscontrast brightness="0" contrast="0" gamma="1"/>
    <huesaturation saturation="0" colorizeGreen="128" colorizeRed="255" colorizeStrength="100" grayscaleMode="0" colorizeOn="0" invertColors="0" colorizeBlue="128"/>
    <rasterresampler maxOversampling="2"/>
    <resamplingStage>resamplingFilter</resamplingStage>
  </pipe>
  <blendMode>0</blendMode>
</qgis>
