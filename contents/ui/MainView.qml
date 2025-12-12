import QtQuick
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami as Kirigami
import "./js/fahrenheitFormatt.js" as FahrenheitFormatt

Item {

    property int generalMargin: 4

    property string formatTime: Plasmoid.configuration.UseFormat12hours ? "h:mm ap" : "h:mm"
    property var titles
    property var namesTitles

    property string titlesBeading: Plasmoid.configuration.selectedMetrics
    property string temperatureUnitUpdate: temperatureUnit
    property string windUnitUpdate: Plasmoid.configuration.windUnit

    property string formattTime: ""
    property var valuesMainView: []

    function getTranslatedWindUnit(unit) {
        if (unit === "km/h") return i18n("km/h")
        if (unit === "mph") return i18n("mph")
        if (unit === "m/s") return i18n("m/s")
        return unit
    }

    function getTranslatedTempUnit(unit) {
        if (unit === "Celsius") return "°C"
        if (unit === "Fahrenheit") return "°F"
        return unit
    }

    property var listMetrics: [
    { name: "Feels Like", nameText: "Feels Like", value: (temperatureUnit === "Celsius" ? weatherData.apparentTemperature : FahrenheitFormatt.fahrenheit(weatherData.apparentTemperature)) + "°"},
    { name: "UV Level", nameText: i18n("UV"), value: weatherData.currentUvIndexText },
    { name: "Humidity", nameText: "Humidity", value: weatherData.currentWeather + "%" },
    { name: "Max/Min", nameText: "Max/Min", value: (temperatureUnit === "Celsius" ? weatherData.dailyWeatherMax[0] : FahrenheitFormatt.fahrenheit(weatherData.dailyWeatherMax[0])) + `|` + (temperatureUnit === "Celsius" ? weatherData.dailyWeatherMin[0] : FahrenheitFormatt.fahrenheit(weatherData.dailyWeatherMin[0])) },
    { name: "Rain", nameText: "Rain", value: weatherData.dailyWeatherMax[0] + "%"},
    { name: "Wind Speed", nameText: "Wind", value: roundMax2Number((windUnitsUpdate(weatherData.windSpeed, Plasmoid.configuration.windUnit))) + " " + getTranslatedWindUnit(Plasmoid.configuration.windUnit)},
    { name: "Sunrise / Sunset", nameText: "Sunrise / Sunset", value: sunriseOrSunset() },
    { name: "Cloud Cover", nameText: "Cloudiness", value: weatherData.cloudCover + "%"}
    ]

    function updateValues() {
        var newValues = [];
        var newNames = [];
        for (var i = 0; i < titles.length; i++) {
            for (var o = 0; o < listMetrics.length; o++){
                if (titles[i] === listMetrics[o].name) {
                    newNames.push(listMetrics[o].nameText);
                    newValues.push(listMetrics[o].value);
                }
            }
        }
        valuesMainView = newValues;
        namesTitles = newNames
    }

    function formatTimeWithCustomAMPM(dateTime, format) {
        var formatted = Qt.formatDateTime(dateTime, format);
        formatted = formatted.replace(/\bPM\b/g, function(match) {
            return i18n("pm")
        });
        formatted = formatted.replace(/\bpm\b/g, function(match) {
            return i18n("pm")
        });
        return formatted;
    }

    function sunriseOrSunset() {
        if (weatherData.hourlyIsDay[0] === 1) {
            return formatTimeWithCustomAMPM(weatherData.hourlyTimes[weatherData.hourlyIsDay.indexOf(0)], formatTime);
        } else {
            return formatTimeWithCustomAMPM(weatherData.hourlyTimes[weatherData.hourlyIsDay.indexOf(1)], formatTime);
        }
    }

    function windUnitsUpdate(kmh, x) {
        const metresPerSecond = kmh * (5 / 18);
        const milesPerHour = kmh * 0.621371;

        return x === "m/s"
        ? metresPerSecond
        : x === "mph"
        ? milesPerHour
        : kmh;
    }

    function roundMax2Number(val) {
        var n = Number(val);
        if (!isFinite(n)) return val;
        return Math.round(n * 100) / 100;
    }

    function formatMax2(val) {
        var n = Number(val);
        if (!isFinite(n)) return "";
        var s = n.toFixed(2).replace(/\.?0+$/, "");
        return s;
    }

    Connections {
        target: weatherData
        function onDataChanged() {
            updateValues()
        }
    }

    onTitlesBeadingChanged: {
        titles = [].concat(Plasmoid.configuration.selectedMetrics)
        updateValues()
    }
    onWindUnitUpdateChanged: {
        titles = [].concat(Plasmoid.configuration.selectedMetrics)
        updateValues()
    }

    onTemperatureUnitUpdateChanged: {
        titles = [].concat(Plasmoid.configuration.selectedMetrics)
        updateValues()
    }

    Component.onCompleted: {
        titles = [].concat(Plasmoid.configuration.selectedMetrics)
        if (weatherData.updateWeather) {
            updateValues()
        }
    }

    Column {
        width: parent.width - generalMargin
        height: parent.height - generalMargin
        spacing: 4

        Item {
            id: currentConditionsSection
            width: parent.width
            height: 64

            Text {
                id: currentTemp
                height: currentConditionsSection.height
                text: temperatureUnit === "Celsius" ? weatherData.currentWeather : FahrenheitFormatt.fahrenheit(weatherData.currentWeather)
                color: Kirigami.Theme.textColor
                font.pixelSize: height
            }

            Text {
                id: tempUnit
                anchors.left: parent.left
                anchors.leftMargin: currentTemp.implicitWidth + 4
                anchors.bottom: maxMin.top
                text: getTranslatedTempUnit(temperatureUnit)
                color: Kirigami.Theme.textColor
                verticalAlignment: Text.AlignVCenter
                height: 64 - maxMin.height -4
                font.pixelSize: currentTemp.height/2
            }

            Kirigami.Heading {
                id: maxMin
                anchors.left: parent.left
                anchors.leftMargin: currentTemp.implicitWidth + 4
                anchors.bottom: parent.bottom
                text: weatherData.currentTextWeather ? weatherData.currentTextWeather : "--"
                font.weight: Font.DemiBold
                opacity: 0.6
                level: 5
            }

            Kirigami.Icon {
                id: weatherIcon
                width: parent.height
                height: width
                source: weatherData.currentIconWeather
                anchors.right: parent.right
            }
        }

        Item {
            id: detailsSection
            width: parent.width
            height: (parent.height - currentConditionsSection.height)
            Flow {
                id: detailFlow
                width: parent.width
                height: Kirigami.Units.gridUnit*4.5
                anchors.bottom: parent.bottom

                Repeater {
                    model: titles.length

                    Column {

                        width: detailFlow.width / 3
                        height: detailFlow.height/2
                        spacing: 4

                        Kirigami.Heading {
                            width: parent.width
                            text: namesTitles[modelData] === "Sunrise / Sunset" ? weatherData.hourlyIsDay[0] === 1 ? i18n("Sunset") : i18n("Sunrise") : i18n(namesTitles[modelData])
                            horizontalAlignment: Text.AlignHCenter
                            font.weight: Font.DemiBold
                            level: 5
                        }

                        Kirigami.Heading {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: valuesMainView[modelData] ? valuesMainView[modelData]  : "--"
                            opacity: 0.7
                            level: 5
                        }
                    }
                }
            }
        }
    }
}
