function [node] = update_node_state(node, event)
% Node State Machine
% node.State belongs to {NoPkt,Ready2Tx,BackOff} states
% event belongs to {NewPkt,Collision,TxSuccess} events
global NoPkt Ready2Tx BackOff
global NewPkt Collision TxSuccess OneSlot
global idxT
global CWmax CWmin
% Some of the node.State and event combinations may be irrelavent in the
% sense that they are not supposed to occur. We shall just ignore them by
% not doing anything in those cases but retain their handle in the switch
% routines if we need them at all. 


switch(node.State)
    %%%%% The node did not have any packet to transmit before this %%%%%%%
    case NoPkt 
        switch (event)
            case NewPkt                                
                % This event is possible either due to an MCB packet
                % scheduling or an LCB schdueling.
                CW = randi([0,2^CWmin-1]);
                node.BoS = CW + idxT;
                if(CW == 0) % Allow the packet to transmit in same slot
                    node.State = Ready2Tx;
                else
                    node.BoS = BackOff;
                end
            
            otherwise
                disp('Error: Unexpected event in NoPkt State!');
%                 dbstop; % stop the execution for debugging. 
        end %switch(event) ends here
    %%%%%%%%%%%%%%% End of node.State = NewPkt %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%% The node has passed the Back Off stage. Ready to Tx. %%%%%%%
    
    case Ready2Tx
        switch (event)
            case NewPkt
                % This case can occur when the node was about to tranmit
                % a packet from LCB in the present slot and there was an
                % arrival of a new packet which got scheduled on the MCB.
                % In such case, since the node has already passed the back
                % off window slots, there is a good probability that
                % keeping the node into same state would result in
                % successful transmission of both the packets. Thus, we do
                % not change the state of the node. 
                
                node.State = Ready2Tx;
                if (node.BoS ~= idxT)
                    disp('Error: Node State Ready2Tx but BoS not idxT!');
%                     dbstop; % stop the execution for debugging
                end         

            case Collision
                % Node experienced a collision with atleast one of the
                % packets. Get the number of retries from both the packets
                % and move the node to the BoS which is higher among two. 
                Rtr = max(node.TxMCB.Rtr, node.TxLCB.Rtr);
                switch(Rtr)
                    case 1
                        CW = 2^(CWmin + Rtr);
                        node.BoS = randi([1,CW]) + idxT;
                    case 2
                        CW = 2^(CWmin + Rtr);
                        node.BoS = randi([1,CW]) + idxT;
                        % Cap the contention window to CWmax from 
                    otherwise
                        CW = 2^CWmax;
                        node.BoS = randi([1,CW]) + idxT;
                end
                % Set the state of the node as per BOS
                if(node.BoS > (idxT+1))
                    node.State = BackOff;
                    % The node is set to transmit in next slot. Change the
                    % state to Ready2Tx
                elseif(node.BoS == (idxT+1))
                    node.State = Ready2Tx;
                end
                
            case TxSuccess
                % Both the packets got tx successfully or the node had only
                % one packet to tx which was successful. Node has no more
                % packet to transmit. 
                node.State = NoPkt;
                % Sanity Check to make sure that node's state and idxT do
                % not have discrepancies. If node was in Ready2Tx, it must
                % have BoS = idxt. Reset the BoS or produce an error. 
                if (node.BoS == idxT)
                    node.BoS = 0;
                else
                    disp('Node state Ready2Tx but BoS != idxT!');
                end
            otherwise
                disp('Suprious Event');
%                 dbstop; % stop the execution for debugging. 
        end %switch(event) ends here
    
   %%%%%%%%%%%%%% End of node.State = Ready2Tx %%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   %%%%%%%%%%%%%%% The node is in BackOff state right now %%%%%%%%%%%%%%%%%
        
    case BackOff
        switch (event)
            case NewPkt
                % This case can occur when the node was in Back off state
                % with a packet in one of LCB or MCB. This situation may
                % arise when only packet during last tranmission suffers
                % collision while other one gets tx successfully. In that
                % case, the node would wait in the same Back - Off state
                % and allow the new packet to ride along with the old
                % packet in the same contention window. 
                
                node.State = BackOff;                
                
            case OneSlot
                % Node just went through one slot of waiting period.
                % Check if it is equal to idxT + 1. If so, it is supposed
                % to transmit in next slot.So, move it into Ready2Tx state.
                
                if (node.BoS == idxT+1)
                    node.State = Ready2Tx;
                end
                
            otherwise
                disp('Suprious Event');
%                 dbstop; % stop the execution for debugging. 
                
                
        end %switch(event) ends here
        
   %%%%%%%%%%%%%% End of node.State = BackOff %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
end % switch (node.State) ends here
    
end % Function update_node_state ends here