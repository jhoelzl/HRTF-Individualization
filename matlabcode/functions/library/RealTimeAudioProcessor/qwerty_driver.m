% This script starts the qwerty demo, which generates sound from a user
% "playing" a qwerty keyboard.
%
% Tucker McClure @ The MathWorks
% Copyright 2012 The MathWorks, Inc.


%% Clean up.
close all; clear all; clear classes; clc;

%% Configuration

sample_rate   = 48000; % [samples/sec]
frame_size    = 128;   % [samples]
output_device = 'Default'; % (Default, ASIO4ALL v2, Traktor Audio 2)
num_inputs    = 0;
num_outputs   = 2;

%% Execution

% Create the processor with a sample rate, frame size, and device name.
rtap = QwertyDemo(num_inputs, ...
                  num_outputs, ...
                  sample_rate, ...
                  frame_size, ...
                  output_device);

% Play. This will start *immediately* and block until all audio output is
% complete.
rtap.Play();

% Release the audio resource for others (be nice).
rtap.release();

% The RTAP records some timing values while playing. Show the results.
rtap.Analyze();
