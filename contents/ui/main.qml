import QtQuick
import QtQuick.Layouts 1.15
import "components" as Components
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import "./js/fahrenheitFormatt.js" as FahrenheitFormatt

PlasmoidItem {
    id: root

    Components.WeatherData {
        id: weatherData
    }

    property string temps
    Connections {
        target: weatherData
        function onDataChanged() {
            temps = (temperatureUnit === "Celsius" ? weatherData.dailyWeatherMax[0] : FahrenheitFormatt.fahrenheit(weatherData.dailyWeatherMax[0])) + `° | ` + (temperatureUnit === "Celsius" ? weatherData.dailyWeatherMin[0] : FahrenheitFormatt.fahrenheit(weatherData.dailyWeatherMin[0]) )+ "°"
        }
    }

    toolTipItem: ColumnLayout {

        Layout.preferredWidth: Kirigami.Units.gridUnit * 15
        Layout.preferredHeight: Kirigami.Units.gridUnit * 8
        Layout.minimumWidth: Kirigami.Units.gridUnit * 15
        Layout.minimumHeight: Kirigami.Units.gridUnit * 8

        Kirigami.Heading {
            Layout.alignment: Qt.AlignHCenter
            text: weatherData.city
            level: 5
        }

        Kirigami.Heading {
            Layout.alignment: Qt.AlignHCenter
            text: temps
            level: 5
        }
        Kirigami.Heading {
            Layout.alignment: Qt.AlignHCenter
            text: weatherData.currentTextWeather
            level: 5
        }
    }
    readonly property bool isVertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground | PlasmaCore.Types.ConfigurableBackground
    preferredRepresentation: isVertical ? width > 300 ? fullRepresentation : height > 300 ? fullRepresentation : compactRepresentation :  compactRepresentation

    property bool boldfonts: Plasmoid.configuration.fontBoldWeather
    property string temperatureUnit: Plasmoid.configuration.temperatureUnit
    property string sizeFontConfg: Plasmoid.configuration.sizeFontPanel

    compactRepresentation: CompactRepresentation {

    }
    fullRepresentation: FullRepresentation {
        width: sectionWidth + Kirigami.Units.gridUnit
        height: sectionHeight + Kirigami.Units.gridUnit
        Layout.minimumWidth: sectionWidth + Kirigami.Units.gridUnit
        Layout.minimumHeight: sectionHeight + Kirigami.Units.gridUnit
        Layout.maximumWidth: minimumWidth
        Layout.maximumHeight: minimumHeight
    }
}
