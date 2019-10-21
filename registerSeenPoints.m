function [seenPoints] = registerSeenPoints(seenPoints,current_pos,cam_model)
%REGISTERSEENPOINTS Function to register the seen Points, e.g. add them to
%the array being passed in.
%   Args: seen Points: x,y matrix of already seen points
%   current_pos: current x, y coordinates
%   cam_model: points from the camera model, which are considered seen

% 1. transform all the points in the camera model by adding them
new_x = cam_model(:,1) + current_pos(1);
new_y = cam_model(:,2) + current_pos(2);
newmat = [new_x new_y];
% 2. Append them to the already seen points
seenPoints = [seenPoints; newmat];
% 3. Return only the unique rows of the seen points
seenPoints = round(seenPoints,1);
seenPoints = unique(seenPoints,'rows');
end

