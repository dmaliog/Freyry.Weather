import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.Dialog {
    id: dialog
    title: i18n("Search Coordinates")
    width: 450
    height: Kirigami.Units.gridUnit * 6

    property double selectedLatitude: 0
    property double selectedLongitude: 0

    property string cityPhoton

    signal ready

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: headerItem ? headerItem.height : Kirigami.Units.gridUnit * 2.5
        height: 1
        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.2)
    }

    Column {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: 5
        spacing: 5

        TextField {
            id: searchField
            width: parent.width
            placeholderText: i18n("Search location...")
            focus: true
            onTextChanged: {
                if (text.length > 2) {
                    searchLocations(text)
                } else {
                    resultsModel.clear()
                    resultsView.height = 0
                    dialog.height = Kirigami.Units.gridUnit * 6
                }
            }
            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Escape) {
                    dialog.close()
                }
            }
        }

        ListView {
            id: resultsView
            width: parent.width
            height: Math.min(resultsModel.count * Kirigami.Units.gridUnit*2.5, Kirigami.Units.gridUnit*16)
            model: resultsModel
            clip: true
            spacing: 2

            delegate: ItemDelegate {
                width: ListView.view.width
                height: Kirigami.Units.gridUnit*2.5
                padding: Kirigami.Units.smallSpacing

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.smallSpacing
                    spacing: Kirigami.Units.smallSpacing

                    Kirigami.Icon {
                        source: "gps"
                        width: Kirigami.Units.iconSizes.smallMedium
                        height: width
                        color: Kirigami.Theme.highlightColor
                    }

                    Label {
                        Layout.fillWidth: true
                        text: display_name
                        elide: Text.ElideRight
                    }
                }

                onClicked: {
                    dialog.selectedLatitude = parseFloat(lat)
                    dialog.selectedLongitude = parseFloat(lon)
                    dialog.cityPhoton = ubication
                    ready()
                    dialog.close()
                }
            }
        }

        Label {
            width: parent.width
            visible: searchField.text.length > 2 && resultsModel.count === 0
            text: i18n("No locations found")
            horizontalAlignment: Text.AlignHCenter
            opacity: 0.5
            font.italic: true
        }
    }

    ListModel { id: resultsModel }

    function searchLocations(query) {
        var url = "https://photon.komoot.io/api/?q=" + encodeURIComponent(query)
        var xhr = new XMLHttpRequest()
        xhr.open("GET", url)
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var data = JSON.parse(xhr.responseText)
                    resultsModel.clear()
                    for (var i = 0; i < data.features.length; i++) {
                        var feature = data.features[i]
                        var city = feature.properties.city || ""
                        var textUbication = feature.properties.city || feature.properties.county || feature.properties.state || feature.properties.name
                        var country = feature.properties.country || ""
                        var displayName = feature.properties.name + (city ? ", " + city : "") + (country ? ", " + country : "")
                        resultsModel.append({
                            display_name: displayName,
                            lat: feature.geometry.coordinates[1],
                            lon: feature.geometry.coordinates[0],
                            ubication: textUbication
                        })
                    }
                    resultsView.height = Math.min(resultsModel.count * Kirigami.Units.gridUnit*2.5, Kirigami.Units.gridUnit*16)
                    dialog.height = resultsView.height + searchField.implicitHeight + 30
                }
            }
        }
        xhr.send()
    }
}


