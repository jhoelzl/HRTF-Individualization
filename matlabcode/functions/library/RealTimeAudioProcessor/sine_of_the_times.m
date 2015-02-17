% [out, state_out] = sine_of_the_times(times, in, state_in)
% 
% This function works as a handle for the HandlePlayer object. Given a set
% of times, inputs, and a current state, it returns corresponding outputs
% and a final state. Here, the left output channel (channel 1) will be
% calculated as a sine wave of a certain frequency over the given time,
% while the right channel (channel 2) is calculated from the propagation of
% an input state over time (a simple harmonic oscillator). If you can't
% hear a difference between the left and right channels, then it's working!
%
% Tucker McClure @ The MathWorks
% Copyright 2012 The MathWorks, Inc.

function [out, state_out] = sine_of_the_times(times, in, state_in)

    % Frequency to use for sin and state transition matrix [rad/s]
    f = 440 * 2 * pi;
    
    % Create a sine wave directly.
    outL = sin(times * f);
    
    % Use a state space representation to create the dynamics we want.
    outR = zeros(length(times), 1);
    
    % Calculate the state transition matrix. Note that this happens every
    % time but is actually constant; this is therefore best suited to an
    % initialization routine. We could build therefore build an object
    % instead of using this 'handle' method. Alternately, we could have
    % precomputed constants passed to this function from an initialization
    % function.
    k_over_m = f^2;
    c_over_m = 0.1;
    A = [0 1; -k_over_m -c_over_m];
    dt = diff(times(1:2));
%     Phi = expm(A * dt); % Exact solution
    Phi = (eye(2) + 0.5*dt*A) / (eye(2) - 0.5*dt*A); % Bilinear transform
    
    % Propagate the state by discrete steps.
    state_out = state_in;
    for k = 1:length(times)
        state_out = Phi * state_out;
        outR(k, 1) = state_out(1);
    end
    
    % Build the final output with the left and right channels plus the
    % input.
    out = 0.5*[outL outR] + 0.1 * in;

end
