function [ ] = plotavg( root_dir )
%PLOTAVG Summary of this function goes here
%   Detailed explanation goes here
x=1;
Xstr = [];
Ystr = [];
while (exist([root_dir,'\',num2str(x), '.mat'],'file'))
    S = ['load ',root_dir,'\',num2str(x),'.mat X Y'];
    eval(S);
    S = ['X',num2str(x),'=X;'];
    eval(S);
    S = ['Y',num2str(x),'=Y;'];
    eval(S);
    Xstr = [Xstr,'X',num2str(x),' '];
    Ystr = [Ystr,'Y',num2str(x),' '];
    x = x + 1;
end
%S = ['semilogx([',Xstr,'],[',Ystr,'],',char(39),'kx',char(39),')'];
S = ['createfigure([',Xstr,'],[',Ystr,'])'];
eval(S)
end