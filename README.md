# 🌤️ ApexOS Weather

**ApexOS Weather** is a compact weather widget for KDE Plasma with enhanced design and functionality.

## About This Fork

**ApexOS Weather** is a fork of **Freyry.Weather**, a compact weather widget for KDE Plasma.

This fork includes various improvements and customizations:
- **Enhanced card styling** — completely redesigned cards with theme integration for consistent appearance
- **Bug fixes and improvements** — fixed all errors, warnings, and configuration issues
- **Multi-language support** — translated to multiple languages (English, Russian, German, Spanish, French, Korean, Dutch, Polish, Portuguese, Turkish, Ukrainian, Chinese)
- **Design improvements** — enhanced UI/UX with better visual consistency
- **Code cleanup** — removed unnecessary comments and improved code quality

## ✨ Features

- Current weather with icon and temperature
- Hourly forecast
- Multi-day forecast
- Detailed information: wind speed, humidity, UV index, feels like temperature, and more
- Location search by coordinates
- Automatic location detection by IP
- Multiple customizable settings

## 🔧 Settings

- Font panel size
- Bold font
- 12-hour time format (AM/PM)
- Temperature units (Celsius/Fahrenheit)
- Wind speed units (km/h, m/s, mph)
- Selectable weather metrics
- Display options (icon only, temperature, conditions)

## 📦 Installation

Download the widget from Pling Store or install manually:

```bash
cd ~/.local/share/plasma/plasmoids/
git clone https://github.com/dmaliog/apexos-weather.git apexos-weather
```

Then restart Plasma or run:

```bash
kbuildsycoca5
killall plasmashell; kstart5 plasmashell
```

## 📝 Fork Modifications

This fork maintains compatibility with the original project while adding significant improvements:

- **Redesigned cards** — completely new card system with viewitem theme integration
- **Bug fixes** — fixed all errors, warnings, and configuration issues
- **Multi-language support** — added translations for 12+ languages
- **Design improvements** — enhanced UI/UX with better visual consistency
- **Code cleanup** — removed unnecessary comments and improved code quality
- **Better responsive layout** — improved layout responsiveness
- **Improved visual consistency** — better visual consistency across all elements

All modifications are made available under the same GPL-3.0-or-later license as the original project.

## Original Project

**Original Project:** Freyry.Weather  
**Original Author:** zayronxio (adolfo@librepixels.com)  
**Original Repository:** https://github.com/zayronxio/Freyry.Weather/  
**Original License:** GPL-3.0+

## 📄 License

This project is licensed under the **GNU General Public License v3.0 or later (GPL-3.0-or-later)**.

All files in this project are subject to the GPL-3.0-or-later license. See the [LICENSE](LICENSE) file for the full license text.

## 🙏 Acknowledgments

This fork is based on the excellent work by **zayronxio** and the original **Freyry.Weather** project. We thank the original author and all contributors for their work.

## 🔗 Links

- **Project Website:** https://apexos.ru/
- **Repository:** https://github.com/dmaliog/apexos-weather
- **Original Project:** https://github.com/zayronxio/Freyry.Weather
- **Original Author:** zayronxio (adolfo@librepixels.com)

---

*Version: 0.1.0*  
*Requires: Plasma 6.0+*
