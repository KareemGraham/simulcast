function [node] = update_node_state(node, event)
% Node State Machine
% node.State belongs to {NoPkt,Ready2Tx,BackOff} states
% event belongs to {NewPkt,Collision,TxSuccess} events
global NoPkt Ready2Tx BackOff
global NewPkt Collision TxSuccess OneSlot
global idxT Rmax Pr

switch(node.State)
    %%%%% The node did not have any packet to transmit before this %%%%%%%
    case NoPkt 
        switch (event)
            case NewPkt                                
                % This event is possible either due to an MCB packet
                % scheduling or an LCB schdueling.
                % If node was supposed to be in BackOff state due to
                % earlier collision, keep it in the same state
                if (node.BoS > idxT)
                    node.State = BackOff;
                else % Allow the packet to transmit in same slot
                    node.State = Ready2Tx;
                    node.BoS = idxT;
                end
            otherwise
                disp('Error: Unexpected event in NoPkt State!');
                dbstop; % stop the execution for debugging. 
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
                if (node.BoS > idxT)
                    disp('Error: Node State Ready2Tx but BoS not idxT!');
                    node
                    node.TxMCB
                    node.TxLCB
                    dbstop; % stop the execution for debugging
                end         

            case Collision
                % Node experienced a collision. Assign random number of
                % slots waiting period as per geometric probability
                % distribution. Pr is the probability that a node would
                % try retransmission in next slot.
                
                Rtr = max(node.TxMCB.Rtr, node.TxLCB.Rtr);
                switch(Rtr <= Rmax)
                    % Note that when both packets suffer collision and only
                    % one gets dropped, handle_failed_pkt marks later pkt
                    % as invalid but keeps the pkt.Rtr == Rmax so that it
                    % could be differntiated from TxSuccess. Hence, one
                    % packet being dropped and one packet getting collided
                    % would result in execution of this stage when one of
                    % the packets may have number of retries = Rmax
                    case 1
                        node.BoS = geornd(Pr) + idxT;
                        if(node.TxMCB.Rtr == Rmax)
                            node.TxMCB.Rtr = 0;
                        elseif(node.TxLCB.Rtr == Rmax)
                            node.TxLCB.Rtr = 0;
                        end
                    otherwise
                        disp('Error: Packet exceeded Rmax Retries!');
                        dbgstop
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
                % Both the packets got tx successfully, or the node had only
                % one packet to tx which was successful, or the node
                % dropped the packet. We need to make sure that if the
                % packet was dropped, we still need to increase the BOS. 
                % packet to transmit. 
                node.State = NoPkt;
                % It means that at least one of the packets suffered a
                % collision and got dropped. 
                if (node.TxMCB.Rtr == Rmax || node.TxLCB.Rtr == Rmax)
                    node.BoS = geornd(Pr) + idxT;
                    % Clear the packets retries again to be cautious
                    node.TxMCB.Rtr = 0;
                    node.TxLCB.Rtr = 0;
                else % it was a successful transmission. Tx in next slot
                    node.BoS = idxT + 1;
                end
            otherwise
                disp('Suprious Event');
                dbstop; % stop the execution for debugging. 
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
                dbstop; % stop the execution for debugging. 
                
                
        end %switch(event) ends here
        
   %%%%%%%%%%%%%% End of node.State = BackOff %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
end % switch (node.State) ends here
    
end % Function update_node_state ends here