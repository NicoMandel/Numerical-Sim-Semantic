function [success_weighted_path_length, success_ct, mean_val, std_val] = ownAlgo_No_Neg(source_dir, source_fname, target_dir, no_of_simulations,...
    max_r, ang_bins, pt_count_threshold_bin, dist_threshold, intermediate_pts_ct, rand_init, rand_recalc)
%OWNALGO Function to evaluate things and store according to params
%   Accepts all "Preliminaries" as parameters to process and save with the
%   filename

% CONSTANTS:
n_significant = 2;
step_counter = zeros(no_of_simulations,1);
camera_points = camModel(dist_threshold,[4 ang_bins]);
successes = boolean(zeros(no_of_simulations,1));
min_step_length = (max_r+1) * intermediate_pts_ct;
if rand_recalc
   rand_recalculation = boolean(ones(no_of_simulations,1));
else
    rand_recalculation = boolean(zeros(no_of_simulations,1));
end

parfor q = 1:no_of_simulations
    source_file = strcat(source_dir, source_fname, int2str(q));
    var = load(source_file);
    good_obj = var.good_obj;
%     bad_obj = var.bad_obj;
    target_obj = var.target_obj;
%     rand_obj = var.rand_obj;
    seenPts= [];
    if rand_init
        All_wps = rand_init_waypoints(max_r, ang_bins);
    else
        All_wps = init_waypoints(max_r, ang_bins);
    end
    
    % it starts at a point in All_wps, which we know from 5
    k = 1;
    wps_len = size(All_wps,1);
    target_found = false;
    good_registered = boolean(zeros(n_significant,1));   % at this stage only n_significant, because we only work with the significant objects
%     bad_registered = boolean(zeros(n_significant,1));
    recalculated = false;
    steps = 0;
    steps_since_recalc = 0;
    
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
            steps_since_recalc = steps_since_recalc+1;
            % Register the seen Points
            seenPts = registerSeenPoints(seenPts, interm_pts(l,:), camera_points);
            
            % Check if the agent is within reach of the goal
            dist_to_goal = withinReach(interm_pts(l,:), target_obj);
            if dist_to_goal < dist_threshold
                % A random number between 0 and 1
                prob_detect = dist_threshold*rand;
                % if it is nearer than the detection probability 
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
                    if ~good_registered(indices(m))
                        prob_detect = dist_threshold*rand;
                        % check if they are smaller than some random variable
                        if dist_to_objects(indices(m)) < prob_detect
                            % recalculate the path - use the location of the
                            % object
                            new_loc = good_obj(indices(m),:);
                            newWP = recalculatePath(seenPts,new_loc,pt_count_threshold_bin, ang_bins, max_r);
                            % Set the k, All_wps and wps_len variables, and the
                            % registered variable
                            k=1;
                            curr_pos = interm_pts(l,:);
                            All_wps = [curr_pos; newWP];
                            wps_len = size(All_wps,1);
                            good_registered(indices(m)) = true;
                            recalculated = true;
                            steps_since_recalc = 0;
                            % break out of innermost loop
                            break;
                        end
                    end
                    m = m+1;
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
%     fprintf('Finished Processing file %d for Own Algo\n',q);
end
if rand_recalc
    rand_str ="rand-recalc";
else
    rand_str ="no_rand"';
end
target_f_name = sprintf("Own-NoNeg-%s-SPL-BinThresh-%d-DistThresh-%.2f-IntermPtsCt-%d.mat",...
    rand_str, pt_count_threshold_bin,dist_threshold,intermediate_pts_ct);
target_file = strcat(target_dir, "/", target_f_name);
save(target_file, 'step_counter');
fprintf('Writing file %s\n',target_f_name);

success_weighted_path_length=SPL(no_of_simulations, min_step_length./step_counter, successes);
success_ct = nnz(successes);
mean_val = mean(step_counter);
std_val = std(step_counter);
end

