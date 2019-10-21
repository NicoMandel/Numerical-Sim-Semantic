% Script to run the reduced version of bigfunction
% the version has its own k to iterate over
% And only uses 12 examples - so that the size does not explode
% This script is based on the shell script that is supposed to lodge the
% results for the HPC
% [0.5, 0.75, 1.0, 1.25]
dist_thresh = [0.5, 0.75, 1.0, 1.25];
pt_thresh = [4, 7, 10, 15];
len_dist = size(dist_thresh,2);
len_pts = size(pt_thresh,2);

counter =0;
for i = 1:len_pts
    for j = 1:len_dist
        counter = bigfunction_Random(pt_thresh(i), dist_thresh(j), counter);
        fprintf("Finished case %d\n", counter);
    end
end


