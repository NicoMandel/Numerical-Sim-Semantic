function [Waypoints] = glob_waypoints(vec_start,vec_stop, segments)
%GLOB_WAYPOINTS Function to return an array of waypoints between two input
%vectors. 
%   Divides a straight line between two vectors into k segments
dir_vec = vec_stop - vec_start;
Waypoints = zeros([segments 2]);
k = 1;
for i=1:segments
    Waypoints(k,:) = vec_start + i/segments * dir_vec;
    k = k+1;
end
end

