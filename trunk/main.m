% main.m 
% 
% Simulcast Packet Transmission on an Ad Hoc Network using Slotted ALOHA
% 
% MATLAB version 
% Programmed by Kareem G/Manish Bansal/Sien Wu/Thomas M

 % Declaring Slotted ALOHA Network Parameters
 
 brate  = 512e3;    % Bit rate
 Srate  = 256e3;    % Symbol rate
 Plen   = 128;      % Packet Length in bits
 R      = 0.1;      % Attempt Rate by each node for transmission in a slot
 G      = 1;        % Offered load to the network (???)
 S      = 0;        % Network throughput (???)
 RT     = 7;        % Maximum No. of retries for a packet before dropping
 n      = 4;        % Path Loss Exponent
 
 % Node parameters
 
 Mnum   = 15;       % Number of nodes on network
 Xmax   = 1000;      % X dimension of area in meters
 Ymax   = 1000;      % Y dimension of area in meters
 Sig    = 0;        % STD distribution of nodes in the area
 
 % Simulcast Parameters
 
 Theta  = 30;       % Offset angle in degrees
 Dmax   = 381;
 
 % Simulation Parameters
 
 Nt     = 1500;     % Number of time slots simulated for each topology
 Ns     = 10;       % Number of topology simulations
 dF     = 1;        % drawFigure parameter of topo function fame :)
 
 % Packet States Enum (Not sure how many we need, just initializing)
 
 Ready  = 0;        % Packet ready to be transmitted
 Trans  = 1;        % Packet Transmission Successful
 Colli  = 2;        % Packet Collision
 Retry  = 3;        % Packet Needs to be retransmitted (State after Colli?)
 Rmax   = 4;        % Packet retry limit reached, drop the packet (RT = 7)
 
 % Packet Encapsulation (Do we declare a packet by new_pkt = Pkt???)
 % @Pstate  : Packet State, see Packet States Enum
 % @Pdes    : Packet Destination, Nodes 1-Mnum
 % @Psrc    : Packet Source, Nodes 1-Mnum
 % @Pdata   : Packet data
 
 Pkt    = struct('Pstate', 0, 'Pdes', 0, 'Psrc', 0, 'Pdata', {});
 
 % Start Topology Simulation
 for idxS = 1:Ns,
     % Get the node distribution, link table and max. no. of hops for each
     % node
     [node, links, mhops] = topo(Mnum, Xmax, Ymax, Sig, Theta, dF);
     % Start SALOHA Time Slot Simulation
     for idxT = 1:Nt,
         % Simulate SLOHA Here: ToDo 
     end % for idxT = 1:Nt
     % Performance Graph code goes here
 end % for idxS = 1:Ns