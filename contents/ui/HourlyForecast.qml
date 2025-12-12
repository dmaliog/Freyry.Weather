import QtQuick
import QtQuick.Layouts
import "lib" as Lib
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import "./js/fahrenheitFormatt.js" as FahrenheitFormatt

Item {
    objectName: "rootHourlyForecast"

    property string temperatureUnit: Plasmoid.configuration.temperatureUnit
    property var iconsHourlyForecast: []
    property var weatherHourlyForecast: []
    property var rainHourlyForecast: []
    property var timesDatesForecast
    property string unitTemp: temperatureUnit
    property bool hours12Format: Plasmoid.configuration.UseFormat12hours
    property string prefixHoursFormatt: hours12Format ? "h ap" : "H"
    property int currentStartIndex: 1
    
    function updateStartIndex() {
        var now = new Date()
        var currentHour = now.getHours()
        if (weatherData.hourlyTimes && weatherData.hourlyTimes.length > 0) {
            for (var i = 0; i < weatherData.hourlyTimes.length; i++) {
                var dateObj = new Date(weatherData.hourlyTimes[i])
                var hour = parseInt(Qt.formatDateTime(dateObj, "H"))
                if (hour >= currentHour) {
                    currentStartIndex = i
                    return
                }
            }
        }
        currentStartIndex = 1
    }

    Lib.Card {
       anchors.fill: parent
       anchors.topMargin: Kirigami.Units.smallSpacing * 2
       
       GridLayout {
           anchors.fill: parent
           anchors.margins: Kirigami.Units.smallSpacing
           columns: 5
           rowSpacing: Kirigami.Units.smallSpacing
           columnSpacing: Kirigami.Units.smallSpacing

           Repeater {
               id: repeater
               model: 5
               delegate: Rectangle {
                   Layout.fillWidth: true
                   Layout.fillHeight: true
                   color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.1)
                   radius: 4

                   Column {
                       id: columnDelegate
                       anchors.centerIn: parent
                       width: parent.width - Kirigami.Units.smallSpacing * 2
                       spacing: Kirigami.Units.smallSpacing * 2
                       property int itemIndex: {
                           var root = columnDelegate
                           for (var i = 0; i < 10 && root.parent; i++) {
                               root = root.parent
                               if (root.hasOwnProperty && root.hasOwnProperty("currentStartIndex")) {
                                   return root.currentStartIndex + modelData
                               }
                           }
                           return modelData + 1
                       }
                       Kirigami.Heading {
                           id: hours
                           width: parent.width
                           horizontalAlignment: Text.AlignHCenter
                           text: timesDatesForecast[parent.itemIndex] === undefined ? "--" : timesDatesForecast[parent.itemIndex]
                           level: 5
                       }
                       Kirigami.Icon {
                           id: icon
                           source: iconsHourlyForecast[parent.itemIndex]
                           width: 24
                           anchors.horizontalCenter: parent.horizontalCenter
                           height: width
                       }
                       Kirigami.Heading {
                           id: temperature
                           width: parent.width
                           horizontalAlignment: Text.AlignHCenter
                           text: weatherHourlyForecast[parent.itemIndex] === undefined ? "--" : Math.round(weatherHourlyForecast[parent.itemIndex]) + "°"
                           level: 5
                       }
                       Kirigami.Heading {
                           id: rain
                           width: parent.width
                           horizontalAlignment: Text.AlignHCenter
                           text: rainHourlyForecast[parent.itemIndex] === undefined ? "--" : "💧" +  Math.round(rainHourlyForecast[parent.itemIndex])
                           level: 5
                       }
                   }
               }
           }
       }
    }
    function formatTimeWithCustomAMPM(dateTime, format) {
        var dateObj = new Date(dateTime);
        var hour24 = parseInt(Qt.formatDateTime(dateObj, "H"));
        var is12Hour = Plasmoid.configuration.UseFormat12hours;
        var formatted;
        var timeOfDay = "";
        var localeName = Qt.locale().name;
        
        if (localeName && (localeName.indexOf("en") === 0)) {
            if (hour24 >= 0 && hour24 < 12) {
                timeOfDay = i18n("morning");
            } else {
                timeOfDay = i18n("afternoon");
            }
        } else {
            if (hour24 >= 5 && hour24 < 12) {
                timeOfDay = i18n("morning");
            } else if (hour24 >= 12 && hour24 < 17) {
                timeOfDay = i18n("afternoon");
            } else if (hour24 >= 17 && hour24 < 22) {
                timeOfDay = i18n("evening");
            } else {
                timeOfDay = i18n("night");
            }
        }
        
        var hour12;
        if (is12Hour) {
            if (hour24 === 0) {
                hour12 = 12;
            } else if (hour24 > 12) {
                hour12 = hour24 - 12;
            } else {
                hour12 = hour24;
            }
            formatted = hour12.toString();
        } else {
            var timeFormat = format.replace(" ap", "").replace("ap", "");
            if (timeFormat === "h" || timeFormat === "hh") {
                timeFormat = "H";
            }
            formatted = Qt.formatDateTime(dateObj, timeFormat);
        }
        return formatted + " " + timeOfDay;
    }

    function updateDatesWeather(){
        var newArrayWeatherHourlyForecast = []
        timesDatesForecast = weatherData.hourlyTimes.map(function(iso) {
            return formatTimeWithCustomAMPM(iso, prefixHoursFormatt)
        })
        iconsHourlyForecast = weatherData.iconsHourlyWeather
        for (var e = 0; e < weatherData.hourlyWeather.length; e++) {
            newArrayWeatherHourlyForecast.push(temperatureUnit === "Celsius" ? weatherData.hourlyWeather[e] : FahrenheitFormatt.fahrenheit(weatherData.hourlyWeather[e]))
        }
        weatherHourlyForecast = newArrayWeatherHourlyForecast
        rainHourlyForecast = weatherData.hourlyPrecipitationProbability
    }

    Connections {
        target: weatherData
        function onDataChanged() {
           updateDatesWeather()
           updateStartIndex()
        }
    }
    onTemperatureUnitChanged: {
        updateDatesWeather()
    }
    onUnitTempChanged: {
        updateDatesWeather()
    }
    Component.onCompleted: {
        updateDatesWeather()
        updateStartIndex()
    }
}
