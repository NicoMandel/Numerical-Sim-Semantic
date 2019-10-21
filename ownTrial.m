%% 1 - Preliminaries
clear
clc
source_dir = "Sims";
source_fname = "/Simulation_";
target_dir = "Results";

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
    source_file = strcat(source_dir, source_fname, int2str(q));
    load(source_file);
    seenPts= [];
    All_wps = init_waypoints(max_r, ang_bins);
    
    % 4.2 At each timestep t the UAV goes to the next WP
    % xy vel max is set to 0.8 in the parameters of the navigation node - so @
    % 10 Hz it'll advance by 0.08m OR turn - max_yawrate is 45 deg/s
    
    % it starts at a point in All_wps, which we know from 5
    k = 1;
    wps_len = size(All_wps,1);
    target_found = false;
    good_registered = boolean(zeros(n_significant,1));   % at this stage only n_significant, because we only work with the significant objects
    bad_registered = boolean(zeros(n_significant,1));
    recalculated = false;
    
%     figure
%     ax1 = subplot(2,2,1);
%     ax2 = subplot(2,2,2);
%     ax3 = subplot(2,2,3);
%     scatter(good_obj(:,1), good_obj(:,2), 'b+','LineWidth',2);
%     title(ax3, 'Real Object Locations')
%     hold on
%     scatter(bad_obj(:,1), bad_obj(:,2), 'r^','LineWidth',2);
%     scatter(target_obj(:,1), target_obj(:,2) ,'gx','LineWidth',2);
%     scatter(rand_obj(:,1), rand_obj(:,2), 'k*','LineWidth',2);
%     xlim(ax3, [-10 10]);
%     ylim(ax3, [-10 10]);
%     title(ax1, 'All Waypoints')
%     xlim(ax1, [-10, 10])
%     ylim(ax1, [-10, 10])
%     hold(ax1, 'on')
    steps = 0;
    
    while ~target_found && k < wps_len
%         plot(ax1, All_wps(:,1), All_wps(:,2));
%         hold(ax1, 'on')
        
%         if ~isempty(seenPts)
%             scatter(ax2, seenPts(:,1), seenPts(:,2))
%             title(ax2, 'Seen Points')
%             xlim(ax2, [-10, 10])
%             ylim(ax2, [-10, 10])
%         end
        
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
%             scatter(ax1, interm_pts(l,1), interm_pts(l,2), 'rx')
            % Register the seen Points
            seenPts = registerSeenPoints(seenPts, interm_pts(l,:), camera_points);
            
            % Check if the agent is within reach of the goal
            dist_to_goal = withinReach(interm_pts(l,:), target_obj);
            if dist_to_goal < dist_threshold
                % A random number between 0 and 1
                prob_detect = rand;
                % if it is nearer than the detection probability 
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
                    if ~good_registered(indices(m))
                        prob_detect = rand;
                        % check if they are smaller than some random variable
                        if dist_to_objects(indices(m)) < prob_detect
                            % recalculate the path - use the location of the
                            % object
                            new_loc = good_obj(indices(m),:);
                            newWP = recalculatePath(seenPts,new_loc,pt_count_threshold_bin, ang_bins, max_r);
                            % Set the k, All_wps and wps_len variables, and the
                            % registered variable
                            k=1;
                            All_wps = newWP;
                            wps_len = size(All_wps,1);
                            good_registered(indices(m)) = true;
                            recalculated = true;
                            % break out of innermost loop
                            break;
                        end
                    end
                    m = m+1;
                end
            end
            
            % Check if the agent is within reach of bad objects - see if
            % this improves anything -IF YES, add to greedy
            dist_to_bad = withinReach(interm_pts(l,:), bad_obj);
            indices = find(dist_to_bad < dist_threshold);
            if ~isempty(indices)
                index_len = size(indices,1);
                m=1;
                % Check if the indices have been registered yet
                while m <= index_len
                    if ~bad_registered(indices(m))
                        prob_detect = rand;
                        if dist_to_bad(indices(m)) < prob_detect
                            % recalculate the path - use the location of the
                            % object
                            new_loc = bad_obj(indices(m),:);
                            WPs = recalculatePath(seenPts,new_loc,pt_count_threshold_bin, ang_bins, max_r);
                            newWP = flipud(WPs);
                            % Set the k, All_wps and wps_len variables, and the
                            % registered variable
                            k=1;
                            All_wps = newWP;
                            wps_len = size(All_wps,1);
                            bad_registered(indices(m)) = true;
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
% target_f_name = "Own-Neg-Recalc";
% target_file = strcat(target_dir, "/", target_f_name);
target_file = "Results_own_Algo_detect_prob";
save(target_file, 'step_counter');
