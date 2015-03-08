function [zero_frequencies_kHz,zero_frequencies_index,plots] = ...
    Algorithm_1(signal,...
                time_cutoff_ms,...
                acor_time_cutoff_ms,...
                lp_flag,...
                LP_ORDER,...
                threshold,...
                fs,...
                FFT_LENGTH,...
                log_flag,...
                plot_flag)
           
%--------------------------------------------------------------------------------------------------- 
%This function returns the frequencies of the pinna spectral notches.
%--------------------------------------------------------------------------------------------------- 
% Author     :     Vikas.C.Raykar 
% Date       :     25 May 2004
% Contact    :     vikas@umiacs.umd.edu
%--------------------------------------------------------------------------------------------------- 
%REFERENCE :
%--------------------------------------------------------------------------------------------------- 
% Extracting frequencies of the pinna spectral notches in measured head related impulse responses 
% Vikas C. Raykar, Ramani Duraiswami, and B. Yegnanarayana, University of Maryland CollegePark, 
% Department of Computer Science Technical Report, CS-TR-4609, July 2004 
% (also published as UMIACS-TR-2004-51).
%--------------------------------------------------------------------------------------------------- 
% EXAMPLE USAGE : See the script Algorithm_1_driver.m
%--------------------------------------------------------------------------------------------------- 

%--------------------------------------------------------------------------------------------------- 
% INPUT :
%--------------------------------------------------------------------------------------------------- 
% signal                : The time domain HRIR signal. 
%
%   Determine the initial onset of the HRIR and use the HRIR from that instant. 
%   The onset is available for the CIPIC database. Use the function 
%   get_CIPIC_HRIR_onset.m to retrive the onset time.
%   [onset]=get_CIPIC_HRIR_onset(subject_id,pinna,elev,azim,freq_kHz);
%   signal=HRIR(onset:end)
%
% time_cutoff_ms        : Size of the Hann window in ms. 
%
%   The torso and the knee reflections are cutoff by this window. A value of
%   1.0 ms is sufficient if the HRIR is used from the initial onset. Else
%   use a value of initial onset+1.0 ms. 
%
% acor_time_cutoff_ms  : Size of the window for windowing the autocorrelation fucntion.
%
%   Use a value of around 1.0-2.0 ms.
%
% lp_flag              : if 1 the analysis is done on the LP residual
% LP_ORDER             : Order for LP analysis (10-12)
%
%   The script has the option of not using LP analysis. However LP analysis
%   is recommended.
%
% threshold            : threshold for the group delay function (0 to -1)
%
%   Using the zero threshold for the group delay function, all valleys below the zero value
%   are marked as relevant notches and their frequencies are noted. In practice a slightly
%   lower threshold of -1 was found to give good results and eliminate any spurious nulls
%   by windowing.
%
% fs                   : Sampling frequency in kHz 
% FFT_LENGTH           : length of the FFT in samples 
% log_flag             : if 1 the spectrum magnitude is in dB
% plot_flag            : if 1 the results are plotted
%
%--------------------------------------------------------------------------------------------------- 
% OUTPUT :
%--------------------------------------------------------------------------------------------------- 
% zero_frequencies_kHz   : Frequencies of the pinna spectral notches in kHz.
%
% zero_frequencies_index : The corresponding  frequency index.
%
%   frequency=[0:fs/FFT_LENGTH:fs/2];
%   zero_frequencies_kHz=frequency(zero_frequencies_index);
%
% plots                  : A structure containing various intermediate results.
%--------------------------------------------------------------------------------------------------- 
% ALGORITHM
%--------------------------------------------------------------------------------------------------- 
% 1. Get residual signal from Linear Prediction. 
% 2. Window the signal using a Hann window.
% 3. Find the autocorrelation fucntion of the windowed signal.
% 4. Window the autocorrealtion function.
% 5. Find the the group-delay of the windowed autocorrelation signal.
% 6. Find local minima in the thresholded group delay.
%--------------------------------------------------------------------------------------------------- 



%----------------------------------------------------------------------
% Frequency and time axis
%----------------------------------------------------------------------

N=length(signal);
frequency=[0:fs/FFT_LENGTH:fs/2];
time=[0:1/(fs):(N-1)/(fs)];

%----------------------------------------------------------------------
% Make a copy of the original signal for plotting purposes
%----------------------------------------------------------------------

