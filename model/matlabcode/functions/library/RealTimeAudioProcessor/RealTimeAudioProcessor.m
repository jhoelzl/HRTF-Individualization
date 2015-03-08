% RealTimeAudioProcessor
%
% The RealTimeAudioProcessor object allows the user to process consecutive
% frames of audio in real-time (it lags real-time by the frame size plus 
% hardware overhead). The object can easily be extended for any type of
% audio processing by overloading the stepImpl method in a derived class.
%
% Use:
%
% % Create the processor with a number of input channels, number of output
% % channels, sample rate, frame size, and device name.
% rtap = RealTimeAudioProcessor(1, 2, 48000, 256, 'Default');
% 
% % Play. This will start *immediately* and block until all audio output is
% % complete.
% rtap.Play();
% 
% % Release the audio resource for others (be nice).
% rtap.release();
% 
% % The RTAP records some timing values while playing. Show the results.
% rtap.Analyze();
% 
% It is recommended that an ASIO audio driver with appropriate hardware be
% used for the audio interface. (ASIO is an open standard from Steinberg
% Media Technologies GmbH).
%
% Tucker McClure @ The MathWorks
% Copyright 2012 The MathWorks, Inc.

classdef RealTimeAudioProcessor < matlab.system.System

    properties (Nontunable, Access = protected)
        
        % Settings
        frame_size   = 128;   % Number of samples in the buffer
        sample_rate  = 48000; % Number of samples per second [samples/s]
        end_time     = inf;   % Number of seconds until playback stops [s]
        in_channels  = 2;     % Number of input channels
        out_channels = 2;     % Number of output channels
        device_name  = 'Default';
        draw_rate    = 0.02;  % Rate to update graphics [s]

        % Derived quantities
        time_step;   % Length of frame [s]
        time_window; % Array of time values from [0 time_step) [s]
        
        % Device interfaces
        ap; % AudioPlayer object to manage output
        ar; % AudioRecorder object to manage input

    end
    
    properties
        
        % UI handles
        figure_handle; % Handle of UI figure
        text_handle;   % Handle of text in figure
        
        samples_until_draw = 0; % Samples left before updating GUI
        
        % Analysis stuff
        max_in_step_time      = 0;
        max_process_step_time = 0;
        max_out_step_time     = 0;
        
    end
    
    methods
        
        % Constructor; creates the RTAP and its internal dsp.AudioPlayer.
        % After creation, the RTAP is ready to play.
        function rtap = RealTimeAudioProcessor(ins, outs, Fs, w, device)
            
            fprintf('Initializing a RealTimeAudioProcessor on %s... ', ...
                    device);
            
            % Set some internals.
            rtap.frame_size   = w;
            rtap.sample_rate  = Fs;
            rtap.in_channels  = ins;
            rtap.out_channels = outs;
            rtap.device_name  = device;
                        
            % Calculate the period.
            rtap.time_step = w/Fs;
            
            % Create all the time values for a window.
            rtap.time_window = (0:w-1)'/Fs;

            % Ok, we set everything up.
            fprintf('done.\n');
            
            % Display latency to user.
            fprintf('Minimum latency due to buffering: %5.1fms\n', ...
                    1000 * rtap.time_step);

        end
        
        % Enter a quasi-real-time loop in which audio is acquired/generated
        % and plugged into the output buffer (if a buffer exists).
        function Play(rtap)
                        
            % If not set up, setup.
            if ~rtap.isLocked
                
                setup(rtap, ...
                      zeros(rtap.frame_size, 1), ...
                      zeros(rtap.frame_size, rtap.in_channels));
                  
            % Otherwise, if we need a new figure, open one.
            elseif ~ishandle(rtap.figure_handle)
                
                rtap.GenerateFigure();
                
            end
            
            % Keep track of time since 'tic'.
            t_clock = 0;
            
            % Keep track of how much material we've played since 'tic'.
            % At t_clock, this should reach to t_clock + time_step.
            t_played = 0;
            
            % Initialize the input.
            in = zeros(rtap.frame_size, rtap.in_channels); %#ok<NASGU>
            
            % Start a timer.
            tic();
            
            % Loop until the end time has been reached or the figure has
            % been closed.
            while t_clock < rtap.end_time && ishandle(rtap.figure_handle)
                
                % Play steps until we're |buffer| into the future.
                if t_played < t_clock + rtap.time_step

                    % Create the times for this frame.
                    time = t_played + rtap.time_window;
                    
                    % Get the input for one frame.
                    if rtap.in_channels > 0
                        step_timer = tic();
                        in = step(rtap.ar);
                        rtap.max_in_step_time = ...
                            max(rtap.max_in_step_time, toc(step_timer));
                    else
                        in = zeros(rtap.frame_size, rtap.in_channels);
                    end
                    
                    % Process one frame.
                    step_timer = tic();
                    out = step(rtap, time, in);
                    rtap.max_process_step_time = ...
                        max(rtap.max_process_step_time, toc(step_timer));
                    
                    % Step the AudioPlayer. Time the step for analysis
                    % purposes.
                    if rtap.out_channels > 0
                        step_timer = tic();
                        step(rtap.ap, out);
                        rtap.max_out_step_time = ...
                            max(rtap.max_out_step_time, toc(step_timer));
                    end
                    
                    % Update the time.
                    t_played = t_played + rtap.time_step;
                    
                end
                
                % Release focus so that figure callbacks can occur.
                if rtap.samples_until_draw <= 0
                    drawnow();
                    rtap.UpdateGraphics();
                    rtap.samples_until_draw = ...
                        rtap.sample_rate * rtap.draw_rate;
                else
                    rtap.samples_until_draw = ...
                        rtap.samples_until_draw - rtap.frame_size;
                end
                
                % Update the clock.
                t_clock = toc();
                
            end
            
            % Wait for audio to end before exiting. We may have just
            % written out a frame, and there may have already been a frame
            % in the buffer, so chill for 2 frames.
            pause(2*rtap.time_step);
            
        end
        
        % Display timing results from last play.
        function Analyze(rtap)
            fprintf(['Results for last play:\n', ...
                     'Maximum input step time:   %5.1fms\n', ...
                     'Maximum process step time: %5.1fms\n', ...
                     'Maximum output step time:  %5.1fms\n'], ...
                    1000*rtap.max_in_step_time, ...  
                    1000*rtap.max_process_step_time, ...  
                    1000*rtap.max_out_step_time);
        end
        
    end
    
    methods (Access = protected)

        % Set up the internal System Objects and the figure.
        function setupImpl(rtap, ~, ~)

            % Create the AudioPlayer.
            if rtap.out_channels > 0
                
                rtap.ap = dsp.AudioPlayer(...
                    'DeviceName',       rtap.device_name, ...
                    'BufferSizeSource', 'Property', ...
                    'BufferSize',       rtap.frame_size, ...
                    'QueueDuration',    0, ...
                    'SampleRate',       rtap.sample_rate);
                
                
                % Start with silence. This initializes the AudioPlayer to
                % the window size and number of channels and takes longer
                % than any subsequent call will take.
                step(rtap.ap, zeros(rtap.frame_size, rtap.out_channels));

            end
            
            % Create the AudioRecorder (if requested).
            if rtap.in_channels > 0
                
                rtap.ar = dsp.AudioRecorder(...
                    'DeviceName',       'Default', ...
                    'SampleRate',       rtap.sample_rate, ...
                    'BufferSizeSource', 'Property', ...
                    'BufferSize',       rtap.frame_size, ...
                    'SamplesPerFrame',  rtap.frame_size, ...
                    'QueueDuration',    0, ...
                    'OutputDataType',   'double', ...
                    'NumChannels',      rtap.in_channels);
                
                % Initialize the input.
                step(rtap.ar);
            
            end
            
            if ishandle(rtap.figure_handle)
                close(rtap.figure_handle);
            end
            rtap.GenerateFigure();
            
            % Draw it.
            drawnow();
            
            % Chill out for a second before rushing forward with sound.
            pause(rtap.time_step);
            
        end
        
        % Process one frame of audio, given the inputs corresponding to the
        % frame and the times.
        function out = stepImpl(rtap, time, in) %#ok<INUSD>
            out = zeros(rtap.frame_size, rtap.out_channels);
        end
        
        % Specify that the step requires 2 inputs.
        function n = getNumInputsImpl(~)
            n = 2;
        end
        
        % Specify that the step requires 1 output.
        function n = getNumOutputsImpl(~)
            n = 1;
        end
        
        % Clean up the AudioPlayer.
        function releaseImpl(rtap)
            
            % Release the dsp.AudioPlayer resource.
            if rtap.out_channels > 0
                release(rtap.ap);
            end
            
            % Release the dsp.AudioRecorder too.
            if rtap.in_channels > 0
                release(rtap.ar);
            end
            
            % Close the figure if it's still open.
            if ishandle(rtap.figure_handle)
                set(rtap.text_handle, 'String', 'Closing.');
                close(rtap.figure_handle);
                rtap.figure_handle = [];
            end
            
        end
        
        % Generate a figure that stays open with updates for the user.
        % Closing this figure ends playback.
        function GenerateFigure(rtap)
            
            % Get the screen dimensions for centering the figure.
            screen_dims = get(0, 'ScreenSize');
            figure_width_height = [640 160];
            figure_dims = [floor(0.5*(  screen_dims(3:4) ...
                                      - figure_width_height)) ...
                           figure_width_height];
                       
            % Generate a figure.
            rtap.figure_handle = figure(...
                'Name',          'Real-Time Audio Processor Controller',...
                'NumberTitle',   'off', ...
                'Position',      figure_dims);
            axes('Position', [0 0 1 1], ...
                 'Visible', 'off');
            rtap.text_handle = text(0.5, 0.5, ...
                'Real Time Audio Processor is active.', ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment',   'middle', ...
                'Interpreter',         'none');
             
        end
        
        function UpdateGraphics(rtap) %#ok<*MANU>
        end
        
    end
    
end
