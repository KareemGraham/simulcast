function [node] = update_node_state(node, event)
% Node State Machine
% node.State belongs to {NoPkt,Ready2Tx,BackOff} states
% event belongs to {NewPkt,Collision,TxSuccess} events
global NoPkt Read2Tx BackOff
global NewPkt Collision TxSuccess
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
                % This is a new packet that has been scheduled. We should
                % put the node in First Back Off window in this case and
                % update the node.BoS field accordingly. 
                                
                % This event is possible either due to an MCB packet
                % scheduling or an LCB schdueling. Ideally, if node.state =
                % NoPkt, it means that it earlier had no packet to
                % transmit. Thus, this is the first time it is entering
                % into contention window (CW) after last successful Tx. Thus,
                % the CW = 1 for this state event. Still, to be cautious,
                % we must get the no. of retries that both the packets have
                % already gone through. If either of them is non zero, we
                % know that there is a problem. To make sure that this
                % event does not occur, we must clear the Tx buffers if
                % packet is successfully tx, or if the packet was dropped
                % due to exceeding the max no. of retries. If packet is
                % still below max. no. of retries, make sure that the
                % node.state = BackOff. 
                CW = max(node.TxMCB.Rtr,node.TxLCB.Rtr);
                if(CW == 0)
                    node.State = BackOff;
                    node.BoS = ceil(2^(CW)*rand(1)) + idxT;
                else
                    disp('Unexpected Size of CW');             
                    dbstop; % stop the execution for debugging. 
                
            case Collision
                
                
            case TxSuccess
                
            otherwise
                disp('Suprious Event');
                dbstop; % stop the execution for debugging. 
                
                
        end %switch(event) ends here
    %%%%%%%%%%%%%%% End of node.State = NewPkt %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%% The node has passed the Back Off stage. Ready to Tx. %%%%%%%
    
    case Ready2Tx
        switch (event)
            case NewPkt                
                
            case Collision
                
            case TxSuccess
                
            otherwise
                disp('Suprious Event');
                dbstop; % stop the execution for debugging. 
                
        end %switch(event) ends here
    
   %%%%%%%%%%%%%% End of node.State = Ready2Tx %%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   %%%%%%%%%%%%%%% The node is in BackOff state right now %%%%%%%%%%%%%%%%%
        
    case BackOff
        switch (event)
            case NewPkt  
                
            case Collision
                
            case TxSuccess
                
            otherwise
                disp('Suprious Event');
                dbstop; % stop the execution for debugging. 
                
                
        end %switch(event) ends here
        
   %%%%%%%%%%%%%% End of node.State = BackOff %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
end % switch (node.State) ends here
    
end % Function update_node_state ends here