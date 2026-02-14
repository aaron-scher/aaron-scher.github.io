# DSP Lab 3: Discrete Time Systems and Convolution

**Authors:** Mateo Aboy, Aaron Scher, and Joel Sprunger
*Oregon Institute of Technology*

!!! info "Lab Materials"
    This lab was developed based on coursework for EE 430. It provides hands-on experience with discrete-time systems, convolution, and digital filtering using MATLAB.

## Objectives

The objective of this lab is to investigate discrete time systems using the concepts of impulse response and convolution to introduce digital filtering. Students will:

- Understand Linear Time-Invariant (LTI) systems
- Apply the convolution sum to filter signals
- Explore moving average and FIR filters
- Work with real biomedical and audio signals
- Understand sampling, decimation, and data compression

## Introduction: The Convolution Sum

### Discrete Time Systems

A discrete time system can be modeled mathematically as a transform, function, or operator $T$ that processes an input sequence $x[n]$ and produces an output sequence $y[n]$:

$$y[n] = T\{x[n]\}$$

### Linear Time-Invariant (LTI) Systems

**Linear systems** obey the principle of superposition:

$$T\{a_1x_1[n] + a_2x_2[n]\} = a_1T\{x_1[n]\} + a_2T\{x_2[n]\}$$

**Time-invariant systems** produce time-shifted outputs for time-shifted inputs:

- If $x[n] \rightarrow y[n]$, then $x[n-n_0] \rightarrow y[n-n_0]$

!!! success "Why LTI Systems Matter"
    LTI systems are important in practice because there is a well-developed mathematical theory for analysis and design. They are (usually) much easier to solve and characterize compared to nonlinear systems.

### Complete Characterization via Impulse Response

An LTI system can be **completely characterized** by its impulse response $h[n]$:

1. Apply unit impulse: $\delta[n]$
2. Record output: $h[n]$
3. Use convolution to find output for any input!

### The Convolution Sum

Once we have $h[n]$, we can find the output for an arbitrary input using:

$$y[n] = T\{x[n]\} = \sum_{k=-\infty}^{\infty} x[k]h[n-k] = \sum_{k=-\infty}^{\infty} x[n-k]h[k]$$

This is the **linear convolution sum**, denoted:

$$y[n] = x[n] * h[n] = h[n] * x[n]$$

## Example: Low-Pass Filter (Moving Average)

### Problem Setup

We create a noisy signal:

- **Desired signal**: 10 Hz sinusoid
- **Sampling rate**: $f_s = 300$ Hz
- **Noise**: Zero-mean, unit-variance Gaussian noise

### Filter Design

We use a simple **moving average filter**:

$$h[n] = \frac{1}{8}(u[n] - u[n-8])$$

This impulse response equals $\frac{1}{8}$ for $n = 0, 1, 2, \ldots, 7$ and zero elsewhere.

### Filtering Operation

Applying convolution:

$$y[n] = \sum_{k=-\infty}^{\infty} x[n-k]h[k] = \frac{1}{8}\sum_{k=0}^{7} x[n-k]$$

Expanded form:

$$y[n] = \frac{1}{8}(x[n] + x[n-1] + x[n-2] + \cdots + x[n-7])$$

This is a **finite impulse response (FIR) filter** of order 7.

### Results

![Filtered Signal](assets/dsp-lab3/dsp_3_filtered.png)
**Figure 1:** Moving average filter smoothing a noisy sinusoid

**Observations:**

- ✅ Output is less noisy than input
- ✅ Filter improves signal-to-noise ratio (SNR)
- ⚠️ Output is a delayed version of input (group delay)
- 📊 Frequency components above cutoff are attenuated

!!! note "Moving Average = Low-Pass Filter"
    The moving average filter acts as a low-pass filter, attenuating high-frequency noise while preserving low-frequency signal content.

## Lab Tasks

### Part I: Intracranial Pressure (ICP) Signal Filtering

#### Task 1.1: Load and Plot ICP Data

[📥 Download: ICPComposite.mat](assets/dsp-lab3/ICPComposite.mat)

```matlab
% Load ICP signal
load('ICPComposite.mat');  % Variable: icpcomposite
fs = 125;  % Sampling frequency (Hz)

% Plot time domain signal
t = (0:length(icpcomposite)-1) / fs;
figure;
plot(t, icpcomposite);
xlabel('Time (s)');
ylabel('ICP (mmHg)');
title('Intracranial Pressure Signal');
grid on;
```

#### Task 1.2: Moving Average Filters of Different Orders

Filter the ICP signal with moving average filters of orders 2, 10, 20, and 200:

