%% 1 - Preliminaries
clear
clc

target_dir = "Sims";
target_fname = "/Simulation_";
no_of_simulations = 200;
% A variable where we store the amount of steps taken for every Simulation
% scenario
step_counter = zeros(no_of_simulations,1);

% The variables which can be changed during simulations
max_r = 10;
ang_bins = 18;
pt_count_threshold_bin = 10;
n_significant = 2;
n_total = 20;
n_insignificant = n_total - n_significant;
dist_threshold = 1;
intermediate_pts_ct = 5;   % how many points per m
camera_points = camModel(dist_threshold,[4 ang_bins]);

%% Now run the simulation
for q = 1:no_of_simulations
    target_file = strcat(target_dir, target_fname, int2str(q));
    load(target_file);
    
    % randomly calculate the initial waypoints
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
    
    
    % it starts at a point in All_wps, which we know from 5
    k = 1;
    wps_len = size(All_wps,1);
    target_found = false;
    steps = 0;
    
    while ~target_found && k < wps_len
        
        % Get the current and the next waypoint
        start_pt = All_wps(k,:);
        end_pt = All_wps(k+1,:);
        dist_x = (end_pt(1) - start_pt(1))^2;
        dist_y = (end_pt(2) - start_pt(2))^2;
        wp_dist = sqrt(dist_x + dist_y);
        pts_count = floor(wp_dist*intermediate_pts_ct);
        % use the points to calculate intermediate Waypoints - trajectory
        interm_pts = glob_waypoints(start_pt', end_pt', pts_count);
        interim_ct = size(interm_pts,1);
        l = 1;
        % For each point on the way
        while l <= interim_ct
            % increase the step counter
            steps = steps+1;            
            % Check if the agent is within reach of the goal
            dist_to_goal = withinReach(interm_pts(l,:), target_obj);
            if dist_to_goal < dist_threshold
                % A random probability to check if the target has actually
                % been detected - only needs to see it once
                prob_detect = rand;
                if dist_to_goal < prob_detect
                    target_found = true;  
                    break
                end
            end
            
            % increase the trajectory counter
            l = l+1;
        end
        % increase the counter
        k=k+1;
    end
    % Save the steps
    step_counter(q) = steps;
    fprintf('Finished Processing file %d \n',q);
end
save("Results_Random_detect_prob", 'step_counter');


