import QtQuick
import QtQuick.Layouts 1.15
import QtQuick.Controls
import org.kde.plasma.plasmoid
import "components" as Components
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import "./js/fahrenheitFormatt.js" as FahrenheitFormatt

Item {
    id: iconAndTem

    readonly property int horizontalPadding: 5
    readonly property int textPadding: 4
    readonly property real iconSpacingRatio: 0.2
    readonly property real iconSpacingDivisor: 8

    Layout.minimumWidth: widthReal
    Layout.minimumHeight: heightReal
    width: widthReal
    height: heightReal

    readonly property bool isVertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    property bool textweather: Plasmoid.configuration.showConditionsWeather
    property bool showTemperature: Plasmoid.configuration.showTemperatureWeather
    property bool activeweathershottext: heightH > 34
    property int fonssizes: Plasmoid.configuration.sizeFontPanel
    property int heightH: root.height
    property var hVerti: wrapper_vertical.implicitHeight
    property var heightReal: isVertical ? hVerti : root.height
    property string temperatureUnit: Plasmoid.configuration.temperatureUnit

    readonly property real tempTextWidth: (showTemperature && textGrados) ? (textGrados.implicitWidth + subtextGrados.implicitWidth) : 0
    readonly property real weatherTextWidth: (wrapper_weathertext && wrapper_weathertext.visible && shortweathertext) ? (shortweathertext.implicitWidth + textPadding) : 0
    readonly property real calculatedTextWidth: Math.max(tempTextWidth, weatherTextWidth)

    property var widthWidget: calculatedTextWidth
    property var widthReal: isVertical ? root.width : (horizontalPadding + icon.width + (calculatedTextWidth > 0 ? calculatedTextWidth + icon.width * iconSpacingRatio : 0) + horizontalPadding)

    MouseArea {
        id: compactMouseArea
        anchors.fill: parent

        hoverEnabled: true

        onClicked: root.expanded = !root.expanded
    }


    RowLayout {
        id: initial
        anchors.fill: parent
        implicitWidth: iconAndTem.horizontalPadding + icon.width + (iconAndTem.calculatedTextWidth > 0 ? iconAndTem.calculatedTextWidth + icon.width * iconAndTem.iconSpacingRatio : 0) + iconAndTem.horizontalPadding
        spacing: icon.width / iconAndTem.iconSpacingDivisor
        anchors.leftMargin: iconAndTem.horizontalPadding
        anchors.rightMargin: iconAndTem.horizontalPadding
        visible: !isVertical
        Kirigami.Icon {
            id: icon
            width: root.height < 17 ? 16 : root.height < 24 ? 22 : 24
            height: width
            source: weatherData.currentIconWeather
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            roundToIconSize: false
        }
        Column {
            id: columntemandweathertext
            Layout.fillWidth: false
            Layout.preferredWidth: iconAndTem.calculatedTextWidth
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            spacing: 0
            Item {
                width: parent.width
                height: Math.max(0, (parent.height - (temOfCo.visible ? temOfCo.height : 0) - (wrapper_weathertext.visible ? wrapper_weathertext.height : 0)) / 2)
            }
            Row {
                id: temOfCo
                width: iconAndTem.calculatedTextWidth
                height: showTemperature ? textGrados.implicitHeight : 0
                visible: showTemperature
                anchors.left: parent.left
                spacing: 0

                Label {
                    id: textGrados
                    height: parent.height
                    width: implicitWidth
                    text: Math.round(temperatureUnit === "Celsius" ?  weatherData.currentWeather : FahrenheitFormatt.fahrenheit(weatherData.currentWeather))
                    font.bold: boldfonts
                    font.pixelSize: fonssizes
                    color: PlasmaCore.Theme.textColor
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
                Label {
                    id: subtextGrados
                    height: parent.height
                    width: implicitWidth
                    text: temperatureUnit === "Celsius" ? " °C " : " °F "
                    horizontalAlignment: Text.AlignLeft
                    font.bold: boldfonts
                    font.pixelSize: fonssizes
                    color: PlasmaCore.Theme.textColor
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Item {
                id: wrapper_weathertext
                height: shortweathertext.implicitHeight
                width: iconAndTem.calculatedTextWidth
                visible: activeweathershottext & textweather
                anchors.left: parent.left
                Label {
                    id: shortweathertext
                    width: parent.width
                    text: weatherData.currentShortTextWeather
                    font.pixelSize: fonssizes
                    font.bold: true
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
    ColumnLayout {
        id: wrapper_vertical
        width: root.width
        implicitHeight: icon_vertical.height + (showTemperature ? textGrados_vertical.implicitHeight : 0)
        spacing: 2
        visible: isVertical
        Kirigami.Icon {
            id: icon_vertical
            width: root.width < 17 ? 16 : root.width < 24 ? 22 : 24
            height: root.width < 17 ? 16 : root.width < 24 ? 22 : 24
            source: weatherData.currentIconWeather
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            roundToIconSize: false
        }
        Row {
            id: temOfCo_vertical
            width: showTemperature ? (textGrados_vertical.implicitWidth + subtextGrados_vertical.implicitWidth) : 0
            height: showTemperature ? textGrados_vertical.implicitHeight : 0
            visible: showTemperature
            Layout.alignment: Qt.AlignHCenter

            Label {
                id: textGrados_vertical
                height: parent.height
                text: Math.round(temperatureUnit === "Celsius" ? weatherData.currentWeather : FahrenheitFormatt.fahrenheit(weatherData.currentWeather))
                font.bold: boldfonts
                font.pixelSize: fonssizes
                color: PlasmaCore.Theme.textColor
                horizontalAlignment: Text.AlignHCenter
            }
            Label {
                id: subtextGrados_vertical
                height: parent.height
                text: (temperatureUnit === "Celsius") ? " °C" : " °F"
                font.bold: boldfonts
                font.pixelSize: fonssizes
                color: PlasmaCore.Theme.textColor
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

}



