function [newWP] = recalculatePath(seenPoints, current_pos, threshold, ang_bin_count, r_bin_count)
%RECALCULATEPATH Takes a list of already seen Points and the current position
% evaluates the histogram and spits out a new path 
%   Detailed explanation goes here

% 1. Offset all points by the current position
new_x = seenPoints(:,1) - current_pos(1);
new_y = seenPoints(:,2) - current_pos(2);

% 2. turn all points into polar points
[theta, rho] = cart2pol(new_x, new_y);
X = [theta rho];
% 3. create the histogram
[N, c] = hist3(X, 'Nbins', [ang_bin_count, r_bin_count]);
% 4. Omit bins where the value is above a threshold
[angs,radii] = find(N<threshold);
% 5. convert the bin centres to cartesian coordinates
new_angs = c{1}(angs);
new_radii = c{2}(radii);
[cart_x, cart_y] = pol2cart(new_angs, new_radii);
% 6. retransfer them to global coordinates
new_x = cart_x + current_pos(1);
new_y = cart_y + current_pos(2);
newWP = [new_x' new_y'];
end

