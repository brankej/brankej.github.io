// set initial center point, zoom, and layers
let startCenter = [47.267, 11.383];
let minLatLng = [46.735686, 10.394005];
let maxLatLng = [47.620789, 12.576880];
let startZoom = 14;
let minZoom = 9;
let layer1 = 'ortho_1970_1982';
let layer2 = 'ortho_aktuell_rgb';

// define baselayers and insert further below, and also in index.html

let ortho_1970_1982 = L.tileLayer.wms(
  "https://gis.tirol.gv.at/arcgis/services/Service_Public/orthofoto/MapServer/WMSServer?", {
    layers: "Image_1970-1982",
    attribution : "Datenquelle: <a href ='https://www.tirol.gv.at/data/nutzungsbedingungen/'> Land Tirol - data.tirol.gv.at </a>",
    transparent: true,
    format: 'image/png',
    pane: "overlayPane",
  }
)

let ortho_1999_2004 = L.tileLayer.wms(
  "https://gis.tirol.gv.at/arcgis/services/Service_Public/orthofoto/MapServer/WMSServer?", {
    layers: "Image_1999-2004",
    attribution : "Datenquelle: <a href ='https://www.tirol.gv.at/data/nutzungsbedingungen/'> Land Tirol - data.tirol.gv.at </a>",
    transparent: true,
    format: 'image/png',
    pane: "overlayPane",
  }
)

let ortho_2004_2009 = L.tileLayer.wms(
  "https://gis.tirol.gv.at/arcgis/services/Service_Public/orthofoto/MapServer/WMSServer?", {
    layers: "Image_2004-2009",
    attribution : "Datenquelle: <a href ='https://www.tirol.gv.at/data/nutzungsbedingungen/'> Land Tirol - data.tirol.gv.at </a>",
    transparent: true,
    format: 'image/png',
    pane: "overlayPane",
  }
)

let ortho_2009_2012 = L.tileLayer.wms(
  "https://gis.tirol.gv.at/arcgis/services/Service_Public/orthofoto/MapServer/WMSServer?", {
    layers: "Image_2009-2012",
    attribution : "Datenquelle: <a href ='https://www.tirol.gv.at/data/nutzungsbedingungen/'> Land Tirol - data.tirol.gv.at </a>",
    transparent: true,
    format: 'image/png',
    pane: "overlayPane",
  }
)

let ortho_2013_2015 = L.tileLayer.wms(
  "https://gis.tirol.gv.at/arcgis/services/Service_Public/orthofoto/MapServer/WMSServer?", {
    layers: "Image_2013-2015",
    attribution : "Datenquelle: <a href ='https://www.tirol.gv.at/data/nutzungsbedingungen/'> Land Tirol - data.tirol.gv.at </a>",
    transparent: true,
    format: 'image/png',
    pane: "overlayPane",
  }
)

let ortho_aktuell_rgb = L.tileLayer.wms(
  "https://gis.tirol.gv.at/arcgis/services/Service_Public/orthofoto/MapServer/WMSServer?", {
    layers: "Image_Aktuell_RGB",
    attribution : "Datenquelle: <a href ='https://www.tirol.gv.at/data/nutzungsbedingungen/'> Land Tirol - data.tirol.gv.at </a>",
    transparent: true,
    format: 'image/png',
    pane: "overlayPane",
  }
)

// Insert basemap letiables; return layer named s
function pickLayer(s) {
  switch (s) {
    case 'ortho_1970_1982':
      return ortho_1970_1982;
    case 'ortho_1999_2004':
      return ortho_1999_2004;
    case 'ortho_2004_2009':
      return ortho_2004_2009;
    case 'ortho_2009_2012':
      return ortho_2009_2012;
    case 'ortho_2013_2015':
      return ortho_2013_2015;
    case 'ortho_aktuell_rgb':
      return ortho_aktuell_rgb;
    default:
      return ortho_1970_1982;
  }
}

// Create two maps
let map1 = L.map('map1', {
    layers: pickLayer(layer1),
    center: startCenter,
    zoom: startZoom,
    zoomControl: false,
    minZoom: minZoom,
    scrollWheelZoom: false,
    //maxBounds: [minLatLng,maxLatLng]
});

