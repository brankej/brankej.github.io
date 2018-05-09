let myMap = L.map("mapdiv");        // http://leafletjs.com/reference-1.3.0.html#map-l-map

const citybikeGroup = L.featureGroup();

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
  "CityBikes" : citybikeGroup,
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


async function addGeojson(url) {
  console.log("URL wird geladen: ", url);
  const response = await fetch(url);
  console.log("Response: ", response);
  const citybike = await response.json();
  console.log("GeoJSON: ", citybike);
  const geojson = L.geoJSON(citybike, {
    style: function(feature) {
      return {color: "#ff0000"};
    },
    pointToLayer: function(geoJsonPoint, latlng) {
      return L.marker(latlng, {icon: L.icon({
        iconUrl: 'icons/cycling.png',
      })
      });
    }
  }).addTo(citybikeGroup);
  citybikeGroup.addLayer(geojson);
  myMap.fitBounds(citybikeGroup.getBounds());
  geojson.bindPopup(function(layer) {
    const props = layer.feature.properties;
    const popupText = `<h1>${props.STATION}</h1>
    <p> Bezirk: ${props.BEZIRK} </p>`;
    return popupText;
  });
  const hash = new L.Hash(myMap)
}

const url = "https://data.wien.gv.at/daten/geo?service=WFS&request=GetFeature&version=1.1.0&typeName=ogdwien:CITYBIKEOGD&srsName=EPSG:4326&outputFormat=json";

addGeojson(url);

myMap.addLayer(citybikeGroup)
myMap.addLayer(myLayers.bmapoverlay)
