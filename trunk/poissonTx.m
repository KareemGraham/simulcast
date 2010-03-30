function [Nbtx] = poissonTx(attempRate)
%Function poissonTx generate a random number for Poisson distribution
%according to the attempRate [0,1]
%
%        Input: attempRate - the average packet transmission attemp 
%                            rate for each node
%
%        Output: Nbtx - the number of packet "arrive" in the transmittor
%
%        Usage: Since the poisson model is used for packets "arrival", this
%               function will determine how many packets we allow to send
%               in the slotted Aloha. For example, at the first slot, if
%               a node gets Nbtx that is 0, then it won't transmit. If a 
%               node gets Nbtx is 1, then it can tranmit a packet within
%               this slot. If a node gets Nbtx is 2, then it can tranmit
%               two packets in this slot and the next slot if no collision.
%               This function should be called by each node at the begining
%               of each slot and allow the Nbtx to be accumulcated.
%               Therefore, each node will have an "AllowedPacketTxCount" to
%               keep track of how many packets it allows to send. In the
%               case of successful transmission, this cound will reduced by
%               1.
%               

%Testing Code
%
%close all
%attempRate = 1;
%n=100;
%Prtx=poissrnd(attempRate,1,n);
%hist(Prtx)
%

Nbtx=poissrnd(attempRate);

end