let map2 = L.map('map2', {
    layers: pickLayer(layer2),
    center: startCenter,
    zoom: startZoom,
    minZoom: minZoom,
    zoomControl: false,
    scrollWheelZoom: false,
    //maxBounds: [minLatLng,maxLatLng]
});

/* // TODO:
// customize link to view source code; add your own GitHub repository
map1.attributionControl
.setPrefix('View <a href="http://github.com/jackdougherty/leaflet-map-sync" target="_blank">code on GitHub</a>');
map2.attributionControl
.setPrefix('');

*/
// Reposition zoom control other than default topleft
L.control.zoom({position: "topright"}).addTo(map1);
L.control.zoom({position: "topright"}).addTo(map2);

// Maßstab metrisch ohne inch
//Maßstabsleiste
let myScale = L.control.scale({
  position : "bottomleft",
  maxWidth : 200,
  imperial : false,
  metric : true
});

myScale.addTo(map2);



// sync code adapted from https://www.mapbox.com/mapbox.js/example/v1.0.0/sync-layer-movement/
// when either map finishes moving, trigger an update on the other one
map1.on('moveend', follow).on('zoomend', follow);
map2.on('moveend', follow).on('zoomend', follow);

// when calling sync, do not infinitely loop again and sync other maps
let quiet = false;
function follow(e) {
    if (quiet) return;
    quiet = true;
    if (e.target === map1) sync(map2, e);
    if (e.target === map2) sync(map1, e);
    quiet = false;
}

// sync steals settings from the moved map (e.target) and applies them to other map
function sync(map, e) {
    map.setView(e.target.getCenter(), e.target.getZoom(), {
        animate: false,
        reset: true
    });
}

function changeBasemap(map, basemap) {
  let other_map = (map === 'map1') ? 'map2' : 'map1';
  let mAp = (map === 'map1') ? map1 : map2; // TODO:  changed map to mAp because redeclaration

  // Disable selected layer on the neighbor map
  // (if two maps load the same layer, weird behavior observed)
  $('#' + other_map + 'basemaps option').removeAttr('disabled');
  $('#' + other_map + 'basemaps option[value="' + basemap + '"]').attr('disabled', 'disabled');

// function that removes loaded layers
function clearAllLayers(){
  let featureLayerCollection = [ortho_1970_1982,ortho_1999_2004,ortho_2004_2009,ortho_2009_2012,ortho_2013_2015,ortho_aktuell_rgb]
  for (let i = 0; i < featureLayerCollection.length; i++) {
      mAp.removeLayer(featureLayerCollection[i]);
  }
  //this line empties the array
  featureLayerCollection.length = 0;
  }
  clearAllLayers()

  // Add appropriate new layer -- insert all basemap letiables
  switch (basemap) {
    case 'ortho_1970_1982':
      mAp.addLayer(ortho_1970_1982);
      break;
    case 'ortho_1999_2004':
      mAp.addLayer(ortho_1999_2004);
      break;
    case 'ortho_2004_2009':
      mAp.addLayer(ortho_2004_2009);
      break;
    case 'ortho_2009_2012':
      mAp.addLayer(ortho_2009_2012);
      break;
    case 'ortho_2013_2015':
      mAp.addLayer(ortho_2013_2015);
      break;
    case 'ortho_aktuell_rgb':
      mAp.addLayer(ortho_aktuell_rgb);
      break;
    default:
      break;
  }
}

// Set up to create permalink
$(document).ready(function() {
  $('#map1basemaps select').change(function() {
    changeBasemap('map1', $(this).val());
  });

  $('#map2basemaps select').change(function() {
    changeBasemap('map2', $(this).val());
  });

  // Generate permalink on click
  $('#permalink').click(function() {
    let zoom = map1._zoom;
    let lat = map1.getCenter().lat;
    let lng = map1.getCenter().lng;
    let layer1 = $('#map1basemaps select').val();
    let layer2 = $('#map2basemaps select').val();
    let href = '#zoom=' + zoom + '&lat=' + lat + '&lng=' +
                  lng + '&layer1=' + layer1 + '&layer2=' + layer2;
    // Update URL in browser
    window.location.hash = href;
    window.prompt("Copy with Cmd+C (Mac) or Ctrl+C", window.location.href);
  });

});
