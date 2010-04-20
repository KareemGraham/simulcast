function [ ] = plottheseavg( root_dir, theta )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    for i=1:length(theta)
        [X(:,i) Y(:,i)]=plotavg(root_dir, theta(i));
    end
    close all;
    theta=[0:5:15 19.25 20:5:45];
% Create figure
figure1 = figure(1);

% Create axes
axes1 = axes('Parent',figure1,'XScale','log','XMinorTick','on');
semilogx(X,Y)
xlim(axes1,[0.001 1]);
% Create xlabel
xlabel('Average Attempt Rate','FontSize',8);

% Create ylabel
ylabel('Average Link Throughput','FontSize',8);

end

