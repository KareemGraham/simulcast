function [links] = topo(maxn, maxx, maxy, sigma, drawFigure);
% Generate network topology
% maxn = Number of nodes;
% maxx * maxy = area in m^2
% sigma is std of distribution of nodes in m
% drawFigure = 1 to plot, 0 for no plot
Dmax = 381;

while(1)    
    link_check = 1;
    node = randn(maxn,2);
    node(:,1) = sigma.*node(:,1);
    node(:,2) = sigma.*node(:,2);
    links = connectivity(node,Dmax);
    d = bfs(links,1,0);
    for x=1:length(node)
       link_check = min(link_check,d(x));
     end
    
    if (max(max(node)) < 500 && min(min(node)) > -500 && link_check > -1)
        break;
    end
% rand('state',S);
end

if drawFigure >= 1
    % make background white, run only once
    colordef none,  whitebg
    figure(1);
    axis equal
    hold on;
    box on;
    % grid on;
    plot(node(:, 1), node(:, 2), 'k.', 'MarkerSize', 8);
    title('Network topology');
    xlabel('X');
    ylabel('Y');
    axis([-maxx/2, maxx/2, -maxy/2, maxy/2]);
    set(gca, 'XTick', [-maxx/2; maxx/2]);
    set(gca, 'XTickLabel', [0; maxx]);
    set(gca, 'YTick', [maxy/2]);
    set(gca, 'YTickLabel', [maxy]);
    for x=1:length(node)
        for y=x+1:length(node)
            if(links(x,y)>0)
                line([node(x,1) node(y,1)],[node(x,2) node(y,2)],'color','r');
            end
        end
        text(node(x,1),node(x,2),['  ' int2str(x)])
    end
end
return;
