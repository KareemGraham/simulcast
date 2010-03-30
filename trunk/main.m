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
 Node   = struct('ID', [], 'TxMCB', [], 'TxLCB', [], 'RxBuf', [], 'iNWQ', [], 'iMCQ', [], 'iLCQ', []);
 
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
 Ns     = 100;        % Number of topology simulations
 dF     = 0;        % drawFigure parameter of topo function fame :)
 NP     = ceil(Nt*R); % No. of packets each node would have to transmit.
 % NP is calculated as the attempt rate times number of slots. This should
 % give us the number of packets each node would try to transmit during the
 % simulation. 
 Pt      = 2;        % Packet type. Right now packet could be either 
 % "To Forward" packet, or regular packet which originates from the same
 % node. We can add Multicast Type or Broadcase type later on if we wish
 % to. 
 
 HopsT  = zeros(Mnum,NP); % Hops table to generate randomly distributed
 % NP no of hops that the packet would need to make to its destination
 
 % Packet States Enum (Not sure how many we need, just initializing)
 
 Inv    = 0;        % Packet is invalid
 Ready  = 1;        % Packet ready to be transmitted
 Trans  = 2;        % Packet Transmission Successful
 Colli  = 3;        % Packet Collision
 Retry  = 4;        % Packet Needs to be retransmitted (State after Colli?)
 Rmax   = 5;        % Packet retry limit reached, drop the packet (RT = 7)
 
 % Packet Type Enum (We may need it if we decide to implement broadcasting)
 
 Normal = 1;        % Normal type packet
 Fwd    = 2;        % Forwarding type packet
 BC     = 3;        % Broadcast packet
 MC     = 4;        % Multicast packet
 
 % Packet Encapsulation (Do we declare a packet by new_pkt = Pkt???)
 % @Des : Final Destination of Packet
 % @Tdes : Destination Node during current transit
 % @Tsrc : Source Node during current transit
 % @Src : Original Source of the packet
 % @Type : Type of packet - Normal, MC or BC
 % @State : State of packet
 % @Rtr : No. of Retries count for the packet
 % @Data : Packet Data
 
 % NW Layer just generates 100 packets for each node at the start of the
 % simulation. As the simulation proceeds, the packets from this queue are
 % fetched into LL_MCQ and LL_LCQ, which is Link Layer More Capable Queues
 % and Link Layer Less Capable Queues. 
 NW_Pkt(Mnum,NP)    = struct('Des', [], 'Tdes', [], 'Tsrc', [], 'Src', [], 'Type', [], 'State', [], 'Rtr', [], 'Data', [], 'No', []);
 % Link Layer More Capable Queue. Each node would maintain a queue for the
 % packets which can be forwarded on the More capable link. Further, the
 % queue would have Pt type subqueues depending upon the packet type.
 % Forwarding type packets are prefered upon the Local originating packets.
 LL_MCQ(Mnum,NP,Pt) = struct('Des', [], 'Tdes', [], 'Tsrc', [], 'Src', [], 'Type', [], 'State', [], 'Rtr', [], 'Data', [], 'No', []);
 % Link Layer Less Capable Queue. Each node would maintain a queue for the
 LL_LCQ(Mnum,NP,Pt) = struct('Des', [], 'Tdes', [], 'Tsrc', [], 'Src', [], 'Type', [], 'State', [], 'Rtr', [], 'Data', [], 'No', []);
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
         Node(idxNode).ID = idxNode;
         Node(idxNode).iNWQ = 1;
         Node(idxNode).iMCQ = [1 1];
         Node(idxNode).iLCQ = [1 1];
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
             NW_Pkt(idxNode,idxNP).Tdes = RouteDes(2);
             NW_Pkt(idxNode,idxNP).Type = Normal;
             NW_Pkt(idxNode,idxNP).State = Ready; % Ready to transmit
             NW_Pkt(idxNode,idxNP).Rtr = 0;
             NW_Pkt(idxNode,idxNP).No = idxNP;
         end %for idxNP = 1:NP
     end % for idxNode = 1:Mnum
     
     % Pre Transmission packet queue processing. I think it needs to be
     % done before each Aloha Slot simulation. Will brainstorm and fix the
     % placement of this code. 
     
     for idxNode = 1:Mnum
         % Fetch the packet from NW queue into one of LL queue
         idxNextPkt = Node(idxNode).iNWQ;
         Node(idxNode).iNWQ = idxNextPkt + 1;
         TempPkt = NW_Pkt(idxNode,idxNextPkt);
         MoreCap = links(TempPkt.Tsrc,TempPkt.Tdes);
         if MoreCap > 0
             LL_MCQ(idxNode,Node(idxNode).iMCQ(1,Normal),Normal) = TempPkt;
             Node(idxNode).iMCQ(1,Normal) = Node(idxNode).iMCQ(1,Normal) + 1; 
         else
             LL_LCQ(idxNode,Node(idxNode).iLCQ(1,Normal),Normal) = TempPkt;
             Node(idxNode).iLCQ(1,Normal) = Node(idxNode).iLCQ(1,Normal) + 1;
         end
     end
     
     % Simulate SLOHA Here: ToDo
     collisions(Mnum) = 0 % initialize collision count for each node
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
     % Post Transmission Packet Processing
     % Things ToDo here -----
        % Update the Tdes fields of forwarding packets here
        % If Pkt.Des = Pkt.Tdes, destination reached. Increment the End to
        % End throughput counter. Else, increment Link Throughput counter. 
        % Expire packets that have collided > max retries
     end % for idxT = 1:Nt
     % Performance Graph code goes here
 end % for idxS = 1:Ns