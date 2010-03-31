% main.m 
% 
% Simulcast Packet Transmission on an Ad Hoc Network using Slotted ALOHA
% 
% MATLAB version Programmed by Kareem G/Manish Bansal/Sien Wu/Thomas M

 close all;
 clear all;
 clc;
 
 % Global Parameters
 global Node;
 global n; % Path Loss Exponent
 global Dmax; % Maximum Distance between two nodes
  
 % Node parameters
 
 Mnum   = 15;       % Number of nodes on network
 Xmax   = 1000;      % X dimension of area in meters
 Ymax   = 1000;      % Y dimension of area in meters
 Sig    = 0;        % STD distribution of nodes in the area
 
 
 % Declaring Slotted ALOHA Network Parameters
 brate  = 512e3;    % Bit rate
 Srate  = 256e3;    % Symbol rate
 Plen   = 923;      % Packet Length in bits
 G      = 1;        % Offered Normalized Load to the Network
 R      = G/Mnum;   % Arrival Rate of packets at node
 % It is calculated as Offered Normalized Load/ No. of Nodes. So if the
 % normalized Load is 1, the number of packets each node would schedule to
 % transmit in Mnum slots should be only 1. Thus, on an average, the number
 % of packets tranmitted in each slot is 1/Mnum by each node. 
 S      = 0;        % Network throughput
 RT     = 7;        % Maximum No. of retries for a packet before dropping
 n      = 4;        % Path Loss Exponent
 
 % Simulcast Parameters
 Theta  = 30;       % Offset angle in degrees
 Dmax   = 381;
 
 % Simulation Parameters
 Nt     = 1500;     % Number of time slots simulated for each topology
 Ns     = 1;        % Number of topology simulations
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
 
 global Invalid Ready Trans Colli Retry Rmax
 
 Invalid= 0;        % Packet is invalid
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
 
 % Packet Structure Initialization
 % @Des : Final Destination of Packet
 % @Tdes : Destination Node during current transit
 % @Tsrc : Source Node during current transit
 % @Src : Original Source of the packet
 % @Type : Type of packet - Normal, MC or BC
 % @State : State of packet
 % @Rtr : No. of Retries count for the packet
 % @Data : Packet Data
 global Pkt
 Pkt = struct('Des', 0, 'Tdes', 0, 'Tsrc', 0, 'Src', 0, 'Type', 0, 'State', 0, 'Rtr', 0, 'Data', zeros(1,Plen), 'No', 0);
  
 % Queue Structure Initilization
 % @ len: Length of queue. When received a new packet, store in
 % Queue(len+1) and len = len + 1
 % @ Pkts: Field to hold 100 instances of Pkt type
 Q = struct('len', 0, 'Pkts', []);
 Q.len = 0;
 Q.Pkts = Pkt;
 Q.Pkts(1:NP) = Pkt;
 
 % Node Structure Initilization
 % @ ID: Node ID
 % @ TxMCB : More Capable Link Tx Buffer
 % @ TxLCB : Less Capable Link Tx Buffer
 % @ RxBuf : Receive Buffer
 % @ LinkCount : Counter to keep successful Link Transmissions
 % @ E2ECount : Counter to keep successful End to End Transmissions
 % @ BoS : Back Off Slot - Next Tx Slot No. 
 % @ X : X coordinate of the node
 % @ Y : Y coordinate of the node
 % @ Mhops : Maximum number of hops possible from this node
 % @ LcLQ : Queue for Less capable - Local originating packets
 % @ McLQ : Queue for More capable - Local originating packets
 % @ LcFQ : Queue for Less capable - Forwarding packets
 % @ McFQ : Queue for More capable - Forwarding packets
 
 Node   = struct('ID', 0, 'TxMCB', [], 'TxLCB', [], 'RxBuf', [], 'LinkCount', 0, 'E2ECount', 0, 'BoS', 0, 'X', 0, 'Y', 0, 'Mhops', 0, 'LcLQ', [], 'McLQ', [], 'LcFQ', [],'McFQ', []);
 Node.TxMCB = Pkt;
 Node.TxLCB = Pkt;
 Node.RxBuf = Pkt;
 Node.LcLQ = Q;
 Node.McLQ = Q;
 Node.LcFQ = Q;
 Node.McFQ = Q;
 Nodes = Node;
 Nodes(1:Mnum) = Node;
 
 % Start Topology Simulation
 for idxS = 1:Ns,
     % Get the node distribution, link table and max. no. of hops for each
     % node
     [nodeXY, Links, Mh] = topo(Mnum, Xmax, Ymax, Sig, Theta, dF);
     
     % Node Initialization 
     for idxNode = 1:Mnum
         Nodes(idxNode).ID  = idxNode;
         Nodes(idxNode).X   = nodeXY(idxNode,1);
         Nodes(idxNode).Y   = nodeXY(idxNode,2);
         Nodes(idxNode).Mhops = Mh(idxNode);
     end

     for idxT = 1:Nt
         
        for SrcNode = 1:Mnum
            TempPkt = Pkt;
            TempPkt.Src = SrcNode;
            TempPkt.Tsrc = SrcNode;
            TempPkt.Type = Normal;
            TempPkt.State = Ready;
            % Get number of arriving packets as per Poisson Dist.
            NumPkts = poissonTx(1); % Keeping it fixed right now. Need to discuss
            if NumPkts == 0
                continue; % If new arrival pkts = 0, go to next node
            end
            nHops = randi([1,Nodes(SrcNode).Mhops],1,NumPkts);
            for i = 1:NumPkts % (What if NumPkts = 0 ??)
                PossDes = nodes_with_n_hops(Links, SrcNode, nHops(i));
                TempPkt.Des = PossDes(randi(length(PossDes)));
                RouteDes = route(SrcNode, TempPkt.Des, Links);
                TempPkt.Tdes = RouteDes(2);
                MoreCap = Links(TempPkt.Tsrc,TempPkt.Tdes);
                if MoreCap > 0 % Can be put on the More Capable Link Queue
                    len = Nodes(SrcNode).McLQ.len;
                    Nodes(SrcNode).McLQ.Pkts(len+1) = TempPkt;
                    Nodes(SrcNode).McLQ.len = len + 1;
                else % Can be put on the Less Capable Link Queue
                    len = Nodes(SrcNode).LcLQ.len;
                    Nodes(SrcNode).LcLQ.Pkts(len+1) = TempPkt;
                    Nodes(SrcNode).LcLQ.len = len + 1;
                end
            end
        end

