function [node, links, mhops] = topo(maxn, maxx, maxy, sigma, theta, drawFigure);
% Generate network topology
% Input parameters
% maxn = Number of nodes;
% maxx * maxy = area in m^2
% sigma is std of distribution of nodes in m
% sigma = 0 for uniform distribution
% theta offset angle
% drawFigure = 1 to plot, 0 for no plot
% Output
% links = connectivity table of nodes 
%        (-) less capable
%        (+) more capable
%        (0) no link
global Dmax;
global n;
Dmax = 381; %Maximum unicast distance
n = 4; %Path loss exponent
while(1)    
    link_check = 1;
    if (sigma > 0)
        node = randn(maxn,2);
        node = sigma.*node;
        dist = 'Guassian';
    else
        node = rand(maxn,2);
        node(:,1) = node(:,1)*maxx-maxx/2;
        node(:,2) = node(:,2)*maxy-maxy/2;
        dist = 'Uniform';
    end
    links = connectivity(node,Dmax,theta);
    
    d = bfs(links,1,0);
    for x=1:length(node)
       link_check = min(link_check,d(x));
    end
    
    mhops = max_hops(links);
    %reject topologies which have unlinked nodes and nodes lying outside
    %set boundries
    if (max(max(node)) < maxx/2 && min(min(node)) > -maxx/2 && link_check > -1)
        break;
    end
end

if drawFigure >= 1
    % make background white, run only once
    colordef none,  whitebg
    figure(1);
    axis equal
    hold on;
    box on;
    plot(node(:, 1), node(:, 2), 'k.', 'MarkerSize', 8);
    title([dist ' Network topology']);
    xlabel('X Distance (meters)');
    ylabel('Y Distance (meters)');
    axis([-maxx/2, maxx/2, -maxy/2, maxy/2]);
    set(gca, 'XTick', [-maxx/2; maxx/2]);
    set(gca, 'XTickLabel', [0; maxx]);
    set(gca, 'YTick', [maxy/2]);
    set(gca, 'YTickLabel', [maxy]);
    for x=1:length(node)
        for y=x+1:length(node)
            if(links(x,y)>0)
                line([node(x,1) node(y,1)],[node(x,2) node(y,2)],'color','r');
            elseif (links(x,y)<0)
                line([node(x,1) node(y,1)],[node(x,2) node(y,2)],'color','b');
            end
        end
        text(node(x,1),node(x,2),['  ' int2str(x)])
    end
end
return;
