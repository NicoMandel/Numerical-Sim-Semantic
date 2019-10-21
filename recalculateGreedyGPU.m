function [newWP] = recalculateGreedyGPU(g, seenPoints, threshold, ang_bins, max_r)
%RecalculateGreedy Takes histogram counts and centers and a threshold
% evaluates the histogram and spits out a new path 
%   Detailed explanation goes here

% 2. turn all seen points into polar points
[theta, rho] = cart2pol(seenPoints(1,:), seenPoints(2,:));
X_gpu = vertcat(theta,rho);
X = gather(X_gpu);
% 3. create the histogram
[N, c] = hist3(X', 'Nbins', [ang_bins, max_r]);
% 4. Omit bins where the value is above a threshold
[angs,radii] = find(N<threshold);
% 5. convert the bin centres to cartesian coordinates
new_angs = c{1}(angs);
new_radii = c{2}(radii);
[cart_x, cart_y] = pol2cart(new_angs, new_radii);
newWP = [cart_x' cart_y'];
clear theta rho X_gpu;
wait(g);
end

