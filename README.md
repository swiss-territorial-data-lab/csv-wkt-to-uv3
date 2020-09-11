# Overview

This _octave_ script is used to help _shapefiles_ conversion into the UV3 format. The script applies on the _CSV/WKT_ export from _shapefiles_ to extract the geometry and to export them into a chosen _UV3_ file.

The script also comes with a standard color palette that can be used to assign colors to the desired extracted layers.

# csv-wkt-to-uv3

This script is used on _CSV/WKT_ exports from _sphapefiles_. Using an example _shapefile_ and the [_QGIS_](https://www.qgis.org/fr/site/) software, the following procedure can be considered :

* Open the shapefile and right-click on the desired layer

* Choose "Export" and then "Export entities as ..."

* Select _CSV_ format

* Specify the path of the _CSV_ file

* Keep EPSG:4326 - WGS84 coordinates system

* Choose AS _WKT_ as _GEOMETRY_ and _SEMICOLON_ as _SEPARATOR_

* Click the _OK_ button to export the geometries

As the _CSV/WKT_ file is correctly exported, run octave (GNU/Linux bash, no _GUI_) : 

    $ octave --no-gui

Then run the script providing the information on _CSV/WKT_ file path, the separator character (semicolon), the color index (from 1 to 20) and the path of the _UV3_ file to create :

    octave:*> csv_wkt_to_uv3('path/to/source.csv',';',4,'path/to/convert.uv3');

The following images gives the available colors in the built-in colormap :

<br />
<p align="center">
<img src="doc/colormap.png?raw=true" width="800">
<br />
<i>Built-in colormap with index from 1 to 20 - The colormap was stolen from python matplotlib (tab20b and tab20c)</i>
</p>
<br />

The script is also able to associate an height value to the _WKT_ geometries in two different ways : if the _WKT_ geometries come with an elevation (_Z_), it is used as _UV3_ third coordinate. If the _CSV_ comes with an _MSL_ column, the script interprets its values as height and use them as _UV3_ third coordinate, replacing the _WKT_ one if provided.

A color can be specified for each _WKT_ geometry through _R_, _G_ and _B_ column. Each column as to provided the corresponding color component in [0,255] range. If a color component is not provided, the specified colormap index is used to assign the color component.

A detailed documentation of specific file formats used by the tools of this suite can be found of the [format page](FORMAT.md).

# Copyright and License

**csv-wkt-to-uv3** - Nils Hamel, Huriel Reichel <br >
Copyright (c) 2020 STDL, Swiss Territorial Data Lab

This program is licensed under the terms of the GNU GPLv3. Documentation and illustrations are licensed under the terms of the CC BY-NC-SA.

# Dependencies

The _csv-wkt-to-uv3_ comes with the following package (Ubuntu 20.04 LTS) dependencies ([Instructions](DEPEND.md)) :

* octave
