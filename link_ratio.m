function [ Rm ] = link_ratio( links )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
Rm = length(find(links > 0))/length(find(links));
end