```matlab
% Define moving average filter coefficients
order2 = ones(1,3) / 3;          % Order 2: [1/3, 1/3, 1/3]
order10 = ones(1,11) / 11;       % Order 10
order20 = ones(1,21) / 21;       % Order 20
order200 = ones(1,201) / 201;    % Order 200

% Apply filters using convolution
y2 = conv(icpcomposite, order2, 'same');
y10 = conv(icpcomposite, order10, 'same');
y20 = conv(icpcomposite, order20, 'same');
y200 = conv(icpcomposite, order200, 'same');

% Plot results
figure;
subplot(4,1,1); plot(t, y2);   title('Order 2');
subplot(4,1,2); plot(t, y10);  title('Order 10');
subplot(4,1,3); plot(t, y20);  title('Order 20');
subplot(4,1,4); plot(t, y200); title('Order 200');
xlabel('Time (s)');
```

**Discussion Questions:**

- How does increasing filter order affect the output?
- What is the trade-off between smoothness and delay?
- At what order does the signal become "too smooth"?

#### Task 1.3: Compare `filter` vs `filtfilt`

```matlab
% Using filter (causal)
y_filter = filter(order20, 1, icpcomposite);

% Using filtfilt (zero-phase, non-causal)
y_filtfilt = filtfilt(order20, 1, icpcomposite);

figure;
subplot(2,1,1); plot(t, y_filter);   title('filter()');
subplot(2,1,2); plot(t, y_filtfilt); title('filtfilt()');
```

!!! question "Is filtfilt Causal?"
    **No!** `filtfilt` applies the filter forward and backward, resulting in zero phase shift but requiring access to future samples. This makes it **non-causal** and unsuitable for real-time applications.

#### Task 1.4: Design Custom FIR Filter

Design an FIR filter to make the ICP signal as sinusoidal as possible:

```matlab
% Design low-pass FIR filter
order = 100;
cutoff = 0.05;  % Normalized frequency (0 to 1)
b = fir1(order, cutoff);

% Apply filter
y_fir = filtfilt(b, 1, icpcomposite);

figure;
plot(t, y_fir);
title('Your Name - Sinusoidal ICP');
xlabel('Time (s)');
ylabel('ICP (mmHg)');
```

#### Task 1.5: Remove DC Component (Trend)

```matlab
% Method 1: Using detrend
y_detrend = detrend(icpcomposite);

% Method 2: Manual DC removal
dc_value = mean(icpcomposite);
y_no_dc = icpcomposite - dc_value;

figure;
plot(t, y_detrend);
title('ICP with DC Component Removed');
xlabel('Time (s)');
ylabel('ICP (mmHg)');
```

### Part II: Audio Signal Fun

#### Task 2.1: Load and Play Audio

[📥 Download: test_audio.mat](assets/dsp-lab3/test_audio.mat)

```matlab
% Load audio file
load('test_audio.mat');  % Variable: y
fs = 44100;  % Sampling rate (Hz)

% Play audio at normal speed
soundsc(y, fs);

% Plot waveform
t = (0:length(y)-1) / fs;
figure;
plot(t, y);
xlabel('Time (s)');
ylabel('Amplitude');
title('Audio Waveform');
```

!!! warning "Volume Warning"
    Before playing audio, turn down your speaker/headphone volume!

#### Task 2.2: Effect of Sampling Rate

```matlab
% Play at half sampling rate
soundsc(y, fs/2);  % 22050 Hz
```

**Questions:**

- How does the audio sound different?
- What happens in the frequency domain when you halve the sampling rate?
- Why does the voice sound deeper/slower?

!!! info "Frequency Domain Effect"
    Lowering the sampling rate without resampling causes aliasing and shifts all frequencies down by a factor of 2, making voices sound deeper and slower.

#### Task 2.3: Proper Decimation

```matlab
% Decimate by factor of 2
g = decimate(y, 2);

% Play decimated signal at correct rate
soundsc(g, fs/2);

% Compare file sizes
whos y g  % Check bytes
```

**Questions:**

- Does the decimated signal sound the same as the original?
- How much memory is saved?

$$\text{Memory Savings} = \left(1 - \frac{\text{size of } g}{\text{size of } y}\right) \times 100\%$$

#### Task 2.4: Maximum Decimation Factor

```matlab
% Try different decimation factors
decimation_factors = [2, 3, 5, 10, 20];

for factor = decimation_factors
    g = decimate(y, factor);
    fprintf('Decimation factor: %d\n', factor);
    soundsc(g, fs/factor);
    pause(3);  % Wait before next playback
end
```

**Find the maximum decimation factor** where you can still understand the message!

#### Task 2.5: Downsample vs Decimate

