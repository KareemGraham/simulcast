function [node] = topo(maxn, maxx, maxy, drawFigure);
% Generate network topology
sigma = 1;
% S = rand('state');
% rand('state',0);
%node = sigma.*randn(maxn,2);
node = rand(maxn,2);
node(:,1) = node(:,1)*maxx;
node(:,2) = node(:,2)*maxy;
% rand('state',S);
 maxx = max(node(:,1))*1.1;
 maxy = max(node(:,2))*1.1;
 minx = min(node(:,1))*.9;
 miny = min(node(:,2))*.9;
Dmax = 381;
links = connectivity(node,Dmax)
if drawFigure >= 1
    % make background white, run only once
    colordef none,  whitebg
    figure(1);
    axis equal
    hold on;
    box on;
    % grid on;
    plot(node(:, 1), node(:, 2), 'k.', 'MarkerSize', 5);
    title('Network topology');
    xlabel('X');
    ylabel('Y');
    %axis([minx, maxx, miny, maxy]);
    set(gca, 'XTick', [0; maxx]);
    set(gca, 'YTick', [maxy]);
    for x=1:length(node)
        for y=x+1:length(node)
            if(links(x,y)>0)
                line([node(x,1) node(y,1)],[node(x,2) node(y,2)],'color','r');
            end
        end
    end
end

%line([info(i, 2), info(k, 2)], [info(i, 3), info(k, 3)], 'Color', 'k', 'LineStyle', '-', 'LineWidth', 1.5);
return;
