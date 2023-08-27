% 
%   This code calls the 'GenerateSpeechWhiteNoise', which generates a 
%   speech sound filed contamined with white noise. The speech file is given
%   as input and calibrated to a desired level (dB SPL). The white noise is
%   generated with the same time legth as the input speech signal and a 
%   desired signal-to-noise ratio within the function.
%   
%   Please note that the approach adopted here computes all level and SNRs 
%   based on the entire time vector of the input signal. Ideally, 
%   this should be done within time blocks when the speech (and/or the noise)
%   is can be considered stationary. The block size which speech is 
%   considered to be stationary is usually 20ms long.
%
%   ACHTUNG: please add the 'StA_Speech_Intelligibility' folder with
%   subfolder to the MATLAB path if you want to use the current settings
%   for figure and sound file saving. Otherwise, just change the paths
%   manually according to your folder settings
%
%   Gil Felix Greco, Braunschweig 11.08.2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; close all; clear all;

%% inputs

% speech: 'The hogs were fed chopped corn and garbage.'
% source: \CD_Loizou\Databases\Speech\IEEE_corpus\wideband
insig = 'C:\Users\forst\OneDrive\Uni\Studienarbeit\StA_Speech_Intelligibility\signals\speech\S_01_08.wav'; % input signal

Desired_SPL_speech = 70; % desired level, in dB spl, to calibrate the input speech signal
SNR = [5 10 15 20];  % desired signal-to-noise ratio (i.e. difference between the speech and noise amplitudes)

plot_figs = 1; % option to plot the figures (1=yes and 0=no)
save_figs = 0; % option to save the figures (1=yes and 0=no)

fig_sound_nametag = {'S_01_08_WhiteNoise_SNR_5',...
                     'S_01_08_WhiteNoise_SNR_10',...
                     'S_01_08_WhiteNoise_SNR_15',...
                     'S_01_08_WhiteNoise_SNR_20'}; % tagname which the figures and sound file will be saved with
                 
figures_dir = 'C:\Users\forst\OneDrive\Uni\Studienarbeit\StA_Speech_Intelligibility\signals\generated\figs';  % string with the folder where the figures shall be saved

save_sound = 1; % option to save the generated sound file (1=yes and 0=no)
sound_dir = 'C:\Users\forst\OneDrive\Uni\Studienarbeit\StA_Speech_Intelligibility\signals\generated'; % string with the folder where the sound file shall be saved

%% generate speech + white noise function

for i = 1:length(SNR)
    
     GenerateSpeechWhiteNoise(insig,...                     % path of input speech signal
                              Desired_SPL_speech,...        % desired level, in dB spl, to calibrate the input speech signal
                              SNR(i),...                    % desired signal-to-noise ratio (i.e. difference between the speech and noise amplitudes)
                              plot_figs,...                 % option to plot the figures (1=yes and 0=no)
                              save_figs,...                 % option to save the figures (1=yes and 0=no)
                              fig_sound_nametag{i},...      % string with the tagname which the figures and sound file will be saved with
                              figures_dir,...               % string with the folder where the figures shall be saved
                              save_sound,...                % option to save the generated sound file (1=yes and 0=no)
                              sound_dir);                   % string with the folder where the sound file shall be saved
                          
end
