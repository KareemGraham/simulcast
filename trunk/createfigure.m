function createfigure(X1, Y1, Theta)
%CREATEFIGURE(X1,Y1)
%  X1:  vector of x data
%  Y1:  vector of y data

%  Auto-generated by MATLAB on 16-Apr-2010 22:44:00

% Create figure
figure1 = figure;
title(['Theta = ', Theta]);
% Create axes
axes1 = axes('Parent',figure1,'XScale','log','XMinorTick','on');
% Uncomment the following line to preserve the X-limits of the axes
% xlim(axes1,[0.001 1]);
box(axes1,'on');
hold(axes1,'all');

% Create semilogx
semilogx1 = semilogx(X1,Y1,'Marker','x','LineStyle','none',...
    'DisplayName','data 1',...
    'Color',[1 1 1]);

axis([10^-3 1 0 0.15]);

% Get xdata from plot
xdata1 = get(semilogx1, 'xdata');
% Get ydata from plot
ydata1 = get(semilogx1, 'ydata');
% Make sure data are column vectors
xdata1 = xdata1(:);
ydata1 = ydata1(:);

% Remove NaN values and warn
nanMask1 = isnan(xdata1(:)) | isnan(ydata1(:));
if any(nanMask1)
    warning('GenerateMFile:IgnoringNaNs', ...
        'Data points with NaN coordinates will be ignored.');
    xdata1(nanMask1) = [];
    ydata1(nanMask1) = [];
end

% Find x values for plotting the fit based on xlim
axesLimits1 = xlim(axes1);
xplot1 = linspace(axesLimits1(1), axesLimits1(2));

% Find coefficients for polynomial (order = 3)
fitResults1 = polyfit(xdata1, ydata1, 3);
% Evaluate polynomial
yplot1 = polyval(fitResults1, xplot1);
% Plot the fit
fitLine1 = plot(xplot1,yplot1,'DisplayName','   cubic','Parent',axes1,...
    'Tag','cubic',...
    'Color',[0 0 0]);

% Set new line in proper position
setLineOrder(axes1, fitLine1, semilogx1);

%-------------------------------------------------------------------------%
function setLineOrder(axesh1, newLine1, associatedLine1)
%SETLINEORDER(AXESH1,NEWLINE1,ASSOCIATEDLINE1)
%  Set line order
%  AXESH1:  axes
%  NEWLINE1:  new line
%  ASSOCIATEDLINE1:  associated line

% Get the axes children
hChildren = get(axesh1,'Children');
% Remove the new line
hChildren(hChildren==newLine1) = [];
% Get the index to the associatedLine
lineIndex = find(hChildren==associatedLine1);
% Reorder lines so the new line appears with associated data
hNewChildren = [hChildren(1:lineIndex-1);newLine1;hChildren(lineIndex:end)];
% Set the children:
set(axesh1,'Children',hNewChildren);

