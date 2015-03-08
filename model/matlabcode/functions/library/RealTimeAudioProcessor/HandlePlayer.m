% HandlePlayer
% 
% This object stores the handle to an 'output' function, calling this 
% function with the current playback time, inputs, and state for every 
% frame.
% 
% This works best when a low-latency driver like an ASIO driver is used for
% output (under Preferences::DSP Toolbox).
%
% Tucker McClure @ The MathWorks
% Copyright 2012 The MathWorks, Inc.

classdef HandlePlayer < RealTimeAudioProcessor
    
    properties

        function_handle; % Handle of function to execute
        state; % User-provided state to pass to function
        
    end
    
    methods
        
        % Create the RTAP, add key callbacks for user input, and update the
        % text display. Then, we're ready to play.
        function rtap = HandlePlayer(handle, initial_state, ...
                ins, outs, Fs, w, device)

            % Call parent constructor.
            rtap = rtap@RealTimeAudioProcessor(ins, outs, Fs, w, device);
            
            fprintf('Initializing HandlePlayer... ');
            
            % Make sure the user gave us a decent handle.
            if ~isa(handle, 'function_handle')
                error('HandlePlayer:InvalidFunctionHandle', ...
                      'Invalid function handle provided to HandlePlayer.');
            end
            
            rtap.function_handle = handle;
            rtap.state = initial_state;
            
            % Lock everything to get ready to play.
            setup(rtap, zeros(w, 1), zeros(w, rtap.in_channels));
            
            fprintf('done.\n');
            
        end
        
    end
    
    methods (Access = protected)
        
        % Overload the output function. Process one frame of audio, given 
        % the inputs corresponding to the frame and the times.
        function out = stepImpl(rtap, time, in)
        
            [out, rtap.state] = rtap.function_handle(time, in, rtap.state);
            
        end
        
        function GenerateFigure(rtap)
            
            % Call the parent's version.
            GenerateFigure@RealTimeAudioProcessor(rtap);
            
            % Update the text display.
            if ~isempty(rtap.function_handle)
                set(rtap.text_handle, 'String', ...
                    {'RealTimeAudioProcessor is active.'; ...
                     ''; ...
                     ['Streaming audio through ' ...
                      func2str(rtap.function_handle) '.']});
            end
            
        end
        
    end
    
end
