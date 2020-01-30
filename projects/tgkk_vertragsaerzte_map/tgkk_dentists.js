/*
    Übersichtskarte Gletscher Tirol
    -------------------------------------------------------------------

*/

//  Leaflet Map with fullscreen
let myMap = L.map("map", {
    fullscreenControl: true,
    zoom: 9,
    center: new L.LatLng(47.267,11.383),  // like -> myMap.setView([47.267,11.383], 10);
  });

let toothpts = L.markerClusterGroup();

//make selectable maps and overlays
let myLayers = {
  osm : L.tileLayer(
    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      subdomains : ["a", "b", "c"],
      attribution : "Datenquelle: <a href = 'https://www.openstreetmap.org/' > © OpenStreetMap</a> Mitwirkende"
    }
  ),
  stamen_toner: L.tileLayer("https://stamen-tiles-{s}.a.ssl.fastly.net/toner/{z}/{x}/{y}.png", {
        subdomains: ["a", "b", "c"],
        attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, under <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a>. Data by <a href="http://openstreetmap.org">OpenStreetMap</a>, under <a href="http://www.openstreetmap.org/copyright">ODbL</a>.'
    }),
};


myMap.addLayer(myLayers.stamen_toner);

// Maßstab metrisch ohne inch
//Maßstabsleiste
let myScale = L.control.scale({
  position : "bottomleft",
  maxWidth : 200,
  imperial : false,
  metric : true
});

myScale.addTo(myMap);




// TODO: Please credit as follows: Maps Icons Collection https://mapicons.mapsmarker.com

//===================Nordtirol==============
const geojson = L.geoJSON(data, {
  style: function(feature) {
    return {color: "#ff0000"};
  },
  pointToLayer: function(geoJsonPoint, latlng) {
    return L.marker(latlng, {icon: L.icon({
      iconUrl: 'icons/dentist.png',
      iconAnchor : [16,37],
      popupAnchor : [0,-37],
    })
    });
  }
}).addTo(toothpts);
toothpts.addLayer(geojson);
myMap.fitBounds(toothpts.getBounds());
toothpts.bindPopup(function(layer) {
  const props = layer.feature.properties;
  const popupText = `<h1>${props.Name}</h1>
  <p> Adresse:  ${props.Adresse}</p><p> TEL:  ${props.Tel}</p><p> Aufnahme:  ${props.Aufnahme}</p>`;
  return popupText;
});



myMap.addLayer(toothpts);



// Baselayer control
let myMapControl  = L.control.layers({
  "OpenStreetMap" : myLayers.osm,
  "Stamen Toner" : myLayers.stamen_toner,
}, {
  //overlay // Overlay controls zum unabhängigem Ein-/Ausschalten der Route und Marker hinzufügen
  "TGKK Zahnärzte" : toothpts,
}, { //map control ausgeklappt lassen
  collapsed:false} );

myMap.addControl(myMapControl);

//=======================================================================

const hash = new L.Hash(myMap);

//=======================================================================

myMap.addControl( new L.Control.Search({
  layer: toothpts,
  initial: false,
  propertyName: 'Name',
}));

