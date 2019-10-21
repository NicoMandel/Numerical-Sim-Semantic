
%% Script to save the initial waypoints and 10 scenarios
% Section 1 - saving the waypoints
target_dir = "Ubuntu-Stuff";
WPS = rand_init_waypoints(10, 18);
WPS = unique(WPS, 'rows');
b = [0.0, 0.0];
Lia = ismember(WPS,b,'rows');
k = find(Lia);
WPS(k,:) = [];
len_wps = size(WPS, 1);
wp_ids = randsample(len_wps, len_wps);
WPS = WPS(wp_ids,:);
WPS = [b; WPS];
writematrix(WPS,fullfile(target_dir, 'Initial_WPs.csv'));
save(fullfile(target_dir, 'Init_Rand_WPS'), 'WPS');

%% Saving some random configurations to load later on
load_dir = "Sims";
load_fname = "Simulation_";

x = randi(200,10,1);
length = size(x,1);
for i = 1:length
    load_file = fullfile(load_dir, strcat(load_fname, int2str(x(i))));    
    var = load(load_file);
    targ = var.target_obj;
    good = var.good_obj;
    bad = var.bad_obj;
    rand = var.rand_obj(1:16,1:2);
    % Locations - Order: 
    X = [targ;good;bad;rand];
    save_str = sprintf("SimScen_%d.csv",x(i));
    writematrix(X,fullfile(target_dir,save_str));
end
fprintf("Done")