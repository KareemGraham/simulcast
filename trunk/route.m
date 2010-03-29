function [ route ] = route( src, dst, links )
%route - finds route from src to dst from links
%   Detailed explanation goes here
[d,route,pred] = graphshortestpath(sparse((links > 0)*1 + (links < 0) * 2), src, dst);
end

