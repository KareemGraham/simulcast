function [ Ndeg ] = network_degree( links )
%Calculates the Network Degree
%   Detailed explanation goes here
Ndeg = 0;
for x=1:length(links)
    Ndeg = Ndeg+length(nodes_with_n_hops(links,x,1));
end
Ndeg = Ndeg/length(links);
end