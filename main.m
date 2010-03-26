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
 
 % Packet States Enum (Not sure how many we need, just initializing)
 
 Ready  = 0;        % Packet ready to be transmitted
 Trans  = 1;        % Packet Transmission Successful
 Colli  = 2;        % Packet Collision
 Retry  = 3;        % Packet Needs to be retransmitted (State after Colli?)
 Rmax   = 4;        % Packet retry limit reached, drop the packet (RT = 7)
 
 % Packet Encapsulation (Do we declare a packet by new_pkt = Pkt???)
 % @Pstate  : Packet State, see Packet States Enum @Pdes    : Packet
 % Destination, Nodes 1-Mnum @Psrc    : Packet Source, Nodes 1-Mnum @Pdata
 % : Packet data
 
 Pkt    = struct('Pstate', 0, 'Pdes', 0, 'Psrc', 0, 'Pdata', {});
 
 % Start Topology Simulation
 for idxS = 1:Ns,
     % Get the node distribution, link table and max. no. of hops for each
     % node
     [node, links, mhops] = topo(Mnum, Xmax, Ymax, Sig, Theta, dF);
     
     % Get the Hop Table for each Node. It is denoted as Nodei_Hops, where i
     % is index of the node that table belongs to. Each table is 1*NP. It
     % consists of uniform random distribution of the hops that a packet
     % may need to make to reach its destination in range [1,mhops(i)]
     for idxNode = 1:Mnum
         s = ['Node' int2str(idxNode) '_Hops = randi([1,mhops(idxNode)],1,NP);' ];
         eval(s)
     end % for idxNode = 1:Mnum
     
     % Start SALOHA Time Slot Simulation
     for idxT = 1:Nt,
         % Simulate SLOHA Here: ToDo 
     end % for idxT = 1:Nt
     % Performance Graph code goes here
 end % for idxS = 1:Ns