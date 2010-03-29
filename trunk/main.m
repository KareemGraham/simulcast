% main.m 
% 
% Simulcast Packet Transmission on an Ad Hoc Network using Slotted ALOHA
% 
% MATLAB version Programmed by Kareem G/Manish Bansal/Sien Wu/Thomas M

 close all;
 clear all;
 clc;
 
 % Node parameters
 
 Mnum   = 15;       % Number of nodes on network
 Xmax   = 1000;      % X dimension of area in meters
 Ymax   = 1000;      % Y dimension of area in meters
 Sig    = 0;        % STD distribution of nodes in the area
 
 % Declaring Slotted ALOHA Network Parameters
 
 brate  = 512e3;    % Bit rate
 Srate  = 256e3;    % Symbol rate
 Plen   = 128;      % Packet Length in bits
 G      = 1;        % Offered Normalized Load to the Network
 R      = G/Mnum;   % Attempt Rate of nodes. 
 % It is calculated as Offered Normalized Load/ No. of Nodes. So if the
 % normalized Load is 1, the number of packets each node would schedule to
 % transmit in Mnum slots should be only 1. Thus, on an average, the number
 % of packets tranmitted in each slot is 1/Mnum by each node. 
 global n;
 S      = 0;        % Network throughput
 RT     = 7;        % Maximum No. of retries for a packet before dropping
 n      = 4;        % Path Loss Exponent
 
 % Simulcast Parameters
 global Dmax;
 Theta  = 30;       % Offset angle in degrees
 Dmax   = 381;
 
 % Simulation Parameters
 
 Nt     = 1500;     % Number of time slots simulated for each topology
 Ns     = 1;        % Number of topology simulations
 dF     = 1;        % drawFigure parameter of topo function fame :)
 NP     = ceil(Nt*R); % No. of packets each node would have to transmit.
 % NP is calculated as the attempt rate times number of slots. This should
 % give us the number of packets each node would try to transmit during the
 % simulation. 
 
 HopsT  = zeros(Mnum,NP); % Hops table to generate randomly distributed
 % NP no of hops that the packet would need to make to its destination
 
 % Packet States Enum (Not sure how many we need, just initializing)
 
 Ready  = 0;        % Packet ready to be transmitted
 Trans  = 1;        % Packet Transmission Successful
 Colli  = 2;        % Packet Collision
 Retry  = 3;        % Packet Needs to be retransmitted (State after Colli?)
 Rmax   = 4;        % Packet retry limit reached, drop the packet (RT = 7)
 
 % Packet Encapsulation (Do we declare a packet by new_pkt = Pkt???)
 % @Des : Final Destination of Packet
 % @Tdes : Destination Node during current transit
 % @Tsrc : Source Node during current transit
 % @Src : Original Source of the packet
 % @Data : Packet Data
 
 NW_Pkt(Mnum,NP)    = struct('Des', [], 'Tdes', [], 'Tsrc', [], 'Src', [], 'State', [], 'Data', []);
 
 % Start Topology Simulation
 for idxS = 1:Ns,
     % Get the node distribution, link table and max. no. of hops for each
     % node
     [node, links, mhops] = topo(Mnum, Xmax, Ymax, Sig, Theta, dF);
     
     % Get the Hop Table for each Node. It consists of uniform random 
     % distribution of the hops that a packet may need to make to reach its 
     % destination in range [1,mhops(i)]
     for idxNode = 1:Mnum
         HopsT(idxNode,:) = randi([1,mhops(idxNode)],1,NP);
         % Construct the NP packets for each node. The packets by ith node
         % need to make hops are stored in ith row of HopsT . Function
         % nodes_with_n_hops(links, x, n) retruns the possible destinations 
         % which can be reached in 'n' hops from 'x'. We pick one of these
         % destinations randomly. route(src,des,links) returns the routing
         % table between src and des nodes. 
         for idxNP = 1:NP
             % Original source is same as the idxNode
             NW_Pkt(idxNode,idxNP).Src = idxNode;
             % During first hop, Tsrc = Src
             NW_Pkt(idxNode,idxNP).Tsrc = NW_Pkt(idxNode,idxNP).Src; 
             % Get the possible destinations for the given hop and select 1
             % of them randomly
             PossDes = nodes_with_n_hops(links, idxNode, HopsT(idxNode,NP));
             NW_Pkt(idxNode,idxNP).Des = PossDes(randi(length(PossDes)));
             % Get the routing table and update the next transit
             % destination
             RouteDes = route(idxNode, NW_Pkt(idxNode,idxNP).Des, links ); 
             NW_Pkt(idxNode,idxNP).Tdes = RouteDes(1);            
         end %for idxNP = 1:NP
     end % for idxNode = 1:Mnum
     
     % Simulate SLOHA Here: ToDo
     collisions(Mnum)=0 % initialize collision count for each node
     for idxT = 1:Nt
        % Nodes that will attempt to transmit
        for idxNode = 1:Mnum
            % random chance that each will attempt to Tx
            % then clean up list
            % - force Tx if collision retry scheduled
            % - no Tx if waiting on collision retry
        end
        % Evaluate collisions and schedule retransmission slot
        % ceil(2^(num. of collisions)*rand(1)) is the binary exponential
        % backoff delay in # of slots
        %
        % Expire packets that have collided > max retries
     end % for idxT = 1:Nt
     % Performance Graph code goes here
 end % for idxS = 1:Ns