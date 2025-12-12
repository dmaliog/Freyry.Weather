
import QtQuick 2.0

import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
         name: i18n("General")
         icon: "kde"
         source: "ConfigGeneral.qml"
    }
    ConfigCategory {
        name: i18n("Weather Settings")
        icon: "weather"
        source: "WeatherConfig.qml"
    }
}
