% This script starts the HandlePlayer, which will pass audio inputs to a
% given function to process them and then pass this along to the output.
%
% Tucker McClure @ The MathWorks
% Copyright 2012 The MathWorks, Inc.

%% Clean up.
close all; clear all; clear classes; clc;

%% Configuration

sample_rate   = 48000; % [samples/sec]
frame_size    = 256;   % [samples]
output_device = 'Default'; % (Default, ASIO4ALL v2, Traktor Audio 2)
num_inputs    = 2;
num_outputs   = 2;
initial_state = [1; 0];

%% Execution

% Create the processor with a sample rate, frame size, and device name.
rtap = HandlePlayer(@sine_of_the_times, ...
                    initial_state, ...
                    num_inputs, ...
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
