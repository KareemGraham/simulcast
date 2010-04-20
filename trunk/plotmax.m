function [ Y ] = plotmax( root_dir, Theta )
%PLOTAVG Summary of this function goes here
%   Detailed explanation goes here
x=1;
Theta = num2str(Theta);
Xstr = [];
Ystr = [];
while (exist([root_dir,'\Theta-',Theta,'\',num2str(x), '.mat'],'file'))
    S = ['load ',root_dir,'\Theta-',Theta,'\',num2str(x),'.mat X Y'];
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
%S = ['createfigure([',Xstr,'],[',Ystr,'],Theta)'];
%eval(S)
x=x-1;
for y=1:x
    S = ['maxy(y) = max(Y',num2str(y),');'];
    eval(S);
end
x = find(maxy == max(maxy));
S = ['createfigure(X',num2str(x),',Y',num2str(x),',Theta)'];
%eval(S)
Y = mean(maxy);
end