function [TxBuff, Tx_Queue] = schd_pkt(TxBuff, Tx_Queue)
% Schedules a packet from Tx_Queue into the TxBuff. Reduces the Queue
% length by 1 and shift the queue as per FIFO to bring next Tx packet at
% head
global Pkt
    TxBuff = Tx_Queue.Pkts(1); % Fetch first pkt
    len = Tx_Queue.len;
    % Shift the queue
    Tx_Queue.Pkts(1:(len-1)) = Tx_Queue.Pkts(2:len);
    Tx_Queue.len = len - 1; 
    % Delete the old packet
    Tx_Queue(len) = Pkt;

    return;
