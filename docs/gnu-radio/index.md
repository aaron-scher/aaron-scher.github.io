# GNU Radio & Software Defined Radio

Welcome to the GNU Radio and Software Defined Radio (SDR) tutorial collection. These tutorials demonstrate practical implementation of digital communication systems using GNU Radio Companion and affordable SDR hardware.

## Available Tutorials

### [BPSK Audio Modem](bpsk-audio-modem.md)

Build a working BPSK modulator/demodulator using only your computer's audio hardware:

- **Binary Phase-Shift Keying**: Fundamental digital modulation
- **Audio-Based Transmission**: Speakers → microphone wireless link
- **Complete Modem**: Both transmitter and receiver in one flow graph
- **TCP Socket Communication**: Real-time text messaging
- **Carrier Synchronization**: PLL and timing recovery

**Topics:** BPSK, modulation, demodulation, GNU Radio, software radio, acoustic modem

**Difficulty:** Intermediate

**Estimated Time:** 1-1.5 hours

## What is GNU Radio?

GNU Radio is a free, open-source software development toolkit for building software-defined radios and signal processing systems.

**Key Features:**
- ✅ **Visual Programming**: Flow graph editor (GNU Radio Companion)
- ✅ **Extensive Block Library**: Modulation, filtering, synchronization
- ✅ **Hardware Support**: USRP, HackRF, RTL-SDR, PlutoSDR, and more
- ✅ **Real-Time Processing**: Live signal generation and analysis
- ✅ **Python/C++ Backend**: Custom block development

## Software Defined Radio (SDR)

### What is SDR?

Traditional radios implement modulation, filtering, and demodulation in hardware. **SDR** implements these functions in **software**, providing:

- **Flexibility**: Change modulation schemes without hardware changes
- **Upgradability**: Add features via software updates
- **Multi-Function**: One device, many applications
- **Education**: Visualize signals and algorithms in real-time

### SDR Hardware

#### Entry-Level ($20-$100)

