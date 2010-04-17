function [ Rm ] = node_ratio( links )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
for x=1:length(links)
Rm(x) = sum(find(links(x,:) > 0)) > 0;
end
Rm = sum(Rm)/length(links);
end

