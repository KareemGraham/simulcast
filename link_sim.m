close all;
clear all;
N = 100;
maxn = 10;
maxx = 1000;
maxy = 1000;
sigma = 250;
theta = 0:5:45;
Ndeg = zeros(length(theta),1);
Rm = zeros(length(theta),1);
global Dmax;
global n;
Dmax = 381;
n = 4;

for y=1:N
    [node, ~, ~] = topo(maxn, maxx, maxy, sigma,0,0);
    for x=1:length(theta);
       links = connectivity(node,Dmax,theta(x));
       Ndeg(x) = Ndeg(x)+network_degree(links);
       Rm(x) = Rm(x)+link_ratio(links);
    end
end
Ndeg=Ndeg./N;
Rm=Rm./N;
figure
plot(theta,Ndeg)
    title('Network Degree v. \theta');
    xlabel('Offset Angle \theta');
    ylabel('Network Degree');
figure
plot(theta,Rm)
    title('More capable node Ratio v. \theta');
    xlabel('Morecapable node Ratio');
    xlabel('Offset Angle \theta');