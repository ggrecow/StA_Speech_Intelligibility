function [SpeechWhiteNoise, TimeVector, fs] = GenerateSpeechWhiteNoise(insig, Desired_SPL_speech, SNR, plot_figs, save_figs, fig_sound_nametag, figures_dir, save_sound, sound_dir)
%
% function [SpeechWhiteNoise, TimeVector, fs] = GenerateSpeechWhiteNoise(insig, Desired_SPL_speech, SNR, plot_figs, save_figs, fig_sound_nametag, figures_dir, save_sound, sound_dir)
%
% 1) load speech signal
%    - compute signal's length, time vector, and compute SPL based on the
%      rms value of the entire signal's length
%
% 2) calibrate SPL of the signal based to a desired_SPL. This is desired
%    because we want that all speech signals have the same level for
%    comparison reasons
%
% 3) generate white noise with same time vector as the input speech signal
%    and calibrate it according to a desired SNR from the level of the
%    speech signal
%
% 4) generate the speech + white noise signal
%
% 5) plot the signals in time and frequency domain (optional)
%
% 6) save the signals in a desired folder (optional)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% INPUTS
%   insig : string
%           - path of input speech signal
%
%   Desired_SPL_speech : scalar
%           - desired level, in dB spl, to calibrate the input speech signal
%
%   SNR : scalar
%           - desired signal-to-noise ratio (i.e. difference between the speech and noise amplitudes)
%
%   plot_figs : boolean
%           - option to plot the figures (1=yes and 0=no)
%
%   save_figs : boolean
%           - option to save the figures (1=yes and 0=no)
%
%   fig_sound_nametag : string
%           - string with the tagname which the figures and sound file will be saved with
%
%   figures_dir : string
%           - string with the folder where the figures shall be saved
%
%   save_sound : boolean
%           - option to save the generated sound file (1=yes and 0=no)
%
%   sound_dir : string
%           - string with the folder where the sound file shall be saved
%
% OUTPUTS
%   SpeechWhiteNoise : [N,1] vector
%           - generated sound file
%
%  TimeVector : [N,1] vector
%           - time vector of the generated file
%
%  fs : scalar
%           - sampling frequency of the generated file
%
%
%   Gil Felix Greco, Braunschweig 11.08.2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% load speech signal

[SpeechSignal,fs]=audioread(insig); % load speech signal

% calculate input signal time parameters
TotalLength = length(SpeechSignal) / fs;  % total time duration of the speech signal
dt=1/fs;                                  % time step
TimeVector = transpose(0:dt:TotalLength-dt);         % time vector

%% calibrate level of input speech signal

pref = 2e-5; % reference pressure

Input_SPL_speech = 20.*log10(rms(SpeechSignal)./pref); % SPL of speech signal based on the RMS values of the entire signal's length

Calibrated_SpeechSignal = SpeechSignal.*10.^((Desired_SPL_speech-Input_SPL_speech)/20);

SPL_Calibrated_SpeechSignal = 20.*log10(rms(Calibrated_SpeechSignal)./pref); % check SPl of the calibrated speech signal

%% generate white noise

WhiteNoise = randn(length(TimeVector),1); % white noise

%% calibrate level of the generated white noise based on the rms value of the speech and a desired SNR

WhiteNoise_levelIn = 20.*log10(rms(WhiteNoise)./pref); % SPL of the generated white noise

WhiteNoise_levelOut = SPL_Calibrated_SpeechSignal - SNR; % level of the white noise based on the SNR and the speech rms value

Calibrated_WhiteNoise = WhiteNoise.*10.^( (WhiteNoise_levelOut - WhiteNoise_levelIn) /20 );

%% generate speech + white noise signal

SpeechWhiteNoise = ones(length(TimeVector),1); % declaring variable for memory allocation
SpeechWhiteNoise = SpeechSignal + Calibrated_WhiteNoise;

%% plots (pressure over time, amplitude in linear scale)

if plot_figs == 1
    
    figure('name','Signals in time domain');
    h = gcf;
    set(h,'Units','Inches');
    pos = get(h,'Position');
    set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])   % necessary to save figs in pdf format in the correct page size
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plot loaded and calibrated speech signal
    subplot(3,1,1)
    
    plot(TimeVector,Calibrated_SpeechSignal);
    a=yline(rms(Calibrated_SpeechSignal),'r--');
    
    ylabel('Pressure, $p$ (Pa)','Interpreter','Latex');
    legend(a,sprintf( '$p_{\\mathrm{rms}}=%.2g$ (Pa) or SPL=%.2g (dB)',rms(Calibrated_SpeechSignal),20*log10(rms(Calibrated_SpeechSignal)/pref) ),'Location','NorthEast','Interpreter','Latex'); %legend boxoff
    
    title('Speech signal');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plot generated white noise
    subplot(3,1,2)
    
    plot(TimeVector,Calibrated_WhiteNoise);
    a=yline(rms(Calibrated_WhiteNoise),'r--');
    
    legend(a,sprintf( '$p_{\\mathrm{rms}}=%.2g$ (Pa) or SPL=%.2g (dB)',rms(Calibrated_WhiteNoise),20*log10(rms(Calibrated_WhiteNoise)/pref) ),'Location','NorthEast','Interpreter','Latex'); %legend boxoff
    
    ylabel('$p$ (Pa)','Interpreter','Latex');
    
    title(sprintf('Calibrated white noise (SNR=%g)',SNR));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plot generated (speech + white noise) signal
    subplot(3,1,3)
    
    plot(TimeVector,SpeechWhiteNoise);
    a=yline(rms(SpeechWhiteNoise),'r--');
    
    legend(a,sprintf( '$p_{\\mathrm{rms}}=%.2g$ (Pa) or SPL=%.2g (dB)',rms(SpeechWhiteNoise),20*log10(rms(SpeechWhiteNoise)/pref) ),'Location','NorthEast','Interpreter','Latex'); %legend boxoff
    
    ylabel('$p$ (Pa)','Interpreter','Latex');
    xlabel('Time, $t$ (s)','Interpreter','Latex');
    
    title('Speech signal + white noise');
    
    set(gcf,'color','w');
    
    if save_figs == 1
        
        figname_out = [figures_dir fig_sound_nametag];
        saveas(gcf,figname_out, 'fig');
        saveas(gcf,figname_out, 'pdf');
        saveas(gcf,figname_out, 'png');
        
        disp(sprintf('\n=========================================='));
        fprintf('Info about generated signal %s\n',fig_sound_nametag);
        fprintf('\nfigure %s was saved on disk\n\t(full name: %s)\n',fig_sound_nametag,figname_out);
        
    else
    end
    
else
end

%% save generated sound file

if save_sound == 1
    
    FileName=[sound_dir fig_sound_nametag '.wav'];
    audiowrite(FileName,SpeechWhiteNoise,fs,'BitsPerSample',16)
    fprintf('\nSound file %s was saved on disk\n\t(full name: %s)\n',fig_sound_nametag,FileName);
    disp(sprintf('==========================================\n'));
else
end

end