%%
% Schedule the packet
% Somethings to keep in mind while scheduling a packet for Tx: 
% 1. Total no. of packets must be greater than zero for a node to be 
% considered for tranmission. 
% 2. Priority order will be McFQ, McLQ, LcFQ, LcLQ. If any of the queues have
% non zero number of packets, consider scheduling the packets from this node
% provided that:
%     a. The packet in the queue has Pkt.State = Ready; and
%     b. Node.TxMCB.State = Invalid or Node.TxLCB.State = Invalid
%        depending upon which buffer the packet would be scheduled in. 
% 3. If above conditions are met, fetch the packet from the queue. Decrement 
% the lenght of the queue and copy the packet into the TxBuffer
%%         

        for i = 1:Mnum
            TransPkt = Nodes(i).McFQ.len + Nodes(i).LcFQ.len + Nodes(i).McLQ.len + Nodes(i).LcLQ.len; % Total no. of packets in the node queues
            
            if(TransPkt == 0)
                continue;
            end
            % Since the packets are already sorted wrt having simulcast
            % capacity or not, we just need to check the relevant queues
            % for the non zero length.
            % Try scheduling a MC Local Packet first
            if(Nodes(i).McLQ.len > 0) % More Capable Link rider fwd packet
                if(Nodes(i).TxMCB.State == Invalid && Nodes(i).McLQ.Pkts(1).State == Ready)
                    [Nodes(i).TxMCB, Nodes(i).McLQ] = schd_pkt(Nodes(i).TxMCB, Nodes(i).McLQ);
                end
            % Try scheduling a MC Fwd Packet next
            elseif(Nodes(i).McFQ.len > 0) % More Capable Link rider Local packet
                if(Nodes(i).TxMCB.State == Invalid && Nodes(i).McFQ.Pkts(1).State == Ready)
                    [Nodes(i).TxMCB, Nodes(i).McFQ] = schd_pkt(Nodes(i).TxMCB, Nodes(i).McFQ);
                end
            end
            % Since either we schduled a More Capable link rider packet
            % or one was already present in the node TxMCB, or there is no
            % Simulcast capability that the node has. In all cases, we
            % should try to schedule a packet in the Less capable link
            % queue starting with local queue
             if(Nodes(i).LcLQ.len > 0) % Less Capable Link rider Local packet
                 if(Nodes(i).TxLCB.State == Invalid && Nodes(i).LcLQ.Pkts(1).State == Ready)
                     [Nodes(i).TxLCB, Nodes(i).LcLQ] = schd_pkt(Nodes(i).TxLCB, Nodes(i).LcLQ);
                 end
             elseif(Nodes(i).LcFQ.len > 0) % Less Capable Link rider Forward packet
                 if (Nodes(i).TxLCB.State == Invalid && Nodes(i).LcFQ.Pkts(1).State == Ready)
                     [Nodes(i).TxLCB, Nodes(i).LcFQ] = schd_pkt(Nodes(i).TxLCB, Nodes(i).LcFQ);
                 end
             end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % From this point on, for all the further purposes, one can assume
        % that the packets are scheduled in TxMCB and TxLCB of the Nodes.
        % The further routines must check Tx.MCB.State = Ready and
        % TxLCB.State = Ready to make sure that the packets in these buffers
        % valid for transmission. There are few changes that we may to do
        % in the packet scheduling. But it would not affect the processing
        % that we need to do from here on. 

