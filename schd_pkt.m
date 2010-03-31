function [TxBuff, Tx_Queue] = schd_pkt(TxBuff, Tx_Queue)
    TxBuff = Tx_Queue.Pkts(1); % Fetch first pkt
    len = Tx_Queue.len;
    % Shift the queue
    Tx_Queue.Pkts(1:(len-1)) = Tx_Queue.Pkts(2:len);
    Tx_Queue.len = len - 1; 
    % Delete the old packet
    Tx_Queue(len) = Pkt;

    return;
