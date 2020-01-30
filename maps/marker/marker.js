let myMap = L.map("mapdiv");        // http://leafletjs.com/reference-1.3.0.html#map-l-map

let markerGroup = L.featureGroup();      //http://leafletjs.com/reference-1.3.0.html#featuregroup-l-featuregroup

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
  bmapoverlay : L.tileLayer(
    "https://{s}.wien.gv.at/basemap/bmapoverlay/normal/google3857/{z}/{y}/{x}.png", {
      subdomains : ["maps", "maps1", "maps2", "maps3", "maps4"],
      attribution : "Datenquelle: <a href ='https://basemap.at'> basemap.at </a>"
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
};


myMap.addLayer(myLayers.bmaporthofoto30cm);                    // http://leafletjs.com/reference-1.3.0.html#map-addlayer
myMap.addLayer(markerGroup);

let myMapControl  = L.control.layers({                // http://leafletjs.com/reference-1.3.0.html#control-layers-l-control-layers
  //Auswahl der Hintergrundkarte
  "OpenStreetMap" : myLayers.osm,
  "Geoland Basemap" : myLayers.geolandbasemap,
  "Geoland Map Grey" : myLayers.bmapgrau,
  "Geoland Map Highdpi" : myLayers.bmaphidip,
  "Geoland Orthophoto 30cm" : myLayers.bmaporthofoto30cm,
}, {
  //overlay
  "Geoland Mapoverlay" : myLayers.bmapoverlay,
  "Marker" :  markerGroup,
}, { //map control ausgeklappt lassen
  collapsed:false} );                               // http://leafletjs.com/reference-1.3.0.html#control-layers-collapsed


myMap.addControl(myMapControl);                     // http://leafletjs.com/reference-1.3.0.html#map-addcontrol

//Maßstabsleiste
let myScale = L.control.scale({   //http://leafletjs.com/reference-1.3.0.html#control-scale-l-control-scale
  position : "bottomleft",        // http://leafletjs.com/reference-1.3.0.html#control-position
  maxWidth : 200,                 // http://leafletjs.com/reference-1.3.0.html#control-scale-maxwidth
  imperial : false,               // http://leafletjs.com/reference-1.3.0.html#control-scale-imperial
  metric : true                   // http://leafletjs.com/reference-1.3.0.html#control-scale-metric
});

myScale.addTo(myMap);             // http://leafletjs.com/reference-1.3.0.html#control-addto

const unicoords = [47.267,11.383]
const usicoords = [47.257,11.356]
const technikcoords = [47.263,11.343]

const markeroptions = {title: "Universität Innsbruck",     //http://leafletjs.com/reference-1.3.0.html#marker-title
    draggable : false,                   //http://leafletjs.com/reference-1.3.0.html#marker-draggable
    opacity : 0.7,                       //http://leafletjs.com/reference-1.3.0.html#marker-opacity
  }


L.marker(unicoords, markeroptions).addTo(markerGroup);    //http://leafletjs.com/reference-1.3.0.html#marker-l-marker
L.marker(usicoords, markeroptions).addTo(markerGroup);
L.marker(technikcoords, markeroptions).addTo(markerGroup);


const patscherkofelcoords = [47.208611, 11.460556]
const iglscoords = [47.230833, 11.408889]


let patscherkofelmarker = L.marker(patscherkofelcoords).addTo(markerGroup);
patscherkofelmarker.bindPopup("<p>Patscherkofel</p><img style='width:200px' src='https://media05.regionaut.meinbezirk.at/2017/02/12/12019164_preview.jpg?1486911814' alt='Patscherkofel'/>");
L.marker(iglscoords).addTo(markerGroup);


myMap.fitBounds(                            //http://leafletjs.com/reference-1.3.0.html#map-fitbounds
  markerGroup.getBounds());                 //http://leafletjs.com/reference-1.3.0.html#map-getbounds


  // create a red polyline from an array of LatLng points
L.polyline([patscherkofelcoords,iglscoords], {color: 'white'}).addTo(myMap);

let unipolygon = L.polygon([unicoords, usicoords, technikcoords], {color: 'blue'}).addTo(myMap);