% Collision part goes here.. 
        
        % Evaluate collisions and schedule retransmission slot
        % ceil(2^(num. of collisions)*rand(1)) is the binary exponential
        % backoff delay in # of slots
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Transmit any packets that did not experience collision
        % 
        % NOTE: not sure yet how to deal with results from simulcast_txrx
        % or how to format "packet" input for simulcast_txrx/unicast_txrx
        %
        % Once I know that, 
        
        for i=1:Mnum
            if Nodes(i).BoS <= idxT % backoff slot not in the future
                if (Nodes(i).TxMCB.State == Ready && Nodes(i).TxLCB.State == Ready)
                   % simulcast
                   result = simulcast_txrx(Nodes(i).TxMCB, Nodes(i).TxLCB,...
                       topo_dist(nodeXY, Nodes(i).TxMCB.Tsrc, Nodes(i).TxMCB.Tdes),...
                       topo_dist(nodeXY, Nodes(i).TxLCB.Tsrc, Nodes(i).TxLCB.Tdes),...
                       Theta);
                elseif (Nodes(i).TxMCB.State == Ready) % unicast MC packet
                    result = unicast_txrx(Nodes(i).TxMCB,...
                        topo_dist(nodeXY, Nodes(i).TxMCB.Tsrc, Nodes(i).TxMCB.Tdes));
                elseif (Nodes(i).TxLCB.State == Ready) % unicast LC packet
                    result = unicast_txrx(Nodes(i).TxLCB,...
                        topo_dist(nodeXY, Nodes(i).TxLCB.Tsrc, Nodes(i).TxLCB.Tdes));
                else
                    result=[]; % not in backoff and nothing to send
                end
                % process result and update nodes/packets.
                % once a packet gets to this point (past collision section),
                % if it has errors, it will be "lost", no retries.
            end
        end
        
     % Post Transmission Packet Processing
     % Things ToDo here -----
        % Update the Tdes fields of forwarding packets here
        % If Pkt.Des = Pkt.Tdes, destination reached. Increment the End to
        % End throughput counter. Else, increment Link Throughput counter. 
        % Expire packets that have collided > max retries
     end % for idxT = 1:Nt
     % Performance Graph code goes here
 end % for idxS = 1:Ns