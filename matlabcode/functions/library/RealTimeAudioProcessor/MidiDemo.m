% MidiDemo
% 
% This is a real-time instrument derived from RealTimeAudioProdessor that
% uses MIDI input to generate audio. This works best when a low-latency
% driver like an ASIO driver is used for output (under Preferences::DSP
% Toolbox).
%
% Tucker McClure @ The MathWorks
% Copyright 2012 The MathWorks, Inc.

classdef MidiDemo < RealTimeAudioProcessor
    
    properties

        % Playback stuff
        keys = false(1, 128); % Logical array of keys currently down
        magnitudes = zeros(1, 128); % Magnitudes of down keys
        
    end

    properties (Constant = true)
        
        % Maps semitone steps about base frequency to correct frequency.
        % MIDI note 69 is A4 at 440 Hz. This is not "well-tempered", but
        % we'll live.
        key_frequencies = 440 * 2 * pi * 2.^(((1:128) - 69)/12);
        
    end
    
    methods
        
        % Create the RTAP, add key callbacks for user input, and update the
        % text display. Then, we're ready to play.
        function rtap = MidiDemo(ins, outs, Fs, w, ...
                                 input_device, output_device)

            % Call parent constructor. Among other things, this creates the
            % figure and text handles we use and therefore must happen
            % first.
            rtap = rtap@RealTimeAudioProcessor(ins, outs, Fs, w, ...
                                               output_device);
            
            fprintf('Initializing MidiDemo.\n');
            
            % Set up the MIDI device (use the first device on the system);
            midi_interface('open', input_device);
            
        end

    end
    
    methods (Access = protected)
        
        % Overload the output function. Process one frame of audio, given 
        % the inputs corresponding to the frame and the times.
        function out = stepImpl(rtap, time, ~)

            % Check for MIDI input.
            msgs = midi_interface();
            for k = 1:size(msgs, 2)
                
                msg = msgs(1, k);
                
                % Key down (with velocity > 0)
                if msg == 144 && msgs(3, k) > 0
                    
                    key = msgs(2, k)+1;
                    rtap.keys(key) = true;
                    rtap.magnitudes(key) = msgs(3, k)/127;
                    
                % Key up
                elseif msg == 128 || (msg == 144 && msgs(3, k) <= 0)
                    
                    rtap.keys(msgs(2, k)+1) = false;
                    
                % Aftertouch (polyphonic)
                elseif msg == 160
                    msgs(3, k)
                    rtap.magnitude(key) = msgs(3, k)/127;
                    
                end
                
            end
            
            % Find all the frequencies we should be playing.
            freqs = rtap.key_frequencies(rtap.keys);
            mags  = rtap.magnitudes(rtap.keys);
                        
            % If there's nothing to play...
            if isempty(freqs)
                
                % Output silence.
                out = zeros(rtap.frame_size, rtap.out_channels);

            % Otherwise, generate some content.
            else
                
                % Initialize the mono output.
                out = zeros(rtap.frame_size, 1);
                
                % For each key down...
                for k = 1:length(freqs)
                    
                    % Generate a sine wave and saw wave.
                    dt = 2*pi/freqs(k);
                    saws = (2/dt * mod(time, dt) - 1);
                    sins = sin(time * freqs(k));
                    
                    % Aside from magnitude controlling volume level, let it
                    % also control frequency content, with higher magnitude
                    % yielding more high frequency content.
                    out = out + mags(k)*(mags(k)*saws + (1-mags(k))*sins);
                    
                end
                
                % Stereoize and gain.
                out = out * (0.5 * ones(1, rtap.out_channels));
                
            end
            
            % Limit audio to [-1 1].
            out = min(1, max(-1, out));
            
        end
        
        % Close the MIDI device and call parent's clean-up method.
        function releaseImpl(rtap)
            midi_interface('close');
            releaseImpl@RealTimeAudioProcessor(rtap);
        end
        
    end
    
end
