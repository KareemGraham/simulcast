% main.m 
% 
% Simulcast Packet Transmission on an Ad Hoc Network using Slotted ALOHA
% 
% MATLAB version Programmed by Kareem G/Manish Bansal/Sien Wu/Thomas M

 close all;
 clear all;
 clc;
 t1=clock;
 % Global Parameters
 global Node;
 global n; % Path Loss Exponent
 global Dmax; % Maximum Distance between two nodes
 global idxT % Current time slot clock counter
  
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
 Nt     = 150;     % Number of time slots simulated for each topology
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
 Pkt = struct('Des', 0, 'Tdes', 0, 'Tsrc', 0, 'Src', 0, 'Type', 0, 'State', 0, 'Rtr', 0, 'Data', boolean(zeros(1,Plen)), 'No', 0);
  
 % Queue Structure Initilization
 % @ len: Length of queue. When received a new packet, store in
 % Queue(len+1) and len = len + 1
 % @ Pkts: Field to hold 100 instances of Pkt type
 Q = struct('len', 0, 'Pkts', []);
 Q.len = 0;
 Q.Pkts = Pkt;
 Q.Pkts(1:NP) = Pkt;
 
 % Node State
 global NoPkt Ready2Tx BackOff
 NoPkt = 0;
 Ready2Tx = 1;
 BackOff = 2;
 
 % Events that lead to a change of Node States
 global NewPkt Collision TxSuccess DropPkt
 NewPkt = 1;
 Collision = 2;
 TxSuccess = 3;
 DropPkt = 4;
 
 % Node Structure Initilization
 % @ ID: Node ID
 % @ TxMCB : More Capable Link Tx Buffer
 % @ TxLCB : Less Capable Link Tx Buffer
 % @ RxBuf : Receive Buffer
 % @ LinkCount : Counter to keep successful Link Transmissions
 % @ E2ECount : Counter to keep successful End to End Transmissions
 % @ BoS : Back Off Slot - Next Tx Slot No. 
 % @ State : State of the Node. Look at "Node State" Table
 % @ X : X coordinate of the node
 % @ Y : Y coordinate of the node
 % @ Mhops : Maximum number of hops possible from this node
 % @ LcLQ : Queue for Less capable - Local originating packets
 % @ McLQ : Queue for More capable - Local originating packets
 % @ LcFQ : Queue for Less capable - Forwarding packets
 % @ McFQ : Queue for More capable - Forwarding packets
 
 Node   = struct('ID', 0, 'TxMCB', [], 'TxLCB', [], 'RxBuf', [], 'LinkCount', 0, 'E2ECount', 0, 'BoS', 0, 'State', 0, 'X', 0, 'Y', 0, 'Mhops', 0, 'LcLQ', [], 'McLQ', [], 'LcFQ', [],'McFQ', []);
 Node.TxMCB = Pkt;
 Node.TxLCB = Pkt;
 Node.RxBuf = Q; %Sien: change the rx buff to be a queue
 Node.LcLQ = Q;
 Node.McLQ = Q;
 Node.LcFQ = Q;
 Node.McFQ = Q;
 Nodes = Node;
 
 % Start Topology Simulation
 for idxS = 1:Ns,
     % Get the node distribution, link table and max. no. of hops for each
     % node
     Nodes(1:Mnum) = Node; % Clear all the nodes when simulating new topology
     [nodeXY, Links, Mh] = topo(Mnum, Xmax, Ymax, Sig, Theta, dF);
          
     % Node Initialization 
     for idxNode = 1:Mnum
         Nodes(idxNode).ID  = idxNode;
         Nodes(idxNode).X   = nodeXY(idxNode,1);
         Nodes(idxNode).Y   = nodeXY(idxNode,2);
         Nodes(idxNode).Mhops = Mh(idxNode);
         Nodes(idxNode).State = NoPkt; % None of the nodes has pkts initially
     end

     %Sien: Throughput counter variable
     pktcount = 0; %total # of packets arrive (Being generated) 
     txcount = 0; %total # of transmission attempted
     etecount = 0;%total # of packets reachs destination 
     ltlcount = 0;%total # of packets are successfully received
     
     
     for idxT = 1:Nt

        for SrcNode = 1:Mnum
            %%%%%%%% First Process the Node State %%%%%%%%%%%%%%%%%
            
            TempPkt = Pkt;
            TempPkt.Src = SrcNode;
            TempPkt.Tsrc = SrcNode;
            TempPkt.Type = Normal;
            TempPkt.State = Ready;
            % Get number of arriving packets as per Poisson Dist.
            NumPkts = poissonTx(R); % As per Arrival Rate as per Poisson DB
            if NumPkts == 0
                continue; % If new arrival pkts = 0, go to next node
            end
            nHops = randi([1,Nodes(SrcNode).Mhops],1,NumPkts);
            for i = 1:NumPkts
                PossDes = nodes_with_n_hops(Links, SrcNode, nHops(i));
                TempPkt.Des = PossDes(randi(length(PossDes)));
                RouteDes = route(SrcNode, TempPkt.Des, Links);
                TempPkt.Tdes = RouteDes(2);
                MoreCap = Links(TempPkt.Tsrc,TempPkt.Tdes);
                %Sien: add the line to create a packet data
                TempPkt.Data=create_packet(1);
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
            
            % Count total # of packets being generated
            pktcount = pktcount + NumPkts; 
        end


