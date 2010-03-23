function [node] = topo(maxn, maxx, maxy, sigma, drawFigure);
% Generate network topology
%sigma = min(sigma,maxx/6);
% S = rand('state');
% rand('state',0);
Dmax = 381;
link_check = 0;
while(1)    
    node = randn(maxn,2);
    %node = rand(maxn,2);
    node(:,1) = sigma.*node(:,1);
    node(:,2) = sigma.*node(:,2);
    links = connectivity(node,Dmax);
    for x=1:length(node)
        link_check =sum(links(:,x));
        if(link_check == 0)
            break;
        end
    end
    if (max(max(node)) < 500 && min(min(node)) > -500 && link_check)
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
    end
end

%line([info(i, 2), info(k, 2)], [info(i, 3), info(k, 3)], 'Color', 'k', 'LineStyle', '-', 'LineWidth', 1.5);
return;
