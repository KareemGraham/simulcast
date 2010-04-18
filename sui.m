function [ Sui ] = sui( links, i, G )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
Ci = 0;
neighbors = find(links(i,:));
Bi = length(neighbors);
for j=1:Bi
    Bij = length(find(links(neighbors(j),:)));
    Ci = Ci + (1-(1-G)^Bij);
end
Ci=Ci/Bi;
Sui = G*(1-Ci);
end

