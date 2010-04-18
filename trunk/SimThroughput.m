function [ Ss, G ] = SimThroughput( links, maxn, Dmax, maxx, maxy, theta)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
n = 4;
       dl = Dmax*(cos(theta*pi/180))^(2/n);
       dm = Dmax*(sin(theta*pi/180))^(2/n);
       pm = (pi*dm^2)/(maxx*maxy);
       Rma = 1 - (1 - pm)^(maxn-1); 

Samples = 20;
Su = zeros(Samples,1);
g = 0;
for G=logspace(-3,0,Samples);
    g=g+1;
    for i=1:maxn
        Su(g) = sui(links,i,G) + Su(g);
    end
    Su(g) = Su(g)/maxn;
end
G=logspace(-3,0,Samples);
Ss = Su.*(1 + Rma);
semilogx(G,Ss)
end