```matlab
% Downsample (no filtering)
y_down = downsample(y, 2);

% Decimate (with anti-aliasing filter)
y_decim = decimate(y, 2);

% Compare
soundsc(y_down, fs/2);  pause(3);
soundsc(y_decim, fs/2);
```

**Key Differences:**

| Function | `downsample` | `decimate` |
|----------|--------------|------------|
| **Anti-aliasing filter** | No | Yes (built-in lowpass filter) |
| **Speed** | Faster | Slower |
| **Quality** | May have aliasing | Prevents aliasing |
| **Use case** | When signal is already bandlimited | General resampling |

**Rational Decimation (3/7):**

```matlab
% Resample by rational factor 3/7
y_rational = resample(y, 3, 7);
soundsc(y_rational, fs*3/7);
```

#### Task 2.6: Recover Secret Message from Noisy Audio

[📥 Download: very_noisy_signal.mat](assets/dsp-lab3/very_noisy_signal.mat)

```matlab
% Load very noisy signal
load('very_noisy_signal.mat');  % Variable: z

% Play noisy signal (turn down volume!)
soundsc(z, fs);  % Sounds like terrible hiss!
```

**Task:** Filter out high-frequency noise to reveal the secret message.

**Attempt 1: Moving Average Filter**

```matlab
% Try different orders
orders = [10, 50, 100, 200, 500];

for order = orders
    h = ones(1, order+1) / (order+1);
    z_filtered = conv(z, h, 'same');
    fprintf('Order: %d\n', order);
    soundsc(z_filtered, fs);
    pause(5);
end
```

**Attempt 2: FIR Low-Pass Filter (Recommended)**

```matlab
% Design FIR low-pass filter
filter_order = 100;
cutoff_freq = 0.1;  % Normalized (0.1 * fs/2 = 0.1*44100/2 = 2.205 kHz)

% Create filter coefficients
b = fir1(filter_order, cutoff_freq);

% Filter the noisy signal
z_clean = conv(z, b, 'same');

% Play filtered signal
soundsc(z_clean, fs);

% Plot comparison
figure;
subplot(2,1,1);
plot(z); title('Noisy Signal');
subplot(2,1,2);
plot(z_clean); title('Filtered Signal');
```

!!! success "Reveal the Secret"
    With proper filtering, you should be able to hear and understand the secret message! Write it down verbatim in your report.

## Key Concepts Summary

### Convolution Properties

- **Commutative**: $x[n] * h[n] = h[n] * x[n]$
- **Associative**: $(x[n] * h_1[n]) * h_2[n] = x[n] * (h_1[n] * h_2[n])$
- **Distributive**: $x[n] * (h_1[n] + h_2[n]) = x[n] * h_1[n] + x[n] * h_2[n]$

### Filter Types

**FIR (Finite Impulse Response):**
- ✅ Always stable
- ✅ Linear phase possible
- ✅ No feedback
- ❌ Higher order required for sharp cutoff

**IIR (Infinite Impulse Response):**
- ✅ Sharper cutoff with lower order
- ✅ More efficient
- ❌ Can be unstable
- ❌ Nonlinear phase

### MATLAB Functions

| Function | Purpose | Causal? |
|----------|---------|---------|
| `conv` | Linear convolution | Yes |
| `filter` | Filter with delay | Yes |
| `filtfilt` | Zero-phase filtering | No |
| `fir1` | Design FIR filter | N/A (design only) |
| `decimate` | Downsample with filtering | Yes |
| `downsample` | Downsample without filtering | Yes |
| `resample` | Rational resampling | Yes |

## Downloadable Resources

- [📥 ICP Composite Signal (ICPComposite.mat)](assets/dsp-lab3/ICPComposite.mat)
- [📥 Test Audio (test_audio.mat)](assets/dsp-lab3/test_audio.mat)
- [📥 Very Noisy Signal (very_noisy_signal.mat)](assets/dsp-lab3/very_noisy_signal.mat)

## Further Reading

!!! tip "Next Topics"
    After mastering convolution and FIR filters, the next topics to explore are:

    - **DTFT (Discrete-Time Fourier Transform)**: Frequency domain analysis
    - **DFT/FFT**: Efficient computation of frequency spectra
    - **Filter Design**: Optimal filter coefficient selection
    - **IIR Filters**: Recursive filters with infinite impulse response
    - **Spectral Analysis**: Power spectral density, periodogram

## References

1. J. Sprunger and M. Aboy, *Computer Explorations in DSP Laboratory 3 - Discrete Time Systems and Convolution*, prepared for EE 430, Oregon Institute of Technology, 2013.
2. Oppenheim & Schafer, *Discrete-Time Signal Processing* (textbook)
3. MATLAB Signal Processing Toolbox Documentation

---

*Lab created January 2016 | Updated for modern context February 2026*