%%%%%%%%%%%%%%%%%%%%% Schedule the packet %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

        for i = 1:Mnum
            TransPkt = Nodes(i).McFQ.len + Nodes(i).LcFQ.len + Nodes(i).McLQ.len + Nodes(i).LcLQ.len; % Total no. of packets in the node queues
            
            if(TransPkt == 0)
                continue;
            end
            % As per the discussion, we must try to schedule MCL-LCL combo
            % first. If no LCL rider packet is available, we end up
            % scheduling MCL-MCL rider packets in MCB and LCB. Restructuring
            % if-elseif for more efficient implementation. 
            % Check if there is an LCL rider packet available. 
            
            if(Nodes(i).TxLCB.State == Invalid) % LCL Rider Buffer Empty
                % Check for LCL rider Local packet queue first
                if (Nodes(i).LcLQ.len > 0 && Nodes(i).LcLQ.Pkts(1).State == Ready)
                    [Nodes(i).TxLCB, Nodes(i).LcLQ] = schd_pkt(Nodes(i).TxLCB, Nodes(i).LcLQ);
                    % Check for LCL rider Fwd packet queue next
                elseif (Nodes(i).LcFQ.len > 0 && Nodes(i).LcFQ.Pkts(1).State == Ready)
                    [Nodes(i).TxLCB, Nodes(i).LcFQ] = schd_pkt(Nodes(i).TxLCB, Nodes(i).LcFQ);
                    % If no LCL Local packet available, try MCL Local packet
                elseif (Nodes(i).McLQ.len > 0 && Nodes(i).McLQ.Pkts(1).State == Ready)
                    [Nodes(i).TxLCB, Nodes(i).McLQ] = schd_pkt(Nodes(i).TxLCB, Nodes(i).McLQ);
                    % If no MCL Local packet available, try MCL FWD packet
                elseif (Nodes(i).McFQ.len > 0 && Nodes(i).McFQ.Pkts(1).State == Ready)
                    [Nodes(i).TxLCB, Nodes(i).McFQ] = schd_pkt(Nodes(i).TxLCB, Nodes(i).McFQ);
                end
                % Since TransPkt > 0, at least one of these queues did have
                % packet. Thus, we must run the Node State Machine to
                % update the state of the this node. 
                [Nodes(i)] = update_node_state(Nodes(i), NewPkt); 
            end
             
             if(Nodes(i).TxMCB.State == Invalid) % MCL Rider Buffer Empty
                 % Check for MCL Rider Local Packet Queue First
                if(Nodes(i).McLQ.len > 0 && Nodes(i).McLQ.Pkts(1).State == Ready)
                    [Nodes(i).TxMCB, Nodes(i).McLQ] = schd_pkt(Nodes(i).TxMCB, Nodes(i).McLQ);
                    [Nodes(i)] = update_node_state(Nodes(i), NewPkt); % Nodes(i).State must be BackOff or Ready
                    % Try scheduling a MCL Rider Fwd Packet next
                elseif(Nodes(i).McFQ.len > 0 && Nodes(i).McFQ.Pkts(1).State == Ready)
                    [Nodes(i).TxMCB, Nodes(i).McFQ] = schd_pkt(Nodes(i).TxMCB, Nodes(i).McFQ);
                    [Nodes(i)] = update_node_state(Nodes(i), NewPkt); % Nodes(i).State must be BackOff or Ready
                end
            end
        end
        
%%%%%%%%%%%%%%%%%%%%Scheduling the Packet Ends Here %%%%%%%%%%%%%%%%%%%%%%%        

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % From this point on, for all the further purposes, one can assume
        % that the packets are scheduled in TxMCB and TxLCB of the Nodes.
        % The further routines must check Tx.MCB.State = Ready and
        % TxLCB.State = Ready to make sure that the packets in these buffers
        % valid for transmission. There are few changes that we may to do
        % in the packet scheduling. But it would not affect the processing
        % that we need to do from here on. 
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Summarize the transmission activity in each node in the activity 
        %tables; then, evaluate if collision occurs
        
        MCPactivity=zeros(1,Mnum);
        LCPactivity=zeros(1,Mnum);

        %Find out the activity in each node
        for i=1:Mnum
            
            if (Nodes(i).State ~= Ready2Tx)
                % Skip collision check in case the Node is in Backoff or NoPkt
                % state. Consider only the nodes in Ready2Tx State
                continue;
            end   
            
            if (Nodes(i).TxMCB.State == Ready)
                MCPactivity(i) = Nodes(i).TxMCB.Tdes;
                % If the node is not in backoff
                txcount = txcount + 1;  
            end
            if (Nodes(i).TxLCB.State == Ready)
                LCPactivity(i) = Nodes(i).TxLCB.Tdes;
                txcount = txcount + 1;
            end
        end    

        %Evaluation the activities to detection collision
        MCPC = collision_detect(Links,MCPactivity);
        LCPC = collision_detect(Links,LCPactivity);
        
        %Change the node and packets status when collision occurs and set
        %the node state to collision right now so that it does not
        %participate in the tx process. We would take care of dropping
        %packet at the end when we process the states of all the nodes at
        %once. 
        for i=1:Mnum
           if (MCPC(i) == 1)
               Nodes(i).TxMCB.State = Colli;
               [Nodes(i)] = update_node_state(Nodes(i), Collision);
           end
           
           if (LCPC(i) == 1)
               Nodes(i).TxLCB.State = Colli;
               [Nodes(i)] = update_node_state(Nodes(i), Collision);
           end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Transmit any packets that did not experience collision
        % 
        % NOTE: not sure yet how to deal with results from simulcast_txrx
        % or how to format "packet" input for simulcast_txrx/unicast_txrx
        %
        % Once I know that, 
        
        for i=1:Mnum
            if (Nodes(i).State == Ready2Tx) % backoff slot not in the future
                if (Nodes(i).TxMCB.State == Ready && Nodes(i).TxLCB.State == Ready) %Sien: Shall we check the retry here?
                   % simulcast
                   % junk is a variable to hold results I don't care about,
                   % if everyone had 2009b we could use ~ to ignore
                   % specific return values
                   [junk,junk,junk,junk,lcbm_err,junk,mcbm_err,mcam_err] =...
                       simulcast_txrx(Nodes(i).TxMCB.Data, Nodes(i).TxLCB.Data,...
                       Links(Nodes(i).TxMCB.Tsrc, Nodes(i).TxMCB.Tdes),...
                       Links(Nodes(i).TxLCB.Tsrc, Nodes(i).TxLCB.Tdes),...
                       Theta);                   
                   %
                   %Case 1: for both packets are going to MC node
                   %
                   if (Nodes(i).TxMCB.Tdes == Nodes(i).TxLCB.Tdes) 
                       %Sien: packet only has error when err == -1
                       if (mcbm_err == -1 && Nodes(i).TxLCB.Rtr > Rmax) %Reach Max retry
                           % delete packet
                           Nodes(i).TxLCB = Pkt;
                           [Nodes(i)] = update_node_state(Nodes(i), DropPkt);
                           %No need to deal with the case of retry < max, since 
                           %Retransmission will occur after back-off
                       elseif (mcbm_err ~= -1 && Nodes(i).TxLCB.Tdes == Nodes(i).TxLCB.Des)
                           %Case when the packet reach its final
                           %destination, delete the packet and update the
                           %both end to end and link to link throughput counters.               
                           Nodes(i).TxLCB.State = Invalid;%
                           etecount = etecount + 1;
                           ltlcount = ltlcount + 1;
                       elseif (mcbm_err ~= -1) % base packet to MC node received                                                                                 
                           mypkt = Nodes(i).TxLCB;
                           mypkt.Tsrc = mypkt.Tdes;
                           RouteDes = route(mypkt.Tsrc, mypkt.Des, Links);
                           mypkt.Tdes = RouteDes(2);
                           
                           %Set the Tx buffer to empty                           
                           Nodes(i).TxLCB.State = Invalid;
                                                    
                           %Now the mypkt.Tsrc is the formal reciver Node
                           %ID
                           len = Nodes(mypkt.Tsrc).RxBuf.len+1;
                           Nodes(mypkt.Tsrc).RxBuf.Pkts(len) = mypkt;
                           Nodes(mypkt.Tsrc).RxBuf.len = len;
                           
                           %increment Link to Link throughput
                           ltlcount = ltlcount + 1;                           

                       end %End of Case 1
                       
                   else %Case 2: for the base mesage is going to LC node                                                    
                        if (lcbm_err == -1 && Nodes(i).TxLCB.Rtr > Rmax) %Reach Max retry
                            % delete packet == set the packet to invalid 
                            Nodes(i).TxLCB.State = Invalid;
                            %No need to deal with the case of retry < max, since 
                            %Retransmission will occur after back-off
                        elseif (lcbm_err ~= -1 && Nodes(i).TxLCB.Tdes == Nodes(i).TxLCB.Des)
                            Nodes(i).TxLCB.State = Invalid;
                            %Need to increment End-to-End and Link-to-Link throughput
                            %counter
                            etecount = etecount + 1;
                            ltlcount = ltlcount + 1;
                        elseif (lcbm_err ~= -1) % base packet to MC node received                          
                            mypkt = Nodes(i).TxLCB;
                            mypkt.Tsrc = mypkt.Tdes;
                            RouteDes = route(mypkt.Tsrc, mypkt.Des, Links);
                            mypkt.Tdes = RouteDes(2);
                                                        
                            Nodes(i).TxLCB.State = Invalid;
                            % now how do we "assign" this packet to the
                            % right Tx queue on the receiving node?
                           
                            %Now the mypkt.Tsrc is the formal reciver Node
                            %ID
                            len = Nodes(mypkt.Tsrc).RxBuf.len+1;
                            Nodes(mypkt.Tsrc).RxBuf.Pkts(len) = mypkt;
                            Nodes(mypkt.Tsrc).RxBuf.len = len;
                            
                            ltlcount = ltlcount + 1;
                        end
                   end %End of Case 2                        
                   %Case 3: to check the additional message for the MC node                   
                   if (mcam_err == -1 && Nodes(i).TxMCB.Rtr > Rmax) 
                        Nodes(i).TxMCB.State = Invalid;
                       % delete packet
                   elseif (mcam_err ~= -1 && Nodes(i).TxMCB.Tdes == Nodes(i).TxMCB.Des)
                       Nodes(i).TxMCB.State = Invalid;
                       %Update Both throughput counter
                       etecount = etecount + 1;
                       ltlcount = ltlcount + 1;
                   elseif (mcam_err == -1) % add packet to receiving node's queue
                       mypkt = Nodes(i).TxMCB;
                       mypkt.Tsrc = mypkt.Tdes;
                       mypkt.Tdes = route(mypkt.Tsrc, mypkt.Des, Links);
                       
                       Nodes(i).TxMCB.State = Invalid;
                       
                       %Sien: Assign the proper queue
                       len = Nodes(mypkt.Tsrc).RxBuf.len+1;
                       Nodes(mypkt.Tsrc).RxBuf.Pkts(len) = mypkt;
                       Nodes(mypkt.Tsrc).RxBuf.len = len;
                       
                       %Update Link to Link throughput
                       ltlcount = ltlcount + 1;
                   end %End of Case 3 
                                      
                elseif (Nodes(i).TxMCB.State == Ready) % unicast MC packet
                    [bm,uni_err] = unicast_txrx(Nodes(i).TxMCB.Data,...
                        Links(Nodes(i).TxMCB.Tsrc, Nodes(i).TxMCB.Tdes));
                                                                                                                 
                   if (uni_err == -1 && Nodes(i).TxMCB.Rtr > Rmax) 
                        Nodes(i).TxMCB.State = Invalid;
                       % delete packet
                   elseif (uni_err ~= -1 && Nodes(i).TxMCB.Tdes == Nodes(i).TxMCB.Des)    
                       Nodes(i).TxMCB.State = Invalid;
                       %Update ETE and LTL throughput
                       etecount = etecount + 1;
                       ltlcount = ltlcount + 1;
                   elseif (uni_err ~= -1) % unicast packet received
                       mypkt = Nodes(i).TxMCB;
                       mypkt.Tsrc = mypkt.Tdes;
                       RouteDes = route(mypkt.Tsrc, mypkt.Des, Links);
                       mypkt.Tdes = RouteDes(2);
                       
                       Nodes(i).TxMCB.State = Invalid;
                       
                       %Sien: Assign the proper queue
                       len = Nodes(mypkt.Tsrc).RxBuf.len+1;
                       Nodes(mypkt.Tsrc).RxBuf.Pkts(len) = mypkt;
                       Nodes(mypkt.Tsrc).RxBuf.len = len;
                       
                       %increment link to link throughput
                       ltlcount = ltlcount + 1;
                   end %End of Case 3 
                                                         
                elseif (Nodes(i).TxLCB.State == Ready) % unicast LC packet
                    
                    [junk,uni_err] = unicast_txrx(Nodes(i).TxLCB.Data,...
                        Links(Nodes(i).TxLCB.Tsrc, Nodes(i).TxLCB.Tdes));

                     if (uni_err == -1 && Nodes(i).TxLCB.Rtr > Rmax) %Reach Max retry
                            % delete packet == set the packet to invalid 
                            Nodes(i).TxLCB.State = Invalid;
                            %No need to deal with the case of retry < max, since 
                            %Retransmission will occur after back-off
                     elseif (uni_err ~= -1 && Nodes(i).TxLCB.Tdes == Nodes(i).TxLCB.Des) 
                            Nodes(i).TxLCB.State = Invalid;
                            %Update ETE LTL throughput
                            etecount = etecount + 1;
                            ltlcount = ltlcount + 1;
                     elseif (uni_err ~= -1) % base packet to MC node received                          
                            mypkt = Nodes(i).TxLCB;
                            mypkt.Tsrc = mypkt.Tdes;
                            RouteDes = route(mypkt.Tsrc, mypkt.Des, Links);
                            mypkt.Tdes = RouteDes(2);

                            
                            Nodes(i).TxLCB.State = Invalid;
                            
                            %Now the mypkt.Tsrc is the formal reciver Node
                            %ID
                            len = Nodes(mypkt.Tsrc).RxBuf.len+1;
                            Nodes(mypkt.Tsrc).RxBuf.Pkts(len) = mypkt;
                            Nodes(mypkt.Tsrc).RxBuf.len = len;
                                                                                   
                            %Increment Link to Link                           
                            ltlcount = ltlcount + 1;
                      end
                %Sien: all cases should be taken care, no need for else                                           
                %else 
                %    ; % not in backoff and nothing to send
                end
            end
        end
        
     % Post Transmission Packet Processing
     % Things ToDo here ----- (Sien: the following task was done in the loop)
        % If Pkt.Des = Pkt.Tdes, destination reached. Increment the End to
        % End throughput counter. Else, increment Link Throughput counter. 
        % Expire packets that have collided > max retries
        
        %Post Processing the successfully received packet
        for i=1:Mnum
            while (Nodes(i).RxBuf.len > 0)
                mypkt = Nodes(i).RxBuf.Pkts(Nodes(i).RxBuf.len);
            %    if(mypkt.State == Invalid)
            %        len = Nodes(i).RxBuf.len - 1;
            %        Nodes(i).RxBuf.len = len;
            %        continue;
            %    end
                MoreCap = Links(mypkt.Tsrc,mypkt.Tdes);
                if (MoreCap > 0)
                    len = Nodes(i).McFQ.len;
                    Nodes(i).McFQ.Pkts(len+1)=mypkt;
                    Nodes(i).McFQ.len = len + 1;
                else
                    len = Nodes(i).LcFQ.len;
                    Nodes(i).LcFQ.Pkts(len+1)=mypkt;
                    Nodes(i).LcFQ.len = len + 1;                               
                end
                %clear Nodes(i).RxBuf.Pkts(Nodes(i).RxBuf.len) mypkt;
                len = Nodes(i).RxBuf.len - 1;
                Nodes(i).RxBuf.len = len;
            end
        end
        
         % Evaluate collisions and schedule retransmission slot
        % ceil(2^(num. of collisions)*rand(1)) is the binary exponential
        % backoff delay in # of slots
        
     end % for idxT = 1:Nt
     % Performance Graph code goes here
 end % for idxS = 1:Ns
 t2=clock;
 Sim_time = etime(t2,t1)