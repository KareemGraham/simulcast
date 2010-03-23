function [ outsig ] = channelAWGN( insign,dist )
%CHANNELAWGN Summary of this function goes here
%   Detailed explanation goes here
f=2.4e9;
c=3e8;
lamda = c/f;
noise = -203.3;

volt_attn = ((lamda/(4*pi*dist))^4)^0.5;

%noise needs to be constants related to 0 dBW SNR
%for BER < 1e-6@381 m => Eb/No ~10.5 dB
%From formula S/N  = Eb/No * R/B
%Which in dB is S - N = Eb/No(dB) + R/B(dB)
%
%In 802.11 standard, Tx max at 2.4G = 100mW or 50dBm
%For simplexity, Tx = 10 dBm for Vmax = 1V
%
%The path-loss at 381m is -183.329 dB, from 40*log10(lamda/(4*pi()*381))
%
%Therefore: 
%     S=Rx Signal at 381m = 10-183.3=-173.33 dBm
%
%From the standard, B=11MHz, R= 1Mbps for BPSK, 2Mbps for QPSK
%Since the max dist is 381 m for unicast traffic, R=1Mbps.
%
%Thus
%     N = -173.33 dBm -10.5 dB -10*log10(1/11)
%       = -173.3 dBm or -203.3 dBW


outsig = awgn(volt_attn*insign,noise);

end

