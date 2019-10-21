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
    seenPts= [];
    All_wps = init_waypoints(max_r, ang_bins);
    
 
    k = 1;
    wps_len = size(All_wps,1);
    target_found = false;
    registered_good = boolean(zeros(n_significant,1));   % at this stage only n_significant, because we only work with the significant objects
    registered_bad = boolean(zeros(n_significant,1));
    recalculated = false;
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
        while l <= interim_ct && ~recalculated
            % increase the step counter
            steps = steps+1;
            % Register the seen Points
            seenPts = registerSeenPoints(seenPts, interm_pts(l,:), camera_points);
            
            % Check if the agent is within reach of the goal
            dist_to_goal = withinReach(interm_pts(l,:), target_obj);
            if dist_to_goal < dist_threshold
                % A random probability to check whether it has actually
                % detected the target - only needs to see it once
                prob_detect = rand;
                if dist_to_goal < prob_detect
                    target_found = true;  
                    break
                end
            end
            
            % Check if the agent is within reach of good objects
            dist_to_objects = withinReach(interm_pts(l,:), good_obj);
            indices = find(dist_to_objects < dist_threshold);
            if ~isempty(indices)
                index_len = size(indices,1);
                m=1;
                % Check if the indices have been registered yet
                while m <= index_len
                    if ~registered_good(indices(m))
                        prob_detect = rand;
                        if dist_to_objects(indices(m)) < prob_detect
                            % recalculate the path
                            newWP = recalculateGreedy(seenPts,pt_count_threshold_bin, ang_bins, max_r);
                            % Set the k, All_wps and wps_len variables, and the
                            % registered variable
                            k=1;
                            All_wps = newWP;
                            wps_len = size(All_wps,1);
                            registered_good(indices(m)) = true;
                            recalculated = true;
                            % break out of innermost loop
                            break;
                        end
                    end
                    m = m+1;
                end
            end
            
            % Check if the agent is within reach of bad objects
            dist_to_bad = withinReach(interm_pts(l,:), bad_obj);
            indices = find(dist_to_bad < dist_threshold);
            if ~isempty(indices)
                index_len = size(indices,1);
                m=1;
                % Check if the indices have been registered yet
                while m <= index_len
                    if ~registered_bad(indices(m))
                        prob_detect = rand;
                        if dist_to_bad(indices(m)) < prob_detect
                            % recalculate the path
                            newWP = recalculateGreedy(seenPts,pt_count_threshold_bin, ang_bins, max_r);
                            % Set the k, All_wps and wps_len variables, and the
                            % registered variable
                            k=1;
                            All_wps = newWP;
                            wps_len = size(All_wps,1);
                            registered_bad(indices(m)) = true;
                            recalculated = true;
                            % break out of innermost loop
                            break;
                        end
                    end
                    m = m+1;
                end
            end
            
            % increase the trajectory counter
            l = l+1;
        end
        % increase the counter
        k=k+1;
        % set recalculated to false
        recalculated = false;
%         hold(ax1,'off')
    end
    % Save the steps
    step_counter(q) = steps;
    fprintf('Finished Processing file %d \n',q);
end
save("Results_Greedy_Algo_detect_prob", 'step_counter');
