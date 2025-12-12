import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

Item {
    id: root

    signal metricsUpdated

    QtObject {
        id: units
        property var wind
        property var temperatureUnit
    }
    QtObject {
        id: coordinates
        property var latitude
        property var longitude
        property bool updateRecent
    }

    QtObject {
        id: ubication
        property string textUbication
    }

    FindCity {
        id: findCity
        onReady: {
            console.log("se esta ejecutando", findCity.cityPhoton)
            ubication.textUbication = findCity.cityPhoton
            coordinates.latitude = findCity.selectedLatitude
            coordinates.longitude = findCity.selectedLongitude
            coordinates.updateRecent = true
            console.log(coordinates.updateRecent, "gggggg", ubication.textUbication)
            Plasmoid.configurationChanged()
        }
    }

    ListModel {
        id: windUnitsModel
        Component.onCompleted: {
            append({ value: "km/h", translated: i18n("km/h") })
            append({ value: "mph", translated: i18n("mph") })
            append({ value: "m/s", translated: i18n("m/s") })
        }
    }

    ListModel {
        id: temperatureUnitsModel
        Component.onCompleted: {
            append({ value: "Celsius", translated: i18n("Celsius") })
            append({ value: "Fahrenheit", translated: i18n("Fahrenheit") })
        }
    }

    property alias cfg_windUnit: units.wind
    property alias cfg_temperatureUnit: units.temperatureUnit
    property alias cfg_ipLocation: ipLocation.checked
    property alias cfg_longitudeLocalized: coordinates.longitude
    property alias cfg_latitudeLocalized: coordinates.latitude
    property alias cfg_selectedMetrics: metricsLayout.selectedMetricNames
    property alias cfg_textUbication: ubication.textUbication
    property alias cfg_updateRecent: coordinates.updateRecent

    QtObject {
        id: metricsLayout

        property alias allMetrics: allMetrics
        property int currentSelected: 0
        property int maxSelected: 6

        property var selectedMetricNames: []

        Component.onCompleted: {
            for (var i = 0; i < allMetrics.count; i++) {
                if (metricsLayout.selectedMetricNames.indexOf(allMetrics.get(i).name) !== -1) {
                    allMetrics.setProperty(i, "selected", true)
                    currentSelected++
                }
            }
        }
    }

    ListModel {
        id: allMetrics
        ListElement { name: "Wind Speed"; selected: false }
        ListElement { name: "Feels Like"; selected: false }
        ListElement { name: "UV Level"; selected: false }
        ListElement { name: "Humidity"; selected: false }
        ListElement { name: "Rain"; selected: false }
        ListElement { name: "Max/Min"; selected: false }
        ListElement { name: "Sunrise / Sunset"; selected: false }
        ListElement { name: "Cloud Cover"; selected: false }
    }

    onMetricsUpdated: {
        metricsLayout.selectedMetricNames = []
        for (var i = 0; i < allMetrics.count; i++) {
            if (allMetrics.get(i).selected) {
                metricsLayout.selectedMetricNames.push(allMetrics.get(i).name)
            }
        }
        console.log("Selected metrics:", metricsLayout.selectedMetricNames)
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
        clip: true

        ColumnLayout {
            width: scrollView.width
            spacing: Kirigami.Units.largeSpacing

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Heading {
                    Layout.fillWidth: true
                    Layout.leftMargin: 5
                    Layout.rightMargin: 5
                    Layout.topMargin: 8
                    Layout.bottomMargin: 5
                    level: 4
                    text: i18n("Location")
                    color: Kirigami.Theme.textColor
                    font.weight: Font.DemiBold
                }

                Kirigami.Separator {
                    Layout.fillWidth: true
                }

                Kirigami.FormLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: Kirigami.Units.smallSpacing

                    CheckBox {
                        id: ipLocation
                        Kirigami.FormData.label: i18n("Use Location of your ip")
                        onCheckedChanged: {
                            if (checked) {
                                coordinates.latitude = 0
                                coordinates.longitude = 0
                            }
                        }
                    }

                    Button {
                        Layout.fillWidth: true
                        text: i18n("Search Coordinates")
                        enabled: !ipLocation.checked
                        onClicked: findCity.open()
                    }

                    TextField {
                        Kirigami.FormData.label: i18n("Latitude")
                        text: coordinates.latitude === 0 ? i18n("unknown") : coordinates.latitude
                        enabled: false
                        visible: !ipLocation.checked
                    }

                    TextField {
                        Kirigami.FormData.label: i18n("Longitude")
                        text: coordinates.longitude === 0 ? i18n("unknown") : coordinates.longitude
                        enabled: false
                        visible: !ipLocation.checked
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Heading {
                    Layout.fillWidth: true
                    Layout.leftMargin: 5
                    Layout.rightMargin: 5
                    Layout.topMargin: 8
                    Layout.bottomMargin: 5
                    level: 4
                    text: i18n("Units")
                    color: Kirigami.Theme.textColor
                    font.weight: Font.DemiBold
                }

                Kirigami.Separator {
                    Layout.fillWidth: true
                }

                Kirigami.FormLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: Kirigami.Units.smallSpacing

                    ComboBox {
                        id: windUnitBox
                        Kirigami.FormData.label: i18n("Wind Unit:")
                        textRole: "translated"
                        valueRole: "value"
                        model: windUnitsModel
                        onActivated: {
                            units.wind = windUnitsModel.get(currentIndex).value
                        }
                        function updateCurrentIndex() {
                            if (windUnitsModel.count === 0) return
                            for (var i = 0; i < windUnitsModel.count; i++) {
                                if (windUnitsModel.get(i).value === units.wind) {
                                    currentIndex = i
                                    return
                                }
                            }
                            currentIndex = 0
                        }
                        Component.onCompleted: {
                            Qt.callLater(function() {
                                updateCurrentIndex()
                            })
                        }
                    }
                    Connections {
                        target: windUnitsModel
                        function onCountChanged() {
                            if (windUnitsModel.count > 0) {
                                windUnitBox.updateCurrentIndex()
                            }
                        }
                    }

                    ComboBox {
                        id: unitsBox
                        Kirigami.FormData.label: i18n("Temperature Unit:")
                        textRole: "translated"
                        valueRole: "value"
                        model: temperatureUnitsModel
                        onActivated: {
                            units.temperatureUnit = temperatureUnitsModel.get(currentIndex).value
                        }
                        function updateCurrentIndex() {
                            if (temperatureUnitsModel.count === 0) return
                            for (var i = 0; i < temperatureUnitsModel.count; i++) {
                                if (temperatureUnitsModel.get(i).value === units.temperatureUnit) {
                                    currentIndex = i
                                    return
                                }
                            }
                            currentIndex = 0
                        }
                        Component.onCompleted: {
                            Qt.callLater(function() {
                                updateCurrentIndex()
                            })
                        }
                    }
                    Connections {
                        target: temperatureUnitsModel
                        function onCountChanged() {
                            if (temperatureUnitsModel.count > 0) {
                                unitsBox.updateCurrentIndex()
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Heading {
                    Layout.fillWidth: true
                    Layout.leftMargin: 5
                    Layout.rightMargin: 5
                    Layout.topMargin: 8
                    Layout.bottomMargin: 5
                    level: 4
                    text: i18n("Weather Metrics")
                    color: Kirigami.Theme.textColor
                    font.weight: Font.DemiBold
                }

                Kirigami.Separator {
                    Layout.fillWidth: true
                }

                Kirigami.FormLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: Kirigami.Units.smallSpacing

                    Repeater {
                        model: allMetrics
                        CheckBox {
                            checked: model.selected
                            Kirigami.FormData.label: i18n(model.name)
                            onClicked: {
                                if (checked) {
                                    if (metricsLayout.currentSelected < metricsLayout.maxSelected) {
                                        metricsLayout.currentSelected++
                                        allMetrics.setProperty(index, "selected", true)
                                    } else {
                                        checked = false
                                    }
                                } else {
                                    metricsLayout.currentSelected--
                                    allMetrics.setProperty(index, "selected", false)
                                }
                                metricsUpdated()
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }

}
