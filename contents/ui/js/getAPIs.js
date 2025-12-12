function obtenerDatosClimaticos(latitud, longitud, callback) {
    let url = `https://api.open-meteo.com/v1/forecast?latitude=${latitud}&longitude=${longitud}&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,rain,showers,weather_code,cloud_cover,wind_speed_10m,uv_index&hourly=temperature_2m,precipitation_probability,weather_code,is_day,uv_index&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max&timezone=auto`;
    let req = new XMLHttpRequest();
    req.open("GET", url, true);

    req.onreadystatechange = function () {
        if (req.readyState === 4) {
            if (req.status === 200) {
                let datos = JSON.parse(req.responseText);
                callback(datos);
            } else {
                callback(null);
            }
        }
    };

    req.onerror = function () {
        callback(null); 
    };

    req.send();
}

function getNameCity(latitude, longitud, leng, callback) {
    let url = `https://nominatim.openstreetmap.org/reverse?format=json&lat=${latitude}&lon=${longitud}&accept-language=${leng}`;

    let req = new XMLHttpRequest();
    req.open("GET", url, true);

    req.onreadystatechange = function () {
        if (req.readyState === 4) {
            if (req.status === 200) {
                try {
                    let datos = JSON.parse(req.responseText);
                    let address = datos.address;
                    let city = address.city;
                    let county = address.county;
                    let state = address.state;
                    let full = city ? city : state ? state : county;
                    callback(full);
                } catch (e) {
                    callback(null);
                }
            } else {
                callback(null);
            }
        }
    };

    req.onerror = function () {
        callback(null);
    };

    req.ontimeout = function () {
        callback(null);
    };

    req.send();
}

function obtenerCoordenadas(callback) {
    let url = "http://ip-api.com/json/";

    let req = new XMLHttpRequest();
    req.open("GET", url, true);

    req.onreadystatechange = function () {
        if (req.readyState === 4) {
            if (req.status === 200) {
                try {
                    let datos = JSON.parse(req.responseText);
                    callback(datos);
                } catch (error) {
                    callback(null);
                }
            } else {
                callback(null);
            }
        }
    };

    req.onerror = function () {
        callback(null);
    };

    req.send();
}
