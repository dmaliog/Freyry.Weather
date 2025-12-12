import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: root

    signal configurationChanged

    QtObject {
        id: sizeFontPanel
        property int value
    }

    property alias cfg_sizeFontPanel: sizeFontPanel.value
    property alias cfg_fontBoldWeather: fontBoldWeather.checked
    property alias cfg_UseFormat12hours: amPm.checked
    property alias cfg_onlyIcon: onlyIcon.checked
    property alias cfg_showTemperatureWeather: showTemperatureWeather.checked
    property alias cfg_showConditionsWeather: showConditionsWeather.checked

    ScrollView {
        id: scrollView
        anchors.fill: parent
        clip: true

        ColumnLayout {
            width: scrollView.width
            spacing: Kirigami.Units.largeSpacing
            Layout.topMargin: Kirigami.Units.smallSpacing
            Layout.bottomMargin: Kirigami.Units.smallSpacing

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
                text: i18n("Font Settings")
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
                    id: size
                    Kirigami.FormData.label: i18n("Font Panel Size:")
                    model: ListModel {
                        Component.onCompleted: {
                            for (var i = 5; i <= 48; i++) {
                                append({ "text": i })
                            }
                        }
                    }
                    onActivated: sizeFontPanel.value = currentValue
                    Component.onCompleted: currentIndex = (sizeFontPanel.value - 5)
                }

                CheckBox {
                    id: fontBoldWeather
                    Kirigami.FormData.label: i18n("Font Bold")
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
                text: i18n("Display Options")
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
                    id: onlyIcon
                    Kirigami.FormData.label: i18n("Only Icon Weather")
                    onCheckedChanged: {
                        if (checked) {
                            showTemperatureWeather.checked = false
                            showConditionsWeather.checked = false
                        }
                    }
                }

                CheckBox {
                    id: showTemperatureWeather
                    enabled: !onlyIcon.checked
                    Kirigami.FormData.label: i18n("Show temperature weather")
                }

                CheckBox {
                    id: showConditionsWeather
                    enabled: !onlyIcon.checked
                    Kirigami.FormData.label: i18n("Show weather conditions")
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
                text: i18n("Time Format")
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
                    id: amPm
                    Kirigami.FormData.label: i18n("12-hour (AM/PM)")
                }
            }
        }
        }
    }
}
