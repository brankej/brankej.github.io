/*
    Übersichtskarte
    -------------------------------------------------------------------

*/

//  Leaflet Map with fullscreen
let myMap = L.map("map", {
  fullscreenControl: true,
  zoom: 9,
  center: new L.LatLng(47.267, 11.383), // like -> myMap.setView([47.267,11.383], 10);
});

let polygon = L.featureGroup(); //for polygons

let myLayers = {
  osm : L.tileLayer(                // http://leafletjs.com/reference-1.3.0.html#tilelayer-l-tilelayer
    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      subdomains : ["a", "b", "c"],
      attribution : "Datenquelle: <a href = 'https://www.openstreetmap.org/' > © OpenStreetMap</a> Mitwirkende"
    }
  ),
  geolandbasemap : L.tileLayer(
    "https://{s}.wien.gv.at/basemap/geolandbasemap/normal/google3857/{z}/{y}/{x}.png", {
      subdomains : ["maps", "maps1", "maps2", "maps3", "maps4"],                                        // http://leafletjs.com/reference-1.3.0.html#tilelayer-subdomains
      attribution : "Datenquelle: <a href ='https://basemap.at'> basemap.at </a>"                       // http://leafletjs.com/reference-1.3.0.html#layer-attribution
    }
  ),
  bmapgrau : L.tileLayer(
    "https://{s}.wien.gv.at/basemap/bmapgrau/normal/google3857/{z}/{y}/{x}.png", {
      subdomains : ["maps", "maps1", "maps2", "maps3", "maps4"],
      attribution : "Datenquelle: <a href ='https://basemap.at'> basemap.at </a>"
    }
  ),
  bmaphidip : L.tileLayer(
    "https://{s}.wien.gv.at/basemap/bmaphidpi/normal/google3857/{z}/{y}/{x}.jpeg", {
      subdomains : ["maps", "maps1", "maps2", "maps3", "maps4"],
      attribution : "Datenquelle: <a href ='https://basemap.at'> basemap.at </a>"
    }
  ),
  bmaporthofoto30cm : L.tileLayer(
    "https://{s}.wien.gv.at/basemap/bmaporthofoto30cm/normal/google3857/{z}/{y}/{x}.jpeg", {
      subdomains : ["maps", "maps1", "maps2", "maps3", "maps4"],
      attribution : "Datenquelle: <a href ='https://basemap.at'> basemap.at </a>"
    }
  ),
  stamen_toner: L.tileLayer("https://stamen-tiles-{s}.a.ssl.fastly.net/toner/{z}/{x}/{y}.png", {
        subdomains: ["a", "b", "c"],
        attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, under <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a>. Data by <a href="http://openstreetmap.org">OpenStreetMap</a>, under <a href="http://www.openstreetmap.org/copyright">ODbL</a>.'
    }),
    stamen_terrain: L.tileLayer("https://stamen-tiles-{s}.a.ssl.fastly.net/terrain/{z}/{x}/{y}.jpg", {
        subdomains: ["a", "b", "c"],
        attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, under <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a>. Data by <a href="http://openstreetmap.org">OpenStreetMap</a>, under <a href="http://www.openstreetmap.org/copyright">ODbL</a>.',
    }),
    stamen_watercolor: L.tileLayer("https://stamen-tiles-{s}.a.ssl.fastly.net/watercolor/{z}/{x}/{y}.jpg", {
        subdomains: ["a", "b", "c"],
        attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, under <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a>. Data by <a href="http://openstreetmap.org">OpenStreetMap</a>, under <a href="http://creativecommons.org/licenses/by-sa/3.0">CC BY SA</a>.'
    }),
};


myMap.addLayer(myLayers.osm);                    // http://leafletjs.com/reference-1.3.0.html#map-addlayer

let myMapControl  = L.control.layers({                // http://leafletjs.com/reference-1.3.0.html#control-layers-l-control-layers
  //Auswahl der Hintergrundkarte
  "OpenStreetMap" : myLayers.osm,
  "Geoland Basemap" : myLayers.geolandbasemap,
  "Geoland Map Grey" : myLayers.bmapgrau,
  "Geoland Map Highdpi" : myLayers.bmaphidip,
  "Geoland Orthophoto 30cm" : myLayers.bmaporthofoto30cm,
  "Stamen Toner" : myLayers.stamen_toner,
  "Stamen Terrain" : myLayers.stamen_terrain,
  "Stamen Watercolor" : myLayers.stamen_watercolor,
}, {
  //overlay
  "IBK": polygon,
}, { //map control ausgeklappt lassen
  collapsed:false} );                               // http://leafletjs.com/reference-1.3.0.html#control-layers-collapsed


myMap.addControl(myMapControl);                     // http://leafletjs.com/reference-1.3.0.html#map-addcontrol


// Maßstab metrisch ohne inch
//Maßstabsleiste
let myScale = L.control.scale({
  position: "bottomleft",
  maxWidth: 200,
  imperial: false,
  metric: true
});

myScale.addTo(myMap);


//----------------------------------------------------
// https://datavizforall.github.io/leaflet-map-polygon-hover/  data source

// Edit ranges and colors to match your data; see http://colorbrewer.org
// Any values not listed in the ranges below displays as the last color
function getColor(d) { // http://colorbrewer2.org/#type=sequential&scheme=YlGnBu&n=5
  return d > 15 ? '#253494' :
    d > 10 ? '#2c7fb8' :
    d > 5 ? '#41b6c4' :
    d > 1 ? '#a1dab4' :
    '#ffffcc';
}


// Edit the getColor property to match data column header in your GeoJson file
function style(feature) {
  return {
    fillColor: getColor(feature.properties.NR),
    weight: 1,
    opacity: 1,
    color: 'black',
    fillOpacity: 0.7
  };
}

topology_polys = topojson.presimplify(data) //pen_dat
topology_polys = topojson.simplify(topology_polys)
let geojson2 = L.topoJson(topology_polys ,   { style: style}).addTo(polygon)




let featureGroup = L.layerGroup([polygon], {
  attribution: "Daten: Stadt Innsbruck  - https://www.innsbruck.gv.at (<a href ='https://creativecommons.org/licenses/by/4.0/'> CC BY 4.0 </a>)",
});


myMap.addLayer(featureGroup);


// Creates an info box on the map
let info = L.control();
info.onAdd = function(myMap) {
  this._div = L.DomUtil.create('div', 'info');
  this.update();
  return this._div;
};


// Edit grades in legend to match the ranges cutoffs inserted above
// In this example, the last grade will appear as 5000+
let legend = L.control({
  position: 'bottomright'
});
legend.onAdd = function(myMap) {
  // Create Div Element and Populate it with HTML
  let div = L.DomUtil.create('div', 'info legend'), //legend header test
    grades = [0, 1, 5, 10, 15],
    labels = [],
    from, to;
  for (let i = 0; i < grades.length; i++) {
    from = grades[i];
    to = grades[i + 1];
    labels.push(
      '<i style="background:' + getColor(from + 1) + '"></i> ' +
      from + (to ? '&ndash;' + to : '+'));
  }
  // Return the Legend div containing the HTML content
  div.innerHTML += '<h4>Placeholder €/m²</h4>' + '</b>'; //
  div.innerHTML += labels.join('<br>');
  return div;
};
legend.addTo(myMap);

//=======================================================================

const hash = new L.Hash(myMap);


//=======================================================================

//fit map on polygon boundaries
myMap.fitBounds(polygon.getBounds());


//=======================================================================
