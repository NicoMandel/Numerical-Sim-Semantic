function [step_counter, successes] = GreedyHPC(source_dir, source_fname, target_dir, no_of_simulations,...
    max_r, ang_bins, pt_count_threshold_bin, dist_threshold, intermediate_pts_ct, do_neg_obj, rand_init, rand_recalc)
%OWNALGO Function to evaluate things and store accordint to params
%   Accepts all "Preliminaries" as parameters to process and save with the
%   filename

% CONSTANTS:
n_significant = 2;
step_counter = zeros(no_of_simulations,1);
ratio = 1.5;
cam_pt_count = 50;
camera_points = camModelHPC(dist_threshold, cam_pt_count, ratio);
successes = boolean(zeros(no_of_simulations,1));
if rand_recalc
   rand_recalculation = boolean(ones(no_of_simulations,1)); 
else
    rand_recalculation = boolean(zeros(no_of_simulations,1));
end


for q = 1:no_of_simulations
    source_file = fullfile(source_dir, strcat(source_fname, int2str(q)));
    var = load(source_file);
    good_obj = var.good_obj;
    bad_obj = var.bad_obj;
    target_obj = var.target_obj;
%     rand_obj = var.rand_obj;
    seenPts= [];
    if rand_init
        % load file
        wp_load = load('Init_Rand_WPS.mat');
        All_wps = wp_load.WPS;
    else
        All_wps = init_waypoints(max_r, ang_bins);
    end
    
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
        if pts_count == 0
           pts_count =1;
        end
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
                prob_detect = dist_threshold*rand;
                if dist_to_goal < prob_detect
                    target_found = true;
                    successes(q) = true;
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
                        prob_detect = dist_threshold*rand;
                        if dist_to_objects(indices(m)) < prob_detect
                            % recalculate the path
                            newWP = recalculateGreedy(seenPts,pt_count_threshold_bin, ang_bins, max_r);
                            % Set the k, All_wps and wps_len variables, and the
                            % registered variable
                            k=1;
                            curr_pos = interm_pts(l,:);
                            All_wps = [curr_pos; newWP];
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
            
            if  do_neg_obj && ~recalculated
                % Check if the agent is within reach of bad objects
                dist_to_bad = withinReach(interm_pts(l,:), bad_obj);
                indices = find(dist_to_bad < dist_threshold);
                if ~isempty(indices)
                    index_len = size(indices,1);
                    m=1;
                    % Check if the indices have been registered yet
                    while m <= index_len
                        if ~registered_bad(indices(m))
                            prob_detect = dist_threshold*rand;
                            if dist_to_bad(indices(m)) < prob_detect
                                % recalculate the path
                                newWP = recalculateGreedy(seenPts,pt_count_threshold_bin, ang_bins, max_r);
                                % Set the k, All_wps and wps_len variables, and the
                                % registered variable
                                k=1;
                                curr_pos = interm_pts(l,:);
                                All_wps = [curr_pos; newWP];
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
            end
            
            
            if k == wps_len-1 && rand_recalculation(q) && l==interim_ct
                % Get a list of new waypoints from a new function
                newWP = recalculateGreedyRandom(seenPts, pt_count_threshold_bin, ang_bins, max_r);
                % Add the last waypoint to the
                curr_pos = interm_pts(l,:);
                All_wps = [curr_pos; newWP];
                wps_len = size(All_wps,1);
                k=0;
                % do this only once
                rand_recalculation(q) = false;
            end
        
            % increase the trajectory counter
            l = l+1;
        end
        % increase the counter
        k=k+1;
        % set recalculated to false
        recalculated = false;                    
    end
    % Save the steps
    step_counter(q) = steps;
end

% For the filename to write
if do_neg_obj
    neg_str = 1;
else
    neg_str = 0;
end
if rand_init
    rand_i_str = 1;
else
    rand_i_str = 0;
end
if rand_recalc
    rand_r_str =1;
else
    rand_r_str =0;
end

target_f_name = sprintf("Greedy-%d-%.2f-%d-config-%d-%d-%d.mat",...
    pt_count_threshold_bin,dist_threshold,intermediate_pts_ct,...
    neg_str, rand_i_str, rand_r_str);
target_file = fullfile(target_dir, target_f_name);
save(target_file, 'step_counter', 'successes');
% fprintf('Writing file %s\n',target_f_name);


end

