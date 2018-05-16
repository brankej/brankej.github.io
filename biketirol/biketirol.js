/*
    Vorbereitung: GPX Track herunterladen und nach GeoJSON konvertieren
    -------------------------------------------------------------------
    Datenquelle https://www.data.gv.at/suche/?search-term=bike+trail+tirol&searchIn=catalog
    Download Einzeletappen / Zur Ressource ...
    Alle Dateien im unterverzeichnis data/ ablegen
    Die .gpx Datei der eigenen Etappe als etappe00.gpx speichern
    Die .gpx Datei über https://mapbox.github.io/togeojson/ in .geojson umwandeln und als etappe00.geojson speichern
    Die etappe00.geojson Datei in ein Javascript Objekt umwandeln und als etappe00.geojson.js speichern

    -> statt 00 natürlich die eigene Etappe (z.B. 01,02, ...25)
*/

// eine neue Leaflet Karte definieren
let myMap = L.map("map", {
    fullscreenControl: true,});

const etappe06Group = L.featureGroup();
// Grundkartenlayer mit OSM, basemap.at, Elektronische Karte Tirol
// (Sommer, Winter, Orthophoto jeweils mit Beschriftung) über L.featureGroup([]) definieren
// WMTS URLs siehe https://www.data.gv.at/katalog/dataset/land-tirol_elektronischekartetirol

let myLayers = {
  osm : L.tileLayer(                // http://leafletjs.com/reference-1.3.0.html#tilelayer-l-tilelayer
    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      subdomains : ["a", "b", "c"],
      attribution : "Datenquelle: <a href = 'https://www.openstreetmap.org/' > © OpenStreetMap</a> Mitwirkende"
    }
  ),
  geolandbasemap : L.tileLayer(
    "https://{s}.wien.gv.at/basemap/geolandbasemap/normal/google3857/{z}/{y}/{x}.png", {
      subdomains : ["maps", "maps1", "maps2", "maps3", "maps4"],                                // http://leafletjs.com/reference-1.3.0.html#tilelayer-subdomains
      attribution : "Datenquelle: <a href ='https://basemap.at'> basemap.at </a>"               // http://leafletjs.com/reference-1.3.0.html#layer-attribution
    }
  ),
  gdi_ortho : L.tileLayer(
    "http://wmts.kartetirol.at/wmts/gdi_ortho/GoogleMapsCompatible/{z}/{x}/{y}.jpeg80", {
      attribution : "Datenquelle: <a href ='https://www.tirol.gv.at/data/nutzungsbedingungen/'> Land Tirol - data.tirol.gv.at </a>"
    }
  ),
  gdi_nomenklatur: L.tileLayer(
    "http://wmts.kartetirol.at/wmts/gdi_nomenklatur/GoogleMapsCompatible/{z}/{x}/{y}.png8", {
      attribution : "Datenquelle: <a href ='https://www.tirol.gv.at/data/nutzungsbedingungen/'> Land Tirol - data.tirol.gv.at </a>",
      pane: "overlayPane"                          //https://leafletjs.com/reference-1.3.0.html#tilelayer-pane

    }
  ),
  gdi_summer: L.tileLayer(
    "http://wmts.kartetirol.at/wmts/gdi_summer/GoogleMapsCompatible/{z}/{x}/{y}.jpeg80", {
      attribution : "Datenquelle: <a href ='https://www.tirol.gv.at/data/nutzungsbedingungen/'> Land Tirol - data.tirol.gv.at </a>"
    }
  ),
  gdi_winter: L.tileLayer(
    "http://wmts.kartetirol.at/wmts/gdi_winter/GoogleMapsCompatible/{z}/{x}/{y}.jpeg80", {
      attribution : "Datenquelle: <a href ='https://www.tirol.gv.at/data/nutzungsbedingungen/'> Land Tirol - data.tirol.gv.at </a>"
    }
  ),
};



const gdi_summerGrp = L.layerGroup([myLayers.gdi_summer, myLayers.gdi_nomenklatur])

const gdi_winterGrp = L.layerGroup([myLayers.gdi_winter, myLayers.gdi_nomenklatur])

const gdi_orthoGrp = L.layerGroup([myLayers.gdi_ortho, myLayers.gdi_nomenklatur])

