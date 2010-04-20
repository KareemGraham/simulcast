function [ outsig ] = channelAWGN381( insign,dist )
%CHANNELAWGN simulated n=4 exponent path loss channel with additive white
%            guassian nosie

f=2.4e9;                %Carrier frequency
c=3e8;                  %Speed of light
n=4;                    %Exponent of path loss
lamda = c/f;            %Wavelength

%Calculate the voltage attenuation for given path loss
volt_attn = ((lamda/(4*pi*dist))^n)^0.5;

%noise needs to be constants related to 0 dBW SNR
%for BER ~1e-4@1 km => Eb/No ~8 dB
%From formula S/N  = Eb/No * R/B
%Which in dB is S - N = Eb/No(dB) + R/B(dB)
%
%In 802.11 standard, Tx max at 2.4G = 100mW or 50dBm
%For simplexity, Tx = 10 dBm for Vmax = 1V
%
%The path-loss at 1km is -200.092 dB, from 40*log10(lamda/(4*pi()*1000))
%
%Therefore: 
%     S=Rx Signal at 1km = 10-200.1=-190.1 dBm
%
%From the standard, B=11MHz, R= 1Mbps for BPSK => 11 Ts per symbol
%Since the max dist is 1k m for unicast traffic, R=1Mbps.
%
%Thus
%     N = -190.1 dBm -8 dB -10*log10(1/11)
%       = -187.7 dBm or -217.7 dBW 
%       => SNR must be greater than 217.7 dB for S=0dBW

snr = 231; %Using 247.7 for SNR
outsig = awgn(volt_attn*insign,snr,0); %

end

