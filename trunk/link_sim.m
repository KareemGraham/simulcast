close all;
clear all;
N = 10;
maxn = 15;
maxx = 1000;
maxy = 1000;
sigma = 0;
theta = 0:5:45;
Ndeg = zeros(length(theta),1);
Rm = zeros(length(theta),1);
global Dmax;
global n;
Dmax = 381;
n = 4;

for y=1:N
    [node, ~, ~] = topo(maxn, maxx, maxy, sigma,45,0);

    for x=1:length(theta);
       links = connectivity(node,Dmax,theta(x));
       Ndeg(x) = Ndeg(x)+network_degree(links);
       Rm(x) = Rm(x)+node_ratio(links);
       
       dl = Dmax*(cos(theta(x)*pi/180))^(2/n);
       dm = Dmax*(sin(theta(x)*pi/180))^(2/n);
       pm(x) = (pi*dm^2)/(maxx*maxy);
       Rma(x) = 1 - (1 - pm(x))^(maxn-1);
       if(y==1)
       SimThroughput(links, maxn, Dmax, maxx, maxy,theta(x))
       hold on;
       end
       %drawfigure(maxx,maxy,node,links,'unit',1)
    end
end
hold off
Ndeg=Ndeg./N;
Rm=Rm./N;
figure
plot(theta,Rma)
    title('More capable node Ratio v. \theta (Theoretical)');
    ylabel('More capable node Ratio');
    xlabel('Offset Angle \theta (degrees)');
figure
plot(theta,Ndeg)
    title('Network Degree v. \theta');
    xlabel('Offset Angle \theta (degrees)');
    ylabel('Network Degree');
figure
plot(theta,Rm)
    title('More capable node Ratio v. \theta');
    ylabel('More capable node Ratio');
    xlabel('Offset Angle \theta (degrees)');