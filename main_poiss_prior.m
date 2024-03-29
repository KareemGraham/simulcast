
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
 global Pr
 
 Wired = 0;     %Simulate Wired Network
 CntStart = 1000; %Slot where counters are enabled
 
 % Node parameters
 
 Mnum   = 15;       % Number of nodes on network
 Xmax   = 1000;      % X dimension of area in meters
 Ymax   = 1000;      % Y dimension of area in meters
 Sig    = 0;        % STD distribution of nodes in the area

  Attempt_tot = 0;
  iAttempts_tot = zeros(1,Mnum);
  iLinkCount = zeros(1,Mnum);

 % Declaring Slotted ALOHA Network Parameters
 brate  = 512e3;    % Bit rate
 Srate  = 256e3;    % Symbol rate
 Plen   = 923;      % Packet Length in bits
 R      = 1;   % Arrival Rate of packets at node
 % It is calculated as Offered Normalized Load/ No. of Nodes. So if the
 % normalized Load is 1, the number of packets each node would schedule to
 % transmit in Mnum slots should be only 1. Thus, on an average, the number
 % of packets tranmitted in each slot is 1/Mnum by each node. 
 S      = 0;        % Network throughput
 RT     = 4;        % Maximum No. of retries for a packet before dropping
 n      = 4;        % Path Loss Exponent
 %CWmin  = 2;        % 2^4 - 1 = 0-15 slots KILL THEM
 %CWmax  = 4;        % 0-64 slots
 Pr     = 0;      % Introducing the world famous Pr as the probability of
                    % retransmission in next slot
 
 % Simulcast Parameters
 Theta  = 19.25;       % Offset angle in degrees
 Dmax   = 381;
 
 % Simulation Parameters
 %Prs = [10^-3:10^-3:10^-2 2*10^-2:0.5*10^-2:10^-1 2*10^-1:10^-1:10^-0];
 Prs = logspace(-3,0,20);
 
 Nt     = 2500;     % Number of time slots simulated for each topology
 Ns     = length(Prs);        % Number of topology simulations
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
 
 global Invalid Ready TxS TxF Colli Retry Rmax

 Invalid= 0;        % Packet is invalid
 Ready  = 1;        % Packet ready to be transmitted
 TxS    = 2;        % Packet Transmission Successful
 TxF    = 3;
 Colli  = 4;        % Packet Collision
 Retry  = 5;        % Packet Needs to be retransmitted (State after Colli?)
 Rmax   = 6;        % Packet retry limit reached, drop the packet (RT = 7)
 
 
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
 global NewPkt Collision TxSuccess OneSlot
 NewPkt = 1;
 Collision = 2;
 TxSuccess = 3;
 OneSlot = 4;
  
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
 
 BoffNodes = zeros(Mnum,1);
 
 NumTopo = 15; % Number of topologies for each Theta
 
 datestring = datestr(now,'dd-mm-yyyy-HHMMSS');
 % Start Topology Simulation
 for Theta = [0:5:45 19.25]
             S = ['mkdir ',datestring,'\','Theta-',num2str(Theta)];
             eval(S);
     for idxNT = 1:NumTopo
             close all
             AvgLink2LinkT = zeros(Ns,1);
             AvgAttempt_rateT = zeros(Ns,1);
             End2EndT = zeros(Ns,1);
             [nodeXY, Links, Mh] = topo(Mnum, Xmax, Ymax, Sig, Theta, dF);

             for idxS = 1:Ns,
                     Pr = Prs(idxS);
                     R = Pr;
                     %Pr = rand;
                     if(Wired)
                         Theta = 0;
                     end
                     % Get the node distribution, link table and max. no. of hops for each
                     % node
                     Nodes(1:Mnum) = Node; % Clear all the nodes when simulating new topology

                     pause(.001);    
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
                         %clc

                         if(idxT == CntStart || idxT == 1)
                             ltlcount = 0;
                             iLinkCount = zeros(1,Mnum);
                             pktcount = 0;
                             iattempt_rate = 0;
                             iLink2Link = 0;
                             iAttempts_tot = 0;
                             etecount = 0;
                         end
                        Slot = idxT;
                        if(idxT > CntStart)
                            Link2Link = ltlcount/(idxT-CntStart)/Mnum;
                            iLink2Link= iLinkCount/(idxT-CntStart);
                            AvgLink2Link = mean(iLink2Link);
                            End2End = etecount/(idxT-CntStart)/Mnum;
                            attempt_rate = Attempt_tot/(idxT-CntStart);
                            iattempt_rate = iAttempts_tot/(idxT-CntStart);
                            AvgAttempt_rate = mean(iattempt_rate);
                        end


                        for SrcNode = 1:Mnum
                            %%%%%%%% First Process the Node State %%%%%%%%%%%%%%%%%
                            BoffNodes(SrcNode) = Nodes(SrcNode).State == BackOff;
                            iLinkCount(SrcNode) = Nodes(SrcNode).LinkCount;

                            TempPkt = Pkt;
                            TempPkt.Src = SrcNode;
                            TempPkt.Tsrc = SrcNode;
                            TempPkt.Type = Normal;
                            TempPkt.State = Ready;
                            % Get number of arriving packets as per Bernoulli Distribution
                            NumPkts = binornd(1,R); % R is the Arrival Rate
                            if NumPkts == 0
                                continue; % If new arrival pkts = 0, go to next node
                            end
                            
%                            nHops = randi([1,Nodes(SrcNode).Mhops],1,NumPkts);
 
                            Gamma = Nodes(SrcNode).Mhops/2;
                            nHops = poissrnd(Gamma/(cos(Theta*pi/180)^(4/n)),1,NumPkts);
                            nHops(nHops < 1) = 1;
                            nHops(nHops > Nodes(SrcNode).Mhops) = Nodes(SrcNode).Mhops;
                            
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
                                 
                                    % Try scheduling a MCL Rider Fwd Packet next
                                if(Nodes(i).McFQ.len > 0 && Nodes(i).McFQ.Pkts(1).State == Ready)
                                    [Nodes(i).TxMCB, Nodes(i).McFQ] = schd_pkt(Nodes(i).TxMCB, Nodes(i).McFQ);
                                    [Nodes(i)] = update_node_state(Nodes(i), NewPkt); % Nodes(i).State must be BackOff or Ready
                                 % Check for MCL Rider Local Packet Queue First
                                elseif(Nodes(i).McLQ.len > 0 && Nodes(i).McLQ.Pkts(1).State == Ready)
                                    [Nodes(i).TxMCB, Nodes(i).McLQ] = schd_pkt(Nodes(i).TxMCB, Nodes(i).McLQ);
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
                            end
                            if (Nodes(i).TxLCB.State == Ready)
                                LCPactivity(i) = Nodes(i).TxLCB.Tdes;
                            end
                        end    
                        %Evaluation the activities to detection collision
                        MCPC = collision_detect(Links,MCPactivity);
                        LCPC = collision_detect(Links,LCPactivity);
                        if(Wired)
                            Theta = 0;
                            if(length(find(MCPactivity, 2)) > 1)
                                MCPC = MCPactivity > 0;
                            end
                            if(length(find(LCPactivity, 2)) > 1)
                                LCPC = LCPactivity > 0;
                            end
                        end
                        iAttempts = (MCPactivity > 0) + (LCPactivity > 0) > 0;
                        Attempts = sum(iAttempts);
                        %Attempts = (length(find(MCPactivity)) + length(find(LCPactivity)));
                        iAttempts_tot = iAttempts_tot + iAttempts; 
                        Attempt_tot = Attempts + Attempt_tot;

                        % Change the packets status when collision occurs so that it does not
                        % participate in the tx process. 

                        for i=1:Mnum
                           if (MCPC(i) > 0)
                               txcount = txcount + 1;
                               Nodes(i).TxMCB.State = Colli;
                           end
                           if (LCPC(i) > 0)
                               txcount = txcount + 1;
                               Nodes(i).TxLCB.State = Colli;
                           end
                        end

                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % Transmit any packets that did not experience collision

                        for i=1:Mnum
                            if (Nodes(i).State == Ready2Tx) % Only process Nodes Ready2Tx
                                if (Nodes(i).TxMCB.State == Ready && Nodes(i).TxLCB.State == Ready) %Sien: Shall we check the retry here?
                                   % simulcast
                                     [~,~,~,~,lcbm_err,~,~,mcam_err] =...
                                       simulcast_txrx(Nodes(i).TxMCB.Data, Nodes(i).TxLCB.Data,...
                                       Links(Nodes(i).TxMCB.Tsrc, Nodes(i).TxMCB.Tdes),...
                                       Links(Nodes(i).TxLCB.Tsrc, Nodes(i).TxLCB.Tdes),...
                                       Theta);
                                   txcount = txcount + 2; % Tx attempt of two packets

                                   switch (lcbm_err) % Check base message tx status
                                       case (-1) % Tx failure due to > 10 errors
                                           % Just flag the packet as per failure or success
                                           Nodes(i).TxLCB.State = TxF;
                                       otherwise
                                           Nodes(i).TxLCB.State = TxS;
                                           ltlcount = ltlcount + 1; % Increment global counter
                                   end

                                   switch (mcam_err) % Check additional message tx status 
                                       case (-1) % Tx failure due to > 10 errors 
                                           Nodes(i).TxMCB.State = TxF; 
                                       otherwise
                                           Nodes(i).TxMCB.State = TxS; 
                                           ltlcount = ltlcount + 1; % Increment global counter
                                   end

                                   % Unicast on Less Capable Link
                                elseif (Nodes(i).TxLCB.State == Ready)
                                    [~,uni_err] = unicast_txrx(Nodes(i).TxLCB.Data,...
                                        Links(Nodes(i).TxLCB.Tsrc, Nodes(i).TxLCB.Tdes));
                                    txcount = txcount + 1; % Tx attempt of one packet
                                    switch (uni_err) 
                                        case (-1) % Tx failure due to > 10 errors 
                                            % Just flag the packet for failure or success 
                                            Nodes(i).TxLCB.State = TxF;
                                        otherwise
                                            Nodes(i).TxLCB.State = TxS;
                                            ltlcount = ltlcount + 1; % Increment global counter
                                    end

                                    % Unicast on More Capable Link in the absence of other
                                    % packet to tx 
                                elseif (Nodes(i).TxMCB.State == Ready)
                                    [~,uni_err] = unicast_txrx(Nodes(i).TxMCB.Data,...
                                        Links(Nodes(i).TxMCB.Tsrc, Nodes(i).TxMCB.Tdes));
                                    txcount = txcount + 1; % Tx attempt of one packet
                                    switch (uni_err)
                                        case (-1) % Tx failure due to > 10 errors 
                                            % Just flag the packet as per error or success
                                            Nodes(i).TxMCB.State = TxF;
                                        otherwise
                                            Nodes(i).TxMCB.State = TxS;
                                            ltlcount = ltlcount + 1; % Increment global counter
                                    end
                                end % End of processing ready to Tx Packet buffers
                            end % End of processing Ready2Tx Nodes
                        end % End of node counter


                     % Post Transmission Packet Processing
                         for i = 1:Mnum;
                         % Ideally, only the nodes which are in Ready2Tx state should have
                         % successful or failed packets. Process these packets and node
                         % states
                         if (Nodes(i).State ~= Ready2Tx)
                             continue;
                         end

                         switch (Nodes(i).TxMCB.State)
                             % Packet could be in one of the four states viz. TxS, TxF,
                             % Colli or Invalid. It CANNOT be in Ready or any other State. 

                             case TxS % MCB packet Transmission Successful
                                 if (Nodes(i).TxMCB.Des == Nodes(i).TxMCB.Tdes) % Packet reached final destination
                                     [Nodes(i),Nodes(i).TxMCB] = handle_final_des_pkt(Nodes(i));
                                     etecount = etecount + 1;
                                 else % Packet needs to hop to next destination on the route
                                 % Get the new route from the function
                                 RouteDes = route(Nodes(i).TxMCB.Tdes, Nodes(i).TxMCB.Des, Links);
                                 NextHop = RouteDes(2);
                                 [Nodes(i),Nodes(NextHop),Nodes(i).TxMCB] = handle_next_des_pkt(Nodes(i),Nodes(NextHop),Nodes(i).TxMCB, Links);
                                 end

                             case {TxF,Colli} % MCB Packet Transmission Failed
                                 [Nodes(i),Nodes(i).TxMCB] = handle_failed_pkt(Nodes(i),Nodes(i).TxMCB);
                             case Invalid
                                 % Packet did not participate in tx process. Do nothing. 
                                 NOP = 0;
                             otherwise
                                 disp('Error: Packet is in unexpected state!');
                                 Nodes(i) % Print Node
                                 Nodes(i).TxMCB % Print Packet
                                 Nodes(i).TxLCB % Print Packet
                                 dbstop;
                         end

                         % LCB Tx Packet Processing
                         switch (Nodes(i).TxLCB.State)
                             case TxS % LCB Pakcet Tx Successful
                                 if (Nodes(i).TxLCB.Des == Nodes(i).TxLCB.Tdes) % Packet reached final destination
                                     [Nodes(i),Nodes(i).TxLCB] = handle_final_des_pkt(Nodes(i));
                                     etecount = etecount + 1;
                                 else % Packet needs to hop to next destination on the route
                                     % Get the new route from the function
                                     RouteDes = route(Nodes(i).TxLCB.Tdes, Nodes(i).TxLCB.Des, Links);
                                     NextHop = RouteDes(2);
                                     [Nodes(i),Nodes(NextHop),Nodes(i).TxLCB] = handle_next_des_pkt(Nodes(i),Nodes(NextHop),Nodes(i).TxLCB, Links);
                                 end

                             case {TxF,Colli} % LCB Packet Tx Failed
                                 [Nodes(i),Nodes(i).TxLCB] = handle_failed_pkt(Nodes(i),Nodes(i).TxLCB);
                             case Invalid % LCB Packet did not participate in Tx
                                 NOP = 0;
                             otherwise
                                 disp('Error: Packet is in unexpected state!');
                                 Nodes(i) % Print Node
                                 Nodes(i).TxMCB % Print Packet
                                 Nodes(i).TxLCB % Print Packet
                                 dbstop;
                         end
                        end

                         for i = 1:Mnum
                             switch(Nodes(i).State)
                                 case Ready2Tx
                                     if (Nodes(i).TxMCB.State == Invalid && Nodes(i).TxLCB.State == Invalid)
                                         % No packet to transmit or both the packets got
                                         % dropped due to collision. Packets have been cleared
                                         % but maintain the BoS in update node state routine. 
                                         Nodes(i) = update_node_state(Nodes(i), TxSuccess);
                                     elseif (Nodes(i).TxMCB.State == Invalid && Nodes(i).TxLCB.State == Ready)
                                         % Indicates a collision. Move to BackOff State
                                         Nodes(i) = update_node_state(Nodes(i), Collision);
                                     elseif (Nodes(i).TxMCB.State == Ready && Nodes(i).TxLCB.State == Invalid)
                                         % Indicates a collision on MCB. Move to BackOff State
                                         Nodes(i) = update_node_state(Nodes(i), Collision);
                                     elseif (Nodes(i).TxMCB.State == Ready && Nodes(i).TxLCB.State == Ready)
                                         Nodes(i) = update_node_state(Nodes(i), Collision);
                                     else % Packet is not expected to be in any other state at this point
                                         disp('Error: Packet is in unexpected state!');
                                         Nodes(i) % Print Node
                                         Nodes(i).TxMCB % Print Packet
                                         Nodes(i).TxLCB % Print Packet
                                         dbstop;
                                     end
                                 case BackOff
                                     % If node was in BackOff State, atleast one packet should
                                     % be Ready. Just decrement the BoS in that case. Else
                                     % there was something wrong. 
                                     if ((Nodes(i).TxMCB.State == Ready && Nodes(i).TxLCB.State == Ready)...
                                             ||(Nodes(i).TxMCB.State == Invalid && Nodes(i).TxLCB.State == Ready)...
                                             ||(Nodes(i).TxMCB.State == Ready && Nodes(i).TxLCB.State == Invalid))
                                         Nodes(i) = update_node_state(Nodes(i), OneSlot);
                                     else
                                         disp('Error: Packet is in unexpected state!');
                                         Nodes(i) % Print Node
                                         Nodes(i).TxMCB % Print Packet
                                         Nodes(i).TxLCB % Print Packet
                                         dbstop;
                                     end
                                 case NoPkt
                                     % Just make sure that both the packets should be in
                                     % Invalid state. Otherwise give an error. 
                                     if (Nodes(i).TxMCB.State ~= Invalid || Nodes(i).TxLCB.State ~= Invalid)
                                         disp('Error: Packet is in unexpected state!');
                                         Nodes(i) % Print Node
                                         Nodes(i).TxMCB % Print Packet
                                         Nodes(i).TxLCB % Print Packet
                                         dbstop;
                                     end
                             end
                         end
                     end % for idxT = 1:Nt
                     % Performance Graph code goes here
                     AvgLink2LinkT(idxS) = AvgLink2Link;
                     AvgAttempt_rateT(idxS) = AvgAttempt_rate;
                     End2EndT(idxS) = End2End;
              end % for idxS = 1:Ns
             XY = sortrows([AvgAttempt_rateT AvgLink2LinkT])';
             X = XY(1,:); Y = XY(2,:);
             semilogx(X,Y,'kx')
             saveas(gcf,[datestring,'\','Theta-',num2str(Theta),'\',num2str(idxNT) '.fig']);
             clear XY Nodes
             S = ['save ',datestring,'\','Theta-',num2str(Theta),'\',num2str(idxNT),'.mat'];
             eval(S)
     end
     close all
     plotavg(datestring,Theta);
     saveas(gcf,[datestring,'\','Theta-',num2str(Theta),'\avg.fig']);    
 end
 t2=clock;
 Sim_time = etime(t2,t1)
