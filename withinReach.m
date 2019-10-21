function dist = withinReach(current_pos, PtArray)
%WITHINREACH to test if the first Arg is within reach of an element of
%second Arg
%   Works with 2-Dimensional arrays. Tests if the first arg, an x,y tuple,
%   is within reach of all elements of the second Arg.

x_dist = PtArray(:,1) - current_pos(1);
y_dist = PtArray(:,2) - current_pos(2);
x_dist = x_dist.^2;
y_dist = y_dist.^2;
dist = sqrt(x_dist+y_dist);
end