**RTL-SDR**
- **Frequency**: 24 MHz - 1.7 GHz (receive only)
- **Bandwidth**: Up to 3.2 MHz
- **Best For**: Learning, FM radio, ADS-B, NOAA satellites
- **Cost**: ~$25
- [RTL-SDR.com](https://www.rtl-sdr.com/)

**AirSpy R2**
- **Frequency**: 24 MHz - 1.8 GHz (receive only)
- **Bandwidth**: Up to 10 MHz
- **Better Dynamic Range** than RTL-SDR
- **Cost**: ~$100

#### Intermediate ($100-$500)

**HackRF One**
- **Frequency**: 1 MHz - 6 GHz (full duplex)
- **Bandwidth**: Up to 20 MHz
- **Transmit**: Yes! Half-duplex
- **Best For**: Experimentation, transmit applications
- **Cost**: ~$300
- [Great Scott Gadgets](https://greatscottgadgets.com/hackrf/)

**LimeSDR Mini**
- **Frequency**: 10 MHz - 3.5 GHz
- **Bandwidth**: Up to 30.72 MHz
- **Transmit**: Yes, full duplex
- **Cost**: ~$159

**ADALM-Pluto (PlutoSDR)**
- **Frequency**: 325 MHz - 3.8 GHz (hackable to 70 MHz - 6 GHz)
- **Bandwidth**: Up to 20 MHz
- **Best For**: Education, DSP learning (Analog Devices provides excellent tutorials)
- **Cost**: ~$100-150
- [Analog Devices PlutoSDR](https://www.analog.com/en/design-center/evaluation-hardware-and-software/evaluation-boards-kits/adalm-pluto.html)

#### Advanced ($700-$8000+)

**USRP B200/B210 (Ettus Research)**
- **Frequency**: 70 MHz - 6 GHz
- **Bandwidth**: Up to 56 MHz
- **Professional Performance**
- **Best For**: Research, commercial development
- **Cost**: $700-$2200

## GNU Radio Companion (GRC)

### Flow Graph Structure

GNU Radio applications consist of **flow graphs**:

```
Source → Signal Processing → Sink
```

**Basic Blocks:**

- **Sources**: Generate or receive signals
  - Signal Source (sine, square, sawtooth)
  - File Source (read from file)
  - Audio Source (microphone)
  - RTL-SDR Source (receive RF)

- **Processing**: Transform signals
  - Filters (low-pass, high-pass, band-pass)
  - Modulators (AM, FM, PSK, QAM)
  - Demodulators
  - Math operations (+, ×, conjugate)

- **Sinks**: Output or transmit signals
  - Audio Sink (speakers)
  - File Sink (save to file)
  - Qt GUI Sinks (plots, scopes, constellation)
  - HackRF Sink (transmit RF)

### Example Flow Graph

**FM Radio Receiver:**

```
RTL-SDR Source → Low Pass Filter → WBFM Receive → Audio Sink
      ↓
  Frequency Xlating FIR Filter (tune to station)
```

## Digital Modulation Schemes

### Phase Shift Keying (PSK)

**BPSK (Binary PSK)**:
- 2 phase states: 0°, 180°
- 1 bit per symbol
- Most robust against noise

**QPSK (Quadrature PSK)**:
- 4 phase states: 0°, 90°, 180°, 270°
- 2 bits per symbol
- Higher data rate than BPSK

**8-PSK**:
- 8 phase states
- 3 bits per symbol
- Used in satellite communications

### Amplitude Shift Keying (ASK)

**OOK (On-Off Keying)**:
- Simplest ASK: carrier on/off
- Used in remote controls, RFID

### Frequency Shift Keying (FSK)

**Binary FSK**:
- Two frequencies represent 0 and 1
- Used in caller ID, older modems

### Quadrature Amplitude Modulation (QAM)

**16-QAM, 64-QAM, 256-QAM**:
- Both amplitude and phase varied
- High spectral efficiency
- Used in WiFi, cable modems, 4G/5G

## Signal Processing Concepts

### Filters

**Low-Pass Filter (LPF)**:
- Passes low frequencies, attenuates high
- Used for channel selection, anti-aliasing

**Band-Pass Filter (BPF)**:
- Passes frequencies in a range
- Used for selecting specific channels

**Root-Raised Cosine (RRC)**:
- Pulse shaping filter
- Minimizes inter-symbol interference (ISI)

### Synchronization

**Carrier Synchronization**:
- **Costas Loop**: Recovers carrier frequency and phase (PSK)
- **PLL (Phase-Locked Loop)**: Tracks carrier

**Symbol Timing Recovery**:
- **Mueller & Müller**: Timing recovery for PSK
- **Clock Recovery MM**: General-purpose timing sync

**Frame Synchronization**:
- **Correlation**: Detect known preamble/sync word
- **Schmidl & Cox**: OFDM timing synchronization

### Visualization

**Time Domain**:
- **Time Sink**: Waveform over time
- **Eye Diagram**: Visualize ISI and jitter

**Frequency Domain**:
- **Frequency Sink (FFT)**: Spectrum analyzer
- **Waterfall Sink**: Time-frequency plot

**Constellation Diagram**:
- I/Q plot showing symbol locations
- Visualize modulation quality

## Common GNU Radio Applications

### Communication

- **Analog FM/AM Radio**: Broadcast reception
- **Digital Voice**: DMR, D-STAR, P25
- **Packet Radio**: AX.25, APRS
- **Satellite Communications**: Weather satellites (NOAA, Meteor-M), amateur satellites

### Monitoring

- **ADS-B**: Aircraft tracking
- **AIS**: Ship tracking
- **Pagers**: Numeric/alphanumeric paging
- **ISM Bands**: Garage openers, tire pressure sensors

### Experimentation

- **Custom Modems**: Design your own modulation
- **Radar**: Passive radar using broadcast signals
- **Radio Astronomy**: Hydrogen line (1420 MHz)
- **RFID**: Reader/writer for LF/HF tags

## Installation

### Linux (Recommended)

```bash
# Ubuntu/Debian
sudo apt-get install gnuradio

# Fedora
sudo dnf install gnuradio

# Or build from source for latest version
```

### macOS

```bash
# Using Homebrew
brew install gnuradio
```

### Windows

- Download installer from [GNU Radio Downloads](https://www.gnuradio.org/releases/)
- Or use **radioconda** (recommended, includes Python ecosystem)

## Learning Resources

### Official Documentation

- [GNU Radio Wiki](https://wiki.gnuradio.org/)
- [GNU Radio Tutorials](https://wiki.gnuradio.org/index.php/Tutorials)
- [Guided Tutorials](https://wiki.gnuradio.org/index.php/Guided_Tutorial_GRC)

### Online Courses

- [Software Defined Radio with HackRF (Coursera)](https://www.coursera.org/learn/software-defined-radio)
- [Michael Ossmann's SDR Lessons](https://greatscottgadgets.com/sdr/)

### Books

- **Michael Ossmann & Dominic Spill**, *Software Defined Radio with HackRF One*
- **Robin Getz et al.**, *Software-Defined Radio for Engineers* (Analog Devices)
- **Rick Lyons**, *Understanding Digital Signal Processing*

### YouTube Channels

- [The Signal Path](https://www.youtube.com/user/TheSignalPathBlog)
- [Great Scott Gadgets](https://www.youtube.com/user/michaelossmann)
- [RTL-SDR.com](https://www.youtube.com/c/RTLSDRBlog)

## Example Projects

### Beginner

- **FM Radio Receiver**: Tune to local FM stations
- **NOAA Weather Satellite Images**: Receive and decode APT images
- **ADS-B Aircraft Tracker**: Plot aircraft on a map
- **Morse Code Decoder**: Receive and decode CW

### Intermediate

- **BPSK/QPSK Modem**: Digital data communication
- **Packet Radio**: Send/receive AX.25 packets
- **DTMF Decoder**: Decode telephone tones
- **Spectrum Analyzer**: Build a full-featured analyzer

### Advanced

- **LTE Signal Analysis**: Decode cellular signals
- **Passive Radar**: Detect aircraft using FM broadcast reflections
- **Direction Finding**: Locate transmitters using phase/TDOA
- **Custom Protocol**: Design and implement your own PHY layer

## Additional Tutorials (Coming Soon)

From the full GNU Radio collection:

- **2PAM Modulation**: Pulse amplitude modulation
- **HackRF Tutorials**: Transmit and receive with HackRF One
- **RTLSDR Examples**: Using cheap RTL dongles
- **Frequency Hopping**: Spread spectrum techniques
- **OFDM**: Orthogonal Frequency Division Multiplexing
- **Packet Radio**: Frame synchronization and error detection

## Community & Support

- [GNU Radio Mailing List](https://lists.gnu.org/mailman/listinfo/discuss-gnuradio)
- [GNU Radio Slack](https://gnuradio.slack.com/)
- [r/RTLSDR](https://www.reddit.com/r/RTLSDR/)
- [r/amateursatellites](https://www.reddit.com/r/amateursatellites/)

## Legal Considerations

!!! warning "Transmission Regulations"
    - **Listen First**: Most jurisdictions allow reception of public signals
    - **Transmit Carefully**: Requires license in most countries
      - Amateur Radio License (HAM): Specific bands and power limits
      - ISM Bands: 433 MHz, 915 MHz (region-dependent), 2.4 GHz, 5.8 GHz
    - **Respect Regulations**: FCC (USA), Ofcom (UK), etc.
    - **Stay in ISM/Amateur Bands**: Don't interfere with licensed services

---

*GNU Radio tutorials prepared by Dr. Aaron Scher, Oregon Institute of Technology*
