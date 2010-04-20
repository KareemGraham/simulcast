function [ ] = plote2emax( root_dir )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
i = 0;
    for theta=[0:5:15 19.25 20:5:45]
        i=i+1;
        [y(i)]=plote2e(root_dir, theta);
    end
    close all;
    theta=[0:5:15 19.25 20:5:45];
plot(theta,y,'k-*')
% Create xlabel
xlabel('Offset Angle \theta (degrees)','FontSize',8);

% Create ylabel
ylabel('Maximum Average End-to-End Throughput','FontSize',8);

end

