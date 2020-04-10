// COVID-19 MAP by webmapping.github.io edited by J.

//start TileLayer Leaflet
let startLayer = L.tileLayer.provider("Stamen.TonerLite");

//Map Initialization 
let map = L.map("map", {
    center: [30, 0],
    zoom: 2,
    layers: [
        startLayer
    ]
});

//FeatureGroup Initialization
let circleGroup = L.featureGroup().addTo(map);

//Add Control Layer Box
L.control.layers({
    "OpenTopoMap": L.tileLayer.provider("OpenTopoMap"),
    "OpenStreetMap.Mapnik": L.tileLayer.provider("OpenStreetMap.Mapnik"),
    "Stamen.TonerLite": startLayer,
    "Stamen.Watercolor": L.tileLayer.provider("Stamen.Watercolor"),
    "Stamen.Terrain": L.tileLayer.provider("Stamen.Terrain"),
    "Stamen.TerrainBackground": L.tileLayer.provider("Stamen.TerrainBackground"),
    "Esri.WorldStreetMap": L.tileLayer.provider("Esri.WorldStreetMap"),
    "Esri.WorldTopoMap": L.tileLayer.provider("Esri.WorldTopoMap"),
    "Esri.WorldImagery": L.tileLayer.provider("Esri.WorldImagery"),
    "Esri.WorldPhysical": L.tileLayer.provider("Esri.WorldPhysical"),
    "Esri.WorldGrayCanvas": L.tileLayer.provider("Esri.WorldGrayCanvas"),
    "CartoDB.Positron": L.tileLayer.provider("CartoDB.Positron")
}, {
    "Thematische Darstellung": circleGroup
}).addTo(map);


//######################################################################

// Main Function Stream John Hopkins CSV DATA with PapaParse and Display as Points on Leaflet Map
async function getCovidData(url) {
    //console.log("URL wird geladen: ", url);
    
    //download Data
    const data = await Papa.parse(url, {
        download: true,
        complete: function(results) {
            
            // on download complete make Map with streamed DATA
            let index = document.querySelector("#slider").value;
            //console.log("Index: ",index);
            let options = document.querySelector("#pulldown").options;
            let label = options[options.selectedIndex].text;
            //console.log("Label: ",label);
            let header =results.data[0];
            //console.log("Header:  ",header);
            //console.log("All Data: ",results.data)

            // Show Date and Theme
            document.querySelector("#datum").innerHTML = `am ${header[index]} - ${label}`;
            circleGroup.clearLayers();

            results.data.sort(function compareNumbers(row1, row2) {
                return row2[index] - row1[index];
            });

            // Change Color for each pulldown
            if (url === "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv") {
                color = "#0074D9";
            } else if (url === "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv") {
                color = "#B10DC9";
            } else {
                color = "#2ECC40";
            }
            
            // make MAP Points
            for (let i = 1; i < results.data.length-1; i++) { //-1 because empty row 264?
                let row = results.data[i];
                //console.log(row[2],row[3], i);
                let reg = `${row[0]} ${row[1]}`;
                let lat = row[2];
                let lng = row[3];
                let val = row[index];
                
                //skip if noone
                if (val === "0") {
                    continue;
                    //console.log(val)
                }
        
                //let mrk = L.marker([lat,lng]).addTo(map);
                //mrk.bindPopup(`${reg}: ${val}`);
        
                //A = r²*PI
                //r² = A/PI
                //r = WURZEL(A/PI)
                let s = 0.1; //default 0.5, went down to 0.1 because AMERICA

                let r = Math.sqrt(val * s / Math.PI);
                let circle = L.circleMarker([lat, lng], {
                    radius: r,
                    color: color
                }).addTo(circleGroup);
                circle.bindPopup(`${reg}: ${val}`);
            }
                //########################
                // Slide has to be inside function cause of header.length value, can't be accessed outside!
            
                //new function call on pulldown change
                document.querySelector("#pulldown").onchange = function () {
                    drawMap();
                };


                //define slider
                let slider = document.querySelector("#slider");
                slider.min = 4;
                slider.max = header.length - 1;
                slider.step = 1;
                slider.value = slider.max; //TODO: on each new function call, even on play=T slide value will be overwritten with sldier.max.

                slider.onchange = function () {
                    drawMap();
                };

                //add playbutton
                let playButton = document.querySelector("#play");
                let runningAnimation = null;

                //define playtrough
                playButton.onclick = function () {
                    let value;
                    if (slider.value == slider.max) {
                        value = slider.min;
                    } else {
                        value = slider.value;
                    }

                    playButton.value = "⏸";

                    if (runningAnimation) {
                        window.clearInterval(runningAnimation);
                        playButton.value = "▶";
                        runningAnimation = null;
                    } else {
                        runningAnimation = window.setInterval(function () {
                            slider.value = value;
                            drawMap();
                            value++;

                            if (value > slider.max) {
                                window.clearInterval(runningAnimation);
                                playButton.value = "▶";
                                runningAnimation = null;
                            }
                        }, 250)
                    }
                };

        }

    })  
  };

      

// Wrapper Function to feed url to PapaParse
let drawMap = function () {
    //get user picks
    let options = document.querySelector("#pulldown").options;
    let value = options[options.selectedIndex].value;

    if (value === "confirmed") {
        const url_conf =  "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv"
        getCovidData(url_conf);
    } else if (value === "deaths") {
        const url_deaths =  "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv"
        getCovidData(url_deaths);
    } else {
        const url_recov =  "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv"
        getCovidData(url_recov);
    }



};



//Initial Map fill
drawMap();
