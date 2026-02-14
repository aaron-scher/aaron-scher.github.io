# Digital Signal Processing

Welcome to the Digital Signal Processing (DSP) tutorial collection. These hands-on labs and tutorials cover fundamental DSP concepts including discrete-time systems, convolution, filtering, and frequency analysis using MATLAB.

## Available Tutorials

### [DSP Lab 3: Discrete Time Systems and Convolution](dsp-lab3-convolution.md)

Comprehensive lab exploring LTI systems, convolution, and practical filtering applications:

- **Convolution Sum**: Understanding and applying the fundamental DSP operation
- **Moving Average Filters**: Simple yet effective smoothing filters
- **FIR Filter Design**: Designing optimal finite impulse response filters
- **Biomedical Signals**: Filtering intracranial pressure (ICP) data
- **Audio Processing**: Noise reduction, decimation, and secret message recovery
- **Sampling & Decimation**: Data compression and resampling

**Topics:** Convolution, LTI systems, FIR filters, MATLAB, audio processing, biomedical signals

**Difficulty:** Intermediate

**Estimated Time:** 4-6 hours (complete lab)

## What You'll Learn

Across all DSP tutorials, you'll master:

✅ **Discrete-Time Signals**: Sampling, quantization, representation
✅ **LTI System Theory**: Impulse response, convolution, stability
✅ **Filter Design**: FIR, IIR, frequency response
✅ **Frequency Analysis**: DTFT, DFT, FFT
✅ **MATLAB Programming**: Signal processing toolbox
✅ **Real-World Applications**: Audio, biomedical, communications

## Essential DSP Concepts

### Time Domain

**Discrete-Time Signals**:
- Sequences: $x[n]$ where $n$ is an integer
- Sampling: Converting continuous-time to discrete-time
- Common sequences: impulse $\delta[n]$, step $u[n]$, exponential

**Linear Time-Invariant (LTI) Systems**:
- **Linearity**: $T\{ax_1[n] + bx_2[n]\} = aT\{x_1[n]\} + bT\{x_2[n]\}$
- **Time-Invariance**: If $x[n] \rightarrow y[n]$, then $x[n-k] \rightarrow y[n-k]$
- **Impulse Response**: $h[n] = T\{\delta[n]\}$ completely characterizes LTI system

**Convolution**:
$$y[n] = x[n] * h[n] = \sum_{k=-\infty}^{\infty} x[k]h[n-k]$$

### Frequency Domain

**Discrete-Time Fourier Transform (DTFT)**:
$$X(e^{j\omega}) = \sum_{n=-\infty}^{\infty} x[n]e^{-j\omega n}$$

**Discrete Fourier Transform (DFT)**:
$$X[k] = \sum_{n=0}^{N-1} x[n]e^{-j2\pi kn/N}, \quad k = 0, 1, \ldots, N-1$$

**Fast Fourier Transform (FFT)**:
- Efficient algorithm for computing DFT
- Complexity: $O(N \log N)$ vs. $O(N^2)$ for DFT

## Filter Types

### FIR (Finite Impulse Response)

**Advantages:**
- ✅ Always stable
- ✅ Linear phase possible (no distortion)
- ✅ Simple to design
- ✅ Finite duration impulse response

**Disadvantages:**
- ❌ Higher order required for sharp cutoff
- ❌ More computational cost

**Common FIR Filters:**
- Moving average
- Windowed sinc
- Parks-McClellan (equiripple)

### IIR (Infinite Impulse Response)

**Advantages:**
- ✅ Sharper cutoff with lower order
- ✅ More efficient (fewer coefficients)
- ✅ Analog filter equivalents (Butterworth, Chebyshev, Elliptic)

**Disadvantages:**
- ❌ Can be unstable if poles outside unit circle
- ❌ Nonlinear phase (distortion)
- ❌ More sensitive to coefficient quantization

## MATLAB Essentials

### Signal Generation

```matlab
% Time vector
n = 0:999;                  % 1000 samples
fs = 1000;                  % Sampling frequency
t = n / fs;                 % Time in seconds

% Sinusoid
f = 10;                     % Frequency (Hz)
x = sin(2*pi*f*t);

% Add noise
noise = randn(size(x));     % Gaussian white noise
x_noisy = x + 0.5*noise;
```

### Convolution

```matlab
% Define signals
x = [1, 2, 3, 4, 5];
h = [0.25, 0.5, 0.25];      % Simple filter

% Convolve
y = conv(x, h);             % Length: length(x) + length(h) - 1
y = conv(x, h, 'same');     % Same length as x
y = conv(x, h, 'valid');    % Only valid (no zero-padding)
```

### Filter Design

```matlab
% FIR low-pass filter
order = 100;
cutoff = 0.1;               % Normalized frequency (0 to 1)
b = fir1(order, cutoff);    % Filter coefficients

% Apply filter (causal)
y = filter(b, 1, x);

% Apply filter (zero-phase, non-causal)
y = filtfilt(b, 1, x);
```

### Frequency Analysis

