function [Y] = plote2e( root_dir, Theta )
%PLOTAVG Summary of this function goes here
%   Detailed explanation goes here
x=1;
Theta = num2str(Theta);
Xstr = [];
Ystr = [];
while (exist([root_dir,'\Theta-',Theta,'\',num2str(x), '.mat'],'file'))
    S = ['load ',root_dir,'\Theta-',Theta,'\',num2str(x),'.mat X End2EndT'];
    eval(S);
    S = ['X',num2str(x),'=X;'];
    eval(S);
    S = ['End2EndT',num2str(x),'=End2EndT;'];
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
    S = ['maxy(y) = max(End2EndT',num2str(y),');'];
    eval(S);
end
x = find(maxy == max(maxy));
S = ['createfigure(X',num2str(x),',End2EndT',num2str(x),',Theta);'];
eval(S);
%S = ['X = X',num2str(x),';'];
eval(S);
%S = ['Y = End2EndT',num2str(x),';'];
Y = maxy(x);
%eval(S);
end