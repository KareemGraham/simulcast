function [ collisions ] = collision_detect( links, activity )
% Returns which transmissions would result in a collision based of topology
%   tx nodes are the indices and rx nodes are elements
%   zero indicates no transmission
collisions = zeros(length(activity),1);
tx_node = find(activity);
for x = 1:length(tx_node)
    rx_local = nodes_with_n_hops(links,activity(tx_node(x)),1);
    for y = 1:length(tx_node)
        if (x == y)
            continue;
        end
        if (isempty(find(rx_local == tx_node(y), 1)) == 1)
            collisions(tx_node(x)) = collisions(tx_node(x))+0;
        else
            collisions(tx_node(x)) = collisions(tx_node(x))+1;
        end
    end
    %check for case that a receiving node is also transmitting
    rxtx = find(activity == tx_node(x));
    if(rxtx)
        collisions(rxtx) = collisions(rxtx)+1;
    end
end
end