```matlab
% Compute FFT
X = fft(x);                 % Complex spectrum
X_mag = abs(X);             % Magnitude spectrum
X_phase = angle(X);         % Phase spectrum

% Frequency vector
N = length(x);
f = (0:N-1) * (fs/N);       % Frequency bins

% Plot spectrum
plot(f, X_mag);
xlabel('Frequency (Hz)');
ylabel('Magnitude');
```

### Audio Processing

```matlab
% Load audio
[y, fs] = audioread('audio.wav');

% Play audio
soundsc(y, fs);             % Auto-scale volume

% Decimate (downsample with anti-aliasing)
y_dec = decimate(y, 2);     % Reduce by factor of 2

% Resample (rational factor)
y_res = resample(y, 3, 4);  % Multiply by 3/4
```

## Applications of DSP

### Audio Processing
- **Noise Reduction**: Filtering unwanted noise
- **Equalization**: Frequency shaping for music
- **Compression**: MP3, AAC encoding
- **Effects**: Reverb, echo, pitch shifting

### Communications
- **Modulation/Demodulation**: AM, FM, PSK, QAM
- **Channel Equalization**: Removing channel distortion
- **Error Correction**: Coding and decoding
- **Synchronization**: Timing and carrier recovery

### Biomedical Signals
- **ECG Processing**: Heart rate variability, arrhythmia detection
- **EEG Analysis**: Brain-computer interfaces, seizure detection
- **Medical Imaging**: CT, MRI reconstruction

### Radar & Sonar
- **Pulse Compression**: Improving range resolution
- **Doppler Processing**: Velocity measurement
- **Beamforming**: Directional signal enhancement

### Image Processing
- **Filtering**: Smoothing, sharpening, edge detection
- **Transform Coding**: JPEG compression
- **Enhancement**: Contrast, color correction

## Software Tools

### MATLAB (Commercial)
- **Pros**: Industry standard, extensive toolboxes, excellent documentation
- **Signal Processing Toolbox**: Core DSP functions
- **Communications Toolbox**: Modulation, coding
- **Audio Toolbox**: Audio I/O, analysis

### GNU Octave (Free)
- **Pros**: MATLAB-compatible, open source
- **Cons**: Some toolboxes missing, slower
- [Download Octave](https://www.gnu.org/software/octave/)

### Python (Free)
- **NumPy**: Array operations
- **SciPy**: Scientific computing, signal processing
- **Matplotlib**: Plotting
- **LibROSA**: Audio analysis

```python
import numpy as np
from scipy import signal
import matplotlib.pyplot as plt

# Create signal
t = np.linspace(0, 1, 1000)
x = np.sin(2*np.pi*10*t)

# Design filter
b, a = signal.butter(4, 0.1)

# Filter signal
y = signal.filtfilt(b, a, x)
```

## Recommended Textbooks

### Undergraduate Level
- **Oppenheim & Schafer**, *Discrete-Time Signal Processing* - Classic, comprehensive
- **Proakis & Manolakis**, *Digital Signal Processing* - Practical focus
- **Lyons**, *Understanding Digital Signal Processing* - Intuitive explanations

### Graduate Level
- **Hayes**, *Statistical Digital Signal Processing and Modeling*
- **Sayed**, *Adaptive Filters*
- **Rabiner & Gold**, *Theory and Application of Digital Signal Processing*

## Online Resources

### Learning Platforms
- [MIT OpenCourseWare - Signals and Systems](https://ocw.mit.edu/courses/res-6-007-signals-and-systems-spring-2011/)
- [DSP Guide by Steven W. Smith](http://www.dspguide.com/) - Free online book
- [Julius O. Smith's Books](https://ccrma.stanford.edu/~jos/) - Free DSP books

### Interactive Tools
- [Seeing Circles, Sines and Signals](https://jackschaedler.github.io/circles-sines-signals/) - Visual DSP
- [Desmos DSP Demos](https://www.desmos.com/) - Interactive graphs

### Communities
- [DSP Stack Exchange](https://dsp.stackexchange.com/)
- [comp.dsp Newsgroup](https://groups.google.com/g/comp.dsp)

## Additional Lab Topics (Coming Soon)

- **Lab 1**: Working with Signals in MATLAB
- **Lab 2**: Sampling and Aliasing
- **Lab 4**: DTMF Tone Generator
- **Lab 5**: DTMF Detector (Dual-Tone Multi-Frequency)
- **Frequency Analysis**: DTFT, DFT, FFT
- **IIR Filter Design**: Butterworth, Chebyshev, Elliptic
- **Adaptive Filtering**: LMS, RLS algorithms
- **Spectral Estimation**: Periodogram, Welch method

## Tips for Success

!!! tip "Mastering DSP"
    1. **Understand Sampling Theorem**: Foundation of all DSP
    2. **Visualize in Both Domains**: Time and frequency
    3. **Practice MATLAB**: Hands-on experience is key
    4. **Work Through Examples**: Don't just read, compute!
    5. **Verify Analytically**: Compare MATLAB results with theory
    6. **Build Intuition**: Understand physical meaning of equations

---

*DSP tutorials prepared by Dr. Aaron Scher, Dr. Mateo Aboy, and Dr. Joel Sprunger, Oregon Institute of Technology*
