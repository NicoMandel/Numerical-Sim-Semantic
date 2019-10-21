function [camPoints] = camModel(threshold, pt_count)
%SEENPOINTS calculates a certain no. of points radially
%   Requires a threshold, a count of points, returns an array of points
%   that are considered seen, equally spaces points radially

radial_pts = pt_count(1);
ang_pts = pt_count(2);
camPoints = zeros([radial_pts*ang_pts+1 2]);
k=1;
for j = 0:(threshold/radial_pts):threshold
    if j == 0
        camPoints(1,:) = [0, 0];
    else
        for i = (2*pi/ang_pts):(2*pi/ang_pts):2*pi
            [x, y] = pol2cart(i, j);
            camPoints(k,:) = [x, y];
            k = k+1;
        end
    end
end
    
end