myMap.addLayer(gdi_summerGrp);          // http://leafletjs.com/reference-1.3.0.html#map-addlayer
// Maßstab metrisch ohne inch
//Maßstabsleiste
let myScale = L.control.scale({   //http://leafletjs.com/reference-1.3.0.html#control-scale-l-control-scale
  position : "bottomleft",        // http://leafletjs.com/reference-1.3.0.html#control-position
  maxWidth : 200,                 // http://leafletjs.com/reference-1.3.0.html#control-scale-maxwidth
  imperial : false,               // http://leafletjs.com/reference-1.3.0.html#control-scale-imperial
  metric : true                   // http://leafletjs.com/reference-1.3.0.html#control-scale-metric
});

myScale.addTo(myMap);             // http://leafletjs.com/reference-1.3.0.html#control-addto
// Start- und Endpunkte der Route als Marker mit Popup, Namen, Wikipedia Link und passenden Icons für Start/Ziel von https://mapicons.mapsmarker.com/

// GeoJSON Track als Linie in der Karte einzeichnen und auf Ausschnitt zoomen
// Einbauen nicht über async, sondern über ein L.geoJSON() mit einem Javascript Objekt (wie beim ersten Stadtspaziergang Wien Beispiel)



// Start- und Endpunkte der Route als Marker mit Popup, Namen, Wikipedia Link und passenden Icons für Start/Ziel von https://mapicons.mapsmarker.com/

const ehrwald_marker = [ 47.399722,10.916667]
let ehrwald_popup = '<h1>Ehrwald </h1><a href="https://de.wikipedia.org/wiki/Ehrwald">Wikipedia</a>'
L.marker(ehrwald_marker, {icon: L.icon({
  iconUrl: '../icons/regroup.png',
  iconAnchor : [16,37],
  popupAnchor : [0,-37],
})
}).addTo(etappe06Group).bindPopup(ehrwald_popup);

const scharnitz_marker = [47.388333,11.265]
let scharnitz_popup = '<h1>Scharnitz </h1><a href="https://de.wikipedia.org/wiki/Scharnitz">Wikipedia</a>'
L.marker(scharnitz_marker, {icon: L.icon({
  iconUrl: '../icons/flag-export.png',
  iconAnchor : [16,37],
  popupAnchor : [0,-37],
})
}).addTo(etappe06Group).bindPopup(scharnitz_popup);

// Baselayer control für OSM, basemap.at, Elektronische Karte Tirol hinzufügen
let myMapControl  = L.control.layers({                // http://leafletjs.com/reference-1.3.0.html#control-layers-l-control-layers
  //Auswahl der Hintergrundkarte
  "OpenStreetMap" : myLayers.osm,
  "Geoland Basemap" : myLayers.geolandbasemap,
}, {
  //overlay // Overlay controls zum unabhängigem Ein-/Ausschalten der Route und Marker hinzufügen
  "Etappe 06" : etappe06Group,
  "Land Tirol Sommer" : gdi_summerGrp,
  "Land Tirol Winter" : gdi_winterGrp,
  "Land Tirol Orthophoto" : gdi_orthoGrp,
}, { //map control ausgeklappt lassen
  collapsed:false} );             // http://leafletjs.com/reference-1.3.0.html#control-layers-collapsed

  let gpxTrack = new L.GPX('data/etappe06.gpx', {
    async: true
  }).addTo(etappe06Group);
  gpxTrack.on("loaded", function(evt) {
    myMap.fitBounds(evt.target.getBounds())
    console.log("name",evt.target.get_name());
    console.log("Distanz",evt.target.get_distance().toFixed(0));
    console.log("Max_Hoehe",evt.target.get_elevation_max().toFixed(0));
    console.log("Min_Hoehe",evt.target.get_elevation_min().toFixed(0));
    console.log("name",evt.target.get_elevation_gain().toFixed(0));
    console.log("name",evt.target.get_elevation_loss().toFixed(0));
    let Distanz = evt.target.get_distance().toFixed(0);
    document.getElementById("Distanz").innerHTML= Distanz;
  });

  myMap.addControl(myMapControl);

  myMap.addLayer(etappe06Group)
