function [seenPoints] = registerSeenPointsGPU(g, seenPoints, current_pos, cam_model)
%REGISTERSEENPOINTS Function to register the seen Points, e.g. add them to
%the array being passed in.
%   Args: seen Points: gpuArray
%   current_pos: current x, y coordinates
%   cam_model: points from the camera model, which are considered seen

% 1. transform all the points in the camera model by adding them
curr_pos = gpuArray(current_pos');
newmat = plus(cam_model,curr_pos);
% 2. Append them to the already seen points
seenPoints_new = horzcat(seenPoints, newmat);
% 3. Return only the unique rows of the seen points
% seenPoints = round(seenPoints,1,'decimals'); % GPU Arrays do not allow
% rounding to significant digits
seenPoints_new = seenPoints_new * 10;
seenPoints_new = round(seenPoints_new);
seenPoints_new = seenPoints_new / 10;
% CAREFUL, when using gpuArrays, we have to go for columns, if we keep the
% points to be transposed from the start
seenPoints = transpose(unique(transpose(seenPoints_new),'rows'));
clear curr_pos newmat seenPoints_new;
wait(g);
end