original_signal=signal;

%----------------------------------------------------------------------
% Spectrum of the original signal
%----------------------------------------------------------------------

original_signal_spectrum=abs(fft(signal,FFT_LENGTH));
original_signal_spectrum=original_signal_spectrum(1:(FFT_LENGTH/2)+1);

if log_flag == 1
    original_signal_spectrum=20*log10(original_signal_spectrum);
end

%----------------------------------------------------------------------
% Linear Prediction Aanalysis
%----------------------------------------------------------------------

if lp_flag == 1
    
    LP_coefficients=lpc(signal,LP_ORDER);
    LP_residual=real(filter(LP_coefficients',1,signal));
    signal=LP_residual;
    
end

%----------------------------------------------------------------------
% Spectrum of the signal
%----------------------------------------------------------------------

signal_spectrum=abs(fft(signal,FFT_LENGTH));
signal_spectrum=signal_spectrum(1:(FFT_LENGTH/2)+1);

if log_flag == 1
    signal_spectrum=20*log10(signal_spectrum);
end

%----------------------------------------------------------------------
% Hanning Window
%----------------------------------------------------------------------

M=round(time_cutoff_ms*fs);
win=zeros(2*N-1,1);
win(N-M+1:N+M-1)=window(@hann,2*M-1);
win=win(N:end);

%----------------------------------------------------------------------
% Window the signal
%----------------------------------------------------------------------

win_signal=signal.*win;

%----------------------------------------------------------------------
%Spectrum of the windowed signal
%----------------------------------------------------------------------

win_signal_spectrum=abs(fft(win_signal,FFT_LENGTH));
win_signal_spectrum=win_signal_spectrum(1:(FFT_LENGTH/2)+1);

if log_flag == 1
    win_signal_spectrum=20*log10(win_signal_spectrum);
end

%----------------------------------------------------------------------
% Autocorrelation of the windowed signal
%----------------------------------------------------------------------

win_signal_acor=xcorr(win_signal);

%----------------------------------------------------------------------
% Spectrum of the  autocorrelation signal
%----------------------------------------------------------------------

win_signal_acor_spectrum=abs(fft(win_signal_acor,FFT_LENGTH));
win_signal_acor_spectrum=win_signal_acor_spectrum(1:(FFT_LENGTH/2)+1);

if log_flag == 1
   win_signal_acor_spectrum=10*log10(win_signal_acor_spectrum);
end

%----------------------------------------------------------------------
% Autocorrelation window
%----------------------------------------------------------------------

M=round(acor_time_cutoff_ms*fs);
awin=zeros(2*N-1,1);
awin(N-M+1:N+M-1)=window(@hann,2*M-1);

%----------------------------------------------------------------------
% Window the autocorrelation fucntion
%----------------------------------------------------------------------

win_signal_acor_win=(win_signal_acor.*awin);
awin=awin(N:end);

%----------------------------------------------------------------------
% Spectrum of the windowed autocorrelation signal
%----------------------------------------------------------------------

win_signal_acor_win_spectrum=abs(fft(win_signal_acor_win,FFT_LENGTH));
win_signal_acor_win_spectrum=win_signal_acor_win_spectrum(1:(FFT_LENGTH/2)+1);

if log_flag == 1
   win_signal_acor_win_spectrum=10*log10(win_signal_acor_win_spectrum);
end

%----------------------------------------------------------------------
% Group delay of the windowed autocorrelation signal
%----------------------------------------------------------------------

win_signal_acor_win=win_signal_acor_win(N:end);
win_signal_acor=win_signal_acor(N:end);

grp_delay=grpdelay(win_signal_acor_win,1,FFT_LENGTH,'whole');
grp_delay=grp_delay(1:(FFT_LENGTH/2)+1);

%----------------------------------------------------------------------
% Zero threshold the group delay 
%----------------------------------------------------------------------
zero_threshold_grp_delay=grp_delay;
zero_threshold_grp_delay(find(zero_threshold_grp_delay > threshold))=0;

%----------------------------------------------------------------------
% Find the local minima in the group delay function
%----------------------------------------------------------------------

[lmval,indd]=lmin(zero_threshold_grp_delay,0);

zero_frequencies_kHz=frequency(indd);
zero_frequencies_index=indd;

%----------------------------------------------------------------------
% Return the intermediate results to the structure plots
%----------------------------------------------------------------------

plots.frequency=frequency;
plots.time=time;
plots.original_signal=original_signal;
plots.original_signal_spectrum=original_signal_spectrum;
plots.signal=signal;
plots.signal_spectrum=signal_spectrum;
plots.win=win;
plots.win_signal=win_signal;
plots.win_signal_spectrum=win_signal_spectrum;
plots.win_signal_acor=win_signal_acor;
plots.win_signal_acor_spectrum=win_signal_acor_spectrum;
plots.awin=awin;
plots.win_signal_acor_win=win_signal_acor_win;
plots.win_signal_acor_win_spectrum=win_signal_acor_win_spectrum;
plots.grp_delay=grp_delay;
plots.zero_threshold_grp_delay=zero_threshold_grp_delay;


if plot_flag==1
    
    figure;
    K=6;
    L=2;
    
    %-----------------------------------------
    
    subplot(K,L,1);
    plot(time,original_signal);
    axis([time(1) time(end) -1 1]);
    h=ylabel('(a)');
    set(h,'rotation',0);
    legend('Signal');
   
   
   %-----------------------------------------
    
    subplot(K,L,3);
    plot(time,signal);
    axis([time(1) time(end) -1 1]);
   hold on;
    plot(time,win*max(signal),'r:');
    h=ylabel('(b)');
    set(h,'rotation',0);
    legend('LP residual');

    
    %-----------------------------------------
    
    subplot(K,L,5);
    plot(time,win_signal);
    axis([time(1) time(end) -1 1]);
    h=ylabel('(c)');
    set(h,'rotation',0);
    legend('Windowed LP residual');

  
    %-----------------------------------------
    
    subplot(K,L,7);
    plot(time,win_signal_acor);
    axis([time(1) time(end) -1 1]);
    hold on;
    plot(time,awin*max(win_signal_acor),'r:');
        h=ylabel('(d)');
       set(h,'rotation',0);
           legend('Autocorrelation');


    %-----------------------------------------
    
    subplot(K,L,9);
    plot(time,win_signal_acor_win);
    axis([time(1) time(end) -1 1]);
    xlabel('Time (ms)');
        h=ylabel('(e)');
       set(h,'rotation',0);
    legend('Windowed Autocorrelation');
 
       
    %-----------------------------------------
    
    subplot(K,L,2);
    plot(frequency,original_signal_spectrum);
    axis([frequency(1) frequency(end) min(original_signal_spectrum) max(original_signal_spectrum)]);
        h=ylabel('(f)');
       set(h,'rotation',0);
    title('Corresponding Spectrum Magnitude');
        
    %-----------------------------------------
    
    subplot(K,L,4);
    plot(frequency,signal_spectrum);
    axis([frequency(1) frequency(end) min(signal_spectrum) max(signal_spectrum)]);
        h=ylabel('(g)');
       set(h,'rotation',0);

        
    %-----------------------------------------
    
    subplot(K,L,6);
    plot(frequency,win_signal_spectrum);
    axis([frequency(1) frequency(end) min(win_signal_spectrum) max(win_signal_spectrum)]);
        h=ylabel('(h)');
       set(h,'rotation',0);

        
    %-----------------------------------------
    
    subplot(K,L,8);
    plot(frequency,win_signal_acor_spectrum);
   axis([frequency(1) frequency(end) min(win_signal_acor_spectrum) max(win_signal_acor_spectrum)]);
       h=ylabel('(i)');
       set(h,'rotation',0);

        
    %-----------------------------------------
    
    subplot(K,L,10);
    plot(frequency,win_signal_acor_win_spectrum);
    h=ylabel('dB');
    axis([frequency(1) frequency(end) min(win_signal_acor_win_spectrum) max(win_signal_acor_win_spectrum)]);
        h=ylabel('(j)');
             set(h,'rotation',0);

    
    %-----------------------------------------
    hold on;
    subplot(K,L,12);
    plot(frequency,grp_delay);
    xlabel('Frequency (kHz)');
    hold on;
    axis([frequency(1) frequency(end) min(grp_delay) max(grp_delay) ]);
    hold on;
    plot(zero_frequencies_kHz,grp_delay(zero_frequencies_index),'r.');
    h=ylabel('(k)');
    hold on;
    plot(frequency,threshold*ones(size(frequency)),'b:');
    set(h,'rotation',0);
    title('Group Delay');

    
       
end

