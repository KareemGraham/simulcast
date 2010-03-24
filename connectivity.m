function [ links ] = connectivity( node, Dmax, theta )
%connectivity - returns matrix of connectivity of nodes
%   Detailed explanation goes here
global n;
if (theta == 0)
     links = zeros(length(node));
    for x = 1:length(node)    
        for y = 1:length(node)
            links(x,y) = topo_dist(x,y,node);
            links(x,y) = links(x,y)*(links(x,y) < Dmax);
        end
    end
else
    dl = Dmax*(cos(theta*pi/180))^(2/n)
    dm = Dmax*(sin(theta*pi/180))^(2/n)
     links = zeros(length(node));
    for x = 1:length(node)    
        for y = 1:length(node)
            links(x,y) = topo_dist(x,y,node);
            if (links(x,y) < dl && links(x,y) > dm)
                links(x,y) = -links(x,y);
            elseif (links(x,y) > dl)
                links(x,y) = 0;
            end
        end
    end

end

end

