% This script starts the MIDI demo, generating sound from MIDI keyboard
% input.
%
% Tucker McClure @ The MathWorks
% Copyright 2012 The MathWorks, Inc.

%% Clean up.
close all; clear all; clear classes; clc;

%% Configuration

sample_rate       = 48000;     % [samples/sec]
frame_size        = 256;       % [samples]
output_device     = 'Default'; % (Default, ASIO4ALL v2, Traktor Audio 2)
num_inputs        = 0;
num_outputs       = 2;

% Select a MIDI device.
[success, midi_input_device] = midi_interface('open');
if success
    midi_interface('close');
else
    fprintf('No MIDI devices selected. Cannot continue.\n');
    return;
end

% Turn off warnings about dropped samples.
warning off dsp:system:toAudioDeviceDroppedSamples;

%% Execution

% Create the processor with a number of input channels, number of output
% channels, sample rate, frame size, and device name.
rtap = MidiDemo(num_inputs, ...
                num_outputs, ...
                sample_rate, ...
                frame_size, ...
                midi_input_device, ...
                output_device);

% Play. This will start *immediately* and block until all audio output is
% complete.
rtap.Play();

% Release the audio resource for others (be nice).
rtap.release();

% The RTAP records some timing values while playing. Show the results.
rtap.Analyze();
