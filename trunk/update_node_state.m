function [node] = update_node_state(node, event)
% Node State Machine
% node.State belongs to {NoPkt,Ready2Tx,BackOff} states
% event belongs to {NewPkt,Collision,TxSuccess} events
global NoPkt Ready2Tx BackOff
global NewPkt Collision TxSuccess DropPkt
global idxT
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
                % scheduling or an LCB schdueling. Ideally, if node.state =
                % NoPkt, it means that it earlier had no packet to
                % transmit. Thus, this is the first time it is entering
                % into contention window (CW) after last successful Tx. Thus,
                % the CW = 0 for this state event. Still, to be cautious,
                % we must get the no. of retries that both the packets have
                % already gone through. If either of them is non zero, we
                % know that there is a problem. To make sure that this
                % event does not occur, we must clear the Tx buffers if
                % packet is successfully tx, or if the packet was dropped
                % due to exceeding the max no. of retries. If packet is
                % still below max. no. of retries, make sure that the
                % node.state = BackOff. 
                CW = max(node.TxMCB.Rtr,node.TxLCB.Rtr); % Ideally, CW = 0;
                if(CW == 0)
                    node.BoS = randi([0 2^(CW)]) + idxT;
                    if(node.BoS == idxT)
                        node.State = Ready2Tx;
                    else
                        node.State = BackOff;  
                    end
                else
                    disp('Error: Unexpected Size of CW!');             
%                     dbstop; % stop the execution for debugging
                end
                
            case Collision
                
                
            case TxSuccess
            
            case DropPkt
            
            otherwise
                disp('Suprious Event');
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
                % This case happens when node was ready to tx in the same
                % slot but experienced a collision. We shall simply put the
                % node into backoff state atand increase the contention
                % window length. The check if the packet has increased the
                % max no. of retries is done later at the end of the loop
                % in main program during node state update. 
                
                node.State = BackOff;
                % Any of the packets may have suffered collision. We must
                % check the both.           
                if (node.TxMCB.State == Colli)
                    CW = node.TxMCB.Rtr + 1;
                    node.TxMCB.Rtr = CW;
                    node.BoS = randi([1,2^CW]) + idxT; % Slot increment from 0 or 1? 
                elseif (node.TxLCB.State == Colli)
                    CW = node.TxLCB.Rtr + 1;
                    node.TxLCB.Rtr = CW;
                    node.BoS = randi([1,2^CW]) + idxT; % Slot increment from 0 or 1? 
                end
                
            case TxSuccess
                % If a packet got transmitted successfully, the NSM must
                % check if the node still has another valid packet in other
                % buffer. 
            
            case DropPkt
                % The node tried transmitting but 
                
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
                
            case Collision
                
            case TxSuccess
            
            case DropPkt
                
            otherwise
                disp('Suprious Event');
%                 dbstop; % stop the execution for debugging. 
                
                
        end %switch(event) ends here
        
   %%%%%%%%%%%%%% End of node.State = BackOff %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
end % switch (node.State) ends here
    
end % Function update_node_state ends here