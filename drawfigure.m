function [  ] = drawfigure( maxx, maxy, node,links, dist, slot)
%DRAWFIGURE Summary of this function goes here
%   Detailed explanation goes here
close all

    % make background white, run only once
%if (slot == 0)    
    colordef none,  whitebg
    %figure('Visible', 'off');
    figure;
    axis equal
    hold on;
    box on;
    plot(node(:, 1), node(:, 2), 'k.', 'MarkerSize', 8);    
%    title([dist ' Network topology']);
%else
%    plot(node(:, 1), node(:, 2), 'k.', 'MarkerSize', 8);    
    title([dist ' Simulcast Ad-hoc Network slot= ' num2str(slot)]);
%end
    
    
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

