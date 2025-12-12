import QtQuick
import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami as Kirigami

Item {
    id: main

    property int sectionWidth: 350
    property int sectionHeight: 170
    property bool widgetExpanded: root.expanded

    Layout.preferredWidth: sectionWidth + Kirigami.Units.gridUnit
    Layout.preferredHeight: sectionHeight + Kirigami.Units.gridUnit
    clip: false
    Layout.minimumWidth: sectionWidth + Kirigami.Units.gridUnit
    Layout.minimumHeight: sectionHeight + Kirigami.Units.gridUnit
    Layout.maximumWidth: minimumWidth
    Layout.maximumHeight: minimumHeight

    property var sections: [mainWeatherView, hourlyForecastView, dailyForecastView]
    property int currentIndex: 0

    Connections {
        target: weatherData
        function onDataChanged() {
            Qt.callLater(function() {
                if (hourlyForecastView.status === Loader.Ready) {
                    var hourlyItem = hourlyForecastView.item
                    if (hourlyItem && hourlyItem.updateStartIndex) {
                        hourlyItem.updateStartIndex()
                    }
                }
            })
        }
    }
    onWidgetExpandedChanged: {
        if (!widgetExpanded) {
            currentIndex = 0
        }
    }
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Header {
            id: header
            Layout.preferredHeight: Kirigami.Units.gridUnit
            Layout.fillWidth: true
            headerText: weatherData.city

            onNext: currentIndex = (currentIndex + 1) % sections.length
            onPrev: currentIndex = (currentIndex - 1 + sections.length) % sections.length
        }
        
        Loader {
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceComponent: sections[currentIndex]
        }
    }

    Component { 
        id: mainWeatherView
        MainView {}
    }
    Component { 
        id: hourlyForecastView
        HourlyForecast {}
    }
    Component { 
        id: dailyForecastView
        DailyForecast {}
    }
}

