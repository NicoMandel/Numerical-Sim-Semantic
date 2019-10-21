function [step_counter, successes] = RandomFunc(source_dir, source_fname, target_dir,...
    no_of_simulations, pt_count_threshold_bin, dist_threshold, intermediate_pts_ct)
%RANDOMFUNC Summary of this function goes here
%   Detailed explanation goes here

% CONSTANT:
step_counter = zeros(no_of_simulations,1);
successes = boolean(zeros(no_of_simulations,1));

parfor q = 1:no_of_simulations
    source_file = fullfile(source_dir, strcat(source_fname, int2str(q)));
    var = load(source_file);
%     good_obj = var.good_obj;
%     bad_obj = var.bad_obj;
    target_obj = var.target_obj;
%     rand_obj = var.rand_obj;
    
    % Load the initial list of waypoints
    wp_load = load('Init_Rand_WPS.mat');
    All_wps = wp_load.WPS;
    
    % it starts at a point in All_wps, which we know from before
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
        if pts_count == 0
           pts_count = 1;
        end
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
                prob_detect = dist_threshold*rand;
                if dist_to_goal < prob_detect
                    target_found = true;
                    successes(q) = true;
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
%     fprintf('Finished Processing file %d for Random\n',q);
end


target_f_name = sprintf("Random-%d-%.2f-%d-config-NA.mat",...
    pt_count_threshold_bin,dist_threshold,intermediate_pts_ct);
target_file = fullfile(target_dir, target_f_name);
save(target_file, 'step_counter', 'successes');

end

