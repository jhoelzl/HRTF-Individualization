% QwertyDemo
% 
% This is a real-time instrument derived from RealTimeAudioProdessor that
% uses the QWERTY keyboard as a musical keyboard and outputs audio. This
% works best when a low-latency driver like an ASIO driver is used for
% output (under Preferences::DSP Toolbox).
%
% Tucker McClure @ The MathWorks
% Copyright 2012 The MathWorks, Inc.

classdef QwertyDemo < RealTimeAudioProcessor
    
    properties

        % Playback stuff
        keys; % Logical array of keys currently down
        
    end

    properties (Constant = true)
        
        % Maps keys (values) to semitones (indices) above base frequency.
        % Here, a, s, d, f, g, h, j, k are the "white keys" with w, e, t,
        % y, u as the "black keys".
        key_map = 'awsedftgyhujk';
        
        % Maps semitone steps about base frequency to correct frequency.
        key_frequencies = 440 * 2 * pi * 2.^((0:12)/12);
        
    end
    
    methods
        
        % Create the RTAP, add key callbacks for user input, and update the
        % text display. Then, we're ready to play.
        function rtap = QwertyDemo(ins, outs, Fs, w, device)

            % Call parent constructor. Among other things, this creates the
            % figure and text handles we use and therefore must happen
            % first.
            rtap = rtap@RealTimeAudioProcessor(ins, outs, Fs, w, device);
            
            fprintf('Initializing QwertyDemo... ');
            
            % Make sure we can map the inputs to the outputs.
            if ins ~= 0 && ins ~= 1 && ins ~= outs
                error('QwertyDemo:AmbiguousMapping', ...
                      ['Ambiguous mapping from number of inputs to ' ...
                       'number of outputs.']);
            end
            
            % Initialize all the keys to off.
            rtap.keys = false(size(rtap.key_map));
            
            % Lock everything to get ready to play.
            setup(rtap, zeros(w, 1), zeros(w, rtap.in_channels));
            
            fprintf('done.\n');
            
        end

        % This function is called when a user presses a key in the figure.
        function KeyDownCallback(rtap, ~, event)
            
            % If a valid key has been pressed...
            if length(event.Key) == 1
                
                % Find it in the key map.
                key_pos = rtap.key_map == event.Character;
                
                % If it's there, record that key as 'down'.
                rtap.keys(key_pos) = true;
                
            % If user presses escape, panic and kill all 'down' notes.
            elseif strcmp(event.Key, 'escape')
                rtap.keys = false(size(rtap.keys));
            end
            
        end
        
        % This function is called when a user presses a key in the figure.
        function KeyUpCallback(rtap, ~, event)
            
            % If a valid key has been pressed...
            if length(event.Character) == 1
                
                % Find it in the key map.
                key_pos = rtap.key_map == event.Character;
                
                % If it's there, record that key as no longer 'down'.
                rtap.keys(key_pos) = false;
                
            end
            
        end

    end
    
    methods (Access = protected)
        
        function GenerateFigure(rtap)

            % Call the parent's version.
            GenerateFigure@RealTimeAudioProcessor(rtap);
            
            % Add key callbacks to figure.
            set(rtap.figure_handle, ...
                'KeyPressFcn',   @rtap.KeyDownCallback,...
                'KeyReleaseFcn', @rtap.KeyUpCallback);
            
            % Update the text display.
            set(rtap.text_handle, 'String', ...
                {'RealTimeAudioProcessor is active.'; ...
                 ''; ...
                 ['Play keys a-k as "white keys" and ' ...
                  'w, e, t, y, u as "black keys".']});
            drawnow();
            
        end
        
        % Overload the output function. Process one frame of audio, given 
        % the inputs corresponding to the frame and the times.
        function out = stepImpl(rtap, time, in)

            % Find all the frequencies we should be playing.
            freqs = rtap.key_frequencies(rtap.keys);
            
            % Try to map the inputs.
            if size(in, 2) == 1
                out = in * (0.1 * ones(1, rtap.out_channels));
            elseif size(in, 2) == rtap.out_channels
                out = 0.1 * in;
            else
                out = zeros(rtap.frame_size, rtap.out_channels);
            end

            % Otherwise, output the frequencies we should be playing plus
            % the input.
            if ~isempty(freqs)
            
                out =   out ...
                      +   sum(sin(time * freqs), 2)/length(freqs) ...
                        * ones(1, rtap.out_channels);
            
            end

            % Limit audio to [-1 1].
            out = min(1, max(-1, out));

        end
        
    end
    
end
