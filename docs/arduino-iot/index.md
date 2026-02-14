# Arduino & IoT

Welcome to the Arduino and Internet of Things tutorial collection. These tutorials cover WiFi communication, sensor interfacing, and web-based control systems using Arduino platforms.

!!! note "Historical Context"
    Many of these tutorials were created for the Arduino Yun (2014-2015 era). While the Yun is now a legacy product, the concepts demonstrated—WiFi sensor monitoring, REST APIs, web interfaces—remain highly relevant and translate directly to modern IoT platforms.

## Available Tutorials

### [Arduino Yun WiFi Tutorial](arduino-yun-wifi.md)

A comprehensive guide to building a WiFi-enabled IoT system using the Arduino Yun:

- **Temperature & Humidity Monitoring** via DHT22 sensor
- **Remote LED Control** through web interface
- **REST API Implementation** for device communication
- **Bridge Library** usage for WiFi communication
- **Web Server** setup on Arduino

**Topics Covered:** WiFi configuration, web servers, sensor integration, REST APIs, IoT fundamentals

**Difficulty:** Intermediate

**Estimated Time:** 3-4 hours

## Modern Alternatives

For new projects in 2026, consider these modern alternatives to the Arduino Yun:

### ESP32/ESP32-C3/ESP32-C6
- **Pros:** Built-in WiFi/Bluetooth, dual-core, low cost, extensive libraries
- **Best For:** General IoT projects, battery-powered devices
- **Programming:** Arduino IDE, ESP-IDF, MicroPython

### Raspberry Pi Pico W
- **Pros:** WiFi capability, RP2040 dual-core, Python support
- **Best For:** Beginners, Python enthusiasts, education
- **Programming:** MicroPython, CircuitPython, C/C++

### Arduino MKR WiFi 1010
- **Pros:** Official Arduino, low power, crypto chip
- **Best For:** Arduino ecosystem users, secure IoT
- **Programming:** Arduino IDE

### Particle Photon 2
- **Pros:** Cloud integration, cellular options, enterprise-ready
- **Best For:** Commercial IoT deployments
- **Programming:** Arduino-like API, cloud IDE

## Key Concepts

Across all tutorials, you'll learn:

✅ **WiFi Communication**: Connecting devices to networks
✅ **Web Servers**: Hosting interfaces on microcontrollers
✅ **Sensor Integration**: Reading and processing sensor data
✅ **REST APIs**: Implementing lightweight communication protocols
✅ **Remote Control**: Building web-based control interfaces
✅ **IoT Architecture**: Understanding client-server relationships

## Prerequisites

**Hardware Knowledge:**
- Basic Arduino programming (setup, loop, digitalRead/Write)
- Understanding of circuits (resistors, LEDs, sensors)
- Familiarity with breadboarding

**Software Skills:**
- Arduino IDE basics
- HTML/JavaScript fundamentals (for web interfaces)
- Basic networking concepts (IP addresses, ports)

**Tools Needed:**
- Arduino IDE or compatible development environment
- Web browser
- Terminal/command prompt for network debugging
- (Optional) FTDI adapter for serial debugging

## Related Topics

### Expand Your IoT Knowledge

After completing these tutorials, explore:

- **MQTT Protocol**: Lightweight messaging for IoT
- **Cloud Integration**: AWS IoT, Google Cloud IoT, Azure IoT Hub
- **Security**: Encryption, authentication, secure boot
- **Edge Computing**: Local processing and AI on devices
- **LoRaWAN**: Long-range, low-power wireless communication
- **BLE (Bluetooth Low Energy)**: Short-range device communication
- **OTA Updates**: Over-the-air firmware updates

## Community Resources

- [Arduino Forum](https://forum.arduino.cc/)
- [ESP32 Community](https://esp32.com/)
- [Adafruit Learning System](https://learn.adafruit.com/)
- [Hackster.io IoT Projects](https://www.hackster.io/iot)
- [Home Assistant Community](https://community.home-assistant.io/)

## Recommended Hardware Suppliers

- [Adafruit](https://www.adafruit.com/) - Curated components, excellent documentation
- [SparkFun](https://www.sparkfun.com/) - Wide selection, tutorials
- [Seeed Studio](https://www.seeedstudio.com/) - Grove system, sensors
- [Digi-Key](https://www.digikey.com/) - Comprehensive catalog, fast shipping

---

*Tutorials prepared by Dr. Aaron Scher, Oregon Institute of Technology*
