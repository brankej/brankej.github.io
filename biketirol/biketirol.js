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
let overlaySteigung = L.featureGroup().addTo(myMap);
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
}).addTo(overlaySteigung).bindPopup(ehrwald_popup);

const scharnitz_marker = [47.388333,11.265]
let scharnitz_popup = '<h1>Scharnitz </h1><a href="https://de.wikipedia.org/wiki/Scharnitz">Wikipedia</a>'
L.marker(scharnitz_marker, {icon: L.icon({
  iconUrl: '../icons/flag-export.png',
  iconAnchor : [16,37],
  popupAnchor : [0,-37],
})
}).addTo(overlaySteigung).bindPopup(scharnitz_popup);

// Baselayer control für OSM, basemap.at, Elektronische Karte Tirol hinzufügen
let myMapControl  = L.control.layers({                // http://leafletjs.com/reference-1.3.0.html#control-layers-l-control-layers
  //Auswahl der Hintergrundkarte
  "OpenStreetMap" : myLayers.osm,
  "Geoland Basemap" : myLayers.geolandbasemap,
  "Land Tirol Sommer" : gdi_summerGrp,
  "Land Tirol Winter" : gdi_winterGrp,
  "Land Tirol Orthophoto" : gdi_orthoGrp,
}, {
  //overlay // Overlay controls zum unabhängigem Ein-/Ausschalten der Route und Marker hinzufügen
  //"Etappe 06" : etappe06Group,
  "Steigung" : overlaySteigung,
}, { //map control ausgeklappt lassen
  collapsed:false} );             // http://leafletjs.com/reference-1.3.0.html#control-layers-collapsed

  //leaflet elevation

  let hoehenprofil = L.control.elevation({
      position: "bottomleft",
      theme: "steelblue-theme", //default: lime-theme
      width: 600,
      height: 125,
      margins: {
          top: 10,
          right: 20,
          bottom: 30,
          left: 50
      },
      useHeightIndicator: true, //if false a marker is drawn at map position
      interpolation: "linear", //see https://github.com/mbostock/d3/wiki/SVG-Shapes#wiki-area_interpolate
      hoverNumber: {
          decimalsX: 3, //decimals on distance (always in km)
          decimalsY: 0, //deciamls on height (always in m)
          formatter: undefined //custom formatter function may be injected
      },
      xTicks: undefined, //number of ticks in x axis, calculated by default according to width
      yTicks: undefined, //number of ticks on y axis, calculated by default according to height
      collapsed: false    //collapsed mode, show chart on click or mouseover
    });
  hoehenprofil.addTo(myMap);


let gpxTrack = new L.GPX('data/etappe06.gpx', {
  async: true,
})//.addTo(etappe06Group);
  gpxTrack.on("loaded", function(evt) {
    myMap.fitBounds(evt.target.getBounds())
    let deep = evt.target.get_elevation_min().toFixed(0);
    document.getElementById("deep").innerHTML= deep;
    let peak = evt.target.get_elevation_max().toFixed(0);
    document.getElementById("peak").innerHTML= peak;
    let wayup = evt.target.get_elevation_gain().toFixed(0);
    document.getElementById("wayup").innerHTML= wayup;
    let waydown = evt.target.get_elevation_loss().toFixed(0);
    document.getElementById("waydown").innerHTML= waydown;
    let Distanz = evt.target.get_distance().toFixed(0);
    Distanz = Distanz/1000 //to km
    document.getElementById("Distanz").innerHTML= Distanz;
  });
  gpxTrack.on("addline",function(evt){
        hoehenprofil.addData(evt.line);
        console.log(evt.line.getLatLngs()[0]);
        console.log(evt.line.getLatLngs()[0].lat);
        console.log(evt.line.getLatLngs()[0].lng);
        console.log(evt.line.getLatLngs()[0].meta);
        console.log(evt.line.getLatLngs()[0].meta.ele);

        // alle Segmente der Steiungslinie hinzufügen
        let gpxLinie = evt.line.getLatLngs();
        for (let i = 1; i < gpxLinie.length; i++) {
          let p1 = gpxLinie[i-1];
          let p2 = gpxLinie[i];

          let dist = myMap.distance(
            [p1.lat,p1.lng],
            [p2.lat,p2.lng]
          );
          //höhenunterschied rechnen
          let delta = (p2.meta.ele -p1.meta.ele).toFixed(1);

          //steigung in %
          //let proz2 = 0;
          //if (dist > 0) {
          //  proz2 = (delta / dist * 100.0).toFixed(1);
          //};
          let proz = (dist > 0 ) ?  (delta / dist * 100.0).toFixed(1) : 0;


          console.log(p1.lat,p1.lng,p2.lat,p2.lng, dist, delta, proz);

          let farbe =
            proz > 10  ? "#cb181d" :
            proz > 6   ? "#fb6a4a" :
            proz > 2   ? "#fcae91" :
            proz > 0   ? "#fee5d9" :
            proz > -2  ? "#edf8e9" :
            proz > -6  ? "#bae4b3" :
            proz > -10 ? "#74c476" :
                          "#238b45";

          let segment = L.polyline(
            [
            [p1.lat,p1.lng],
            [p2.lat,p2.lng],
          ],{
              color: farbe,
              weight : 10,

            }
          ).addTo(overlaySteigung)
        }
  });

myMap.addControl(myMapControl);
myMap.addLayer(etappe06Group);
