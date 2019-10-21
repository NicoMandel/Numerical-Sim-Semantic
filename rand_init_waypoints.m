function [All_wps] = rand_init_waypoints(max_r,ang_bins)
%RAND_INIT_WAYPOINTS creates a set of random waypoints to visit initally
%   Detailed explanation goes here
radii = linspace(1,max_r+1,max_r+1);
angles = linspace(0,2*pi-(2*pi)/ang_bins, ang_bins);
wp_no = (max_r+1)*ang_bins;
wp_ids = randsample(wp_no,wp_no);
All_wps = zeros([wp_no 2]);
for i = 1:wp_no
    id = wp_ids(i);
    if id ~= wp_no
        radius_idx = floor(id/ang_bins)+1;
        ang_idx = mod(id,ang_bins-1)+1;
        radius = radii(radius_idx);
        ang = angles(ang_idx);
        [x, y] = pol2cart(ang, radius);
        All_wps(i,:) = [x y];
    end
end


end

