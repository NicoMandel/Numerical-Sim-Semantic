function [All_wps] = init_waypoints(max_r,ang_bins)
%INIT_WAYPOINTS Creates a list of initial waypoints
%   Requires a maximum radius and a number of angular bins
%   Returns waypoints in Cartesian coordinates

radii = linspace(1,max_r+1,max_r+1);
angs = linspace(0,2*pi-(2*pi)/ang_bins, ang_bins);
sz_rad = size(radii,2);
sz_ang = size(angs, 2);
All_wps = zeros([sz_rad*sz_ang 2]);
k = 1;
for r = 1:sz_rad
    for a = 1:sz_ang
        [x, y] = pol2cart(angs(1,a),radii(1,r));
        All_wps(k,:) = [x y];
        k = k+1;
    end
end
end

