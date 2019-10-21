%% 1 - Preliminaries
clear
clc
target_fname = "/Simulation_";

max_r = 10;
ang_bins = 18;
pt_count_threshold_bin = 10;
n_significant = 2;
n_total = 20;
n_insignificant = n_total - n_significant;
dist_threshold = 1;
intermediate_pts_ct = 10;   % how many points per m
seenPts= [];

mu = 0.75; % good value about 0.95 of cdf is @ x=2
lam = 0.75;
target_dir = sprintf("Sims-Inv_Gauss-Mu-%f-Lam-%f",mu,lam);
% target_dir = "Sims";
% At max_r - a radius sampled from the inverse gaussian.
inv_g = makedist('InverseGaussian','mu',mu,'lambda',lam);
% Potentially for bad models
% lam_bad = 1 / (1-lam_good);
% mu_bad = 1/mu;

% x = 0:0.01:5;
% y = pdf(inv_g,x);
% y_cdf = cdf(inv_g,x);
% figure
% plot(x,y,'.')
% hold on
% plot(x,y_cdf,'r.')
%% Actually go through all the files
for k = 1:200

    % 2.0 - Spawn the target model
    % At a radial location
    ang_target = 2*pi*rand;
    % max r and angle sampled from uniform
    % convert it to a Cartesian location
    [x_target, y_target] = pol2cart(ang_target, max_r);
    target_obj = [x_target y_target];

    % 2.1 Spawn the 2 - Good models
    rand_r = random(inv_g,[n_significant,1]);
    good_r = max_r - (rand_r*0.5*max_r);
    good_ang = normrnd(ang_target,pi/3.14,[n_significant,1]);
    [good_obj_x, good_obj_y] = pol2cart(good_ang, good_r);
    good_obj = [good_obj_x good_obj_y];
    % 2.2 - Spawn the 2 Bad Models

    % at the negative angle of the target from 0 - just use the same distribution
    bad_r = max_r*0.5*random(inv_g,[n_significant,1]);
    bad_ang = normrnd(ang_target-pi,pi/3.14,[n_significant,1]); % the pi/3.14 qualifies as humor, doesnt it?
    [bad_obj_x, bad_obj_y] = pol2cart(bad_ang, bad_r);
    bad_obj = [bad_obj_x bad_obj_y];
    % scatter(bad_obj(:,1), bad_obj(:,2), 'r^','LineWidth',2);

    % 3  take some RANDOM objects 
    rand_r = max_r * rand(n_insignificant,1);
    rand_ang = 2*pi*rand(n_insignificant,1);
    [rand_x, rand_y] = pol2cart(rand_r, rand_ang);
    rand_obj = [rand_x rand_y];

    % 3.5 SAVE all of them 
    target_file = strcat(target_dir, target_fname, int2str(k));
    save(target_file,'target_obj','good_obj','bad_obj','rand_obj');

end










