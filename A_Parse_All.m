%% Script to parse all the result files and get the data out
results_dir = fullfile('Results','All_Cases');
s = dir(fullfile(results_dir,'*.mat'));

% to compare and decipher strings
own_str = "Own";
greedy_str = "Greedy";
max_r = 10;
no_of_simulations = 200;
pt_thresh = [4 7 10 15];
dist_thresh = [0.5 0.75 1.0 1.25];
interm_pts = [1 2 3 5 8];
min_steps = interm_pts*max_r;
Algos = ["Own", "Greedy", "Random"];
C = {'b','g','r'};
LineStyle = {'-',':','-.','--'};

% 3 Algorithms, i, j, k, p, q, r, evaluation values= [SPL. successes, mean, std]
BigArray = ones(2,numel(pt_thresh),numel(dist_thresh),numel(interm_pts), 2, 2, 2, 4);

for h=1:numel(s)
    % deciphering the string
   f_name = s(h).name;
%    numbers = sscanf(f_name, '%s-%d-%f-%d-config-%d-%d-%d');
   new_str = split(f_name,'-');
   last_idx = size(new_str,1);
   last_part = split(new_str(last_idx),'.');
   
   p = str2double(new_str(6));
   q = str2double(new_str(7));
   r = str2double(last_part(1));
   
   algo = new_str(1);
   i_val = str2double(new_str(2));  % pt_thresh
   j_val = str2double(new_str(3));  % dist_thresh
   k_val = str2double(new_str(4));  % interm_pts
   
   i = find(pt_thresh == i_val);
   j = find(dist_thresh == j_val);
   k = find(interm_pts == k_val);
   
   algo_str = string(algo);
   if strcmp(algo_str,own_str)
       alg_idx = 1;
   else 
       alg_idx = 2;
   end
   
   % Loading the actual inputs 
   fnm = fullfile(results_dir, f_name);
   data = load(fnm);
   succ = data.successes;
   steps = data.step_counter;
   
   % Calculating the values to store in the BigArray
   no_successes = nnz(succ);
   mean_steps = mean(steps);
   std_steps = std(steps);
   spl_algo = SPL_Acc(no_of_simulations, min_steps(k), steps, succ);
    % for p, q, r, we have to increase the index by 1! so that 1 == false, 2
   % == true
   BigArray(alg_idx,i,j,k,p+1,q+1,r+1,1) = spl_algo;
   BigArray(alg_idx,i,j,k,p+1,q+1,r+1,2) = no_successes;
   BigArray(alg_idx,i,j,k,p+1,q+1,r+1,3) = mean_steps;
   BigArray(alg_idx,i,j,k,p+1,q+1,r+1,4) = std_steps;
end

%% Read in the results from the random trials
random_dir = fullfile('Results', 'Random_Cases');
s = dir(fullfile(random_dir,'*.mat'));
Rand_Array = ones(numel(pt_thresh),numel(dist_thresh),numel(interm_pts), 4);
for h=1:numel(s)
    % deciphering the string
   f_name = s(h).name;
   new_str = split(f_name,'-');
   
   i_val = str2double(new_str(2));  % pt_thresh
   j_val = str2double(new_str(3));  % dist_thresh
   k_val = str2double(new_str(4));  % interm_pts
   
   i = find(pt_thresh == i_val);
   j = find(dist_thresh == j_val);
   k = find(interm_pts == k_val);   
   
   % Loading the actual inputs 
   fnm = fullfile(random_dir, f_name);
   data = load(fnm);
   succ = data.successes;
   steps = data.step_counter;
   spl_algo = SPL_Acc(no_of_simulations, min_steps(k), steps, succ);
   no_successes = nnz(succ);
   mean_steps = mean(steps);
   std_steps = std(steps);
   
   Rand_Array(i,j,k,1) = spl_algo;
   Rand_Array(i,j,k,2) = no_successes;
   Rand_Array(i,j,k,3) = mean_steps;
   Rand_Array(i,j,k,4) = std_steps;
end




%% FORMAT HERE:
% 1st Dim - Algorithm. 1 = Own, 2 = Greedy, 3 = Random
% 2nd Dim - Pt-Threshold
% 3rd Dim - Dist-Threshold
% 4th Dim - Interm-Pts
% 5th Dim - With Negative Samples - 1 =no, 2 = yes (due to bool+1)
% 6th Dim - With Random Initialization - 1 =no, 2 = yes (due to bool+1)
% 7th Dim - With Random Recalculation - 1 =no, 2 = yes (due to bool+1) -
% CAREFUL - 6th - Dim 0 and 7th Dim 1 does not exist
% 8th Dim - 1: SPL, 2: Successes, 3: Mean Steps, 4: Std deviation of steps
%% Test Section
idxs = find(BigArray ~= 1); % == 1
% these are a lot.... see what went wrong there

%% Plot for certain case - p = 2, q = 2, r = 2
% plot spls
% to set xticklabels use this string array https://au.mathworks.com/help/matlab/ref/xticklabels.html
% create an array of similar size with num2str and sprintf(%d-%d-%:.2f - which will then )
pt_len = numel(pt_thresh);
dist_len = numel(dist_thresh);
interm_len = numel(interm_pts);
name_cell_array = {};
for i = 1:pt_len
    for j= 1:dist_len
        for k =1:interm_len
            name_cell_array{i,j,k} = sprintf("%d-%.2f-%d", pt_thresh(i), dist_thresh(j), interm_pts(k));
        end
    end
end
name_vec = reshape(name_cell_array, [], 1);

%%
rand_vals = Rand_Array(:,:,:,1);
rand_vec_glob = reshape(rand_vals, [], 1);
lwidth = 2;
ftsize = 15;
t_ftsize = 12;
idx = 0;
trigger_str = ["false", "true"];
limits = [0 0.1];
figure;
for p = [1 2]
    for q = [1 2]
        if q == 2
            for r = [1 2]
                %                 idx = ((p-1)*2 + q-1)*2+r;
                own_vals = BigArray(1,:,:,:,p,q,r,1);
                greedy_vals = BigArray(2,:,:,:,p,q,r,1);
                idx = idx+1;
                ax = subplot(2, 3, idx);
                % Actual plotting stuff
                own_vec = reshape(own_vals, [], 1);
                greedy_vec = reshape(greedy_vals, [], 1);
                reduced_idcs = greedy_vec ~= 1;
                own_vec = own_vec(reduced_idcs);
                greedy_vec = greedy_vec(reduced_idcs);
                rand_vec = rand_vec_glob(reduced_idcs);
                x = 1:size(own_vec,1);
                plot(x,own_vec,'g-','DisplayName','Own','LineWidth',lwidth);
                hold on;
                plot(x,greedy_vec,'r:','DisplayName','Greedy','LineWidth',lwidth);
                plot(x,rand_vec, 'k-.', 'DisplayName','Random','LineWidth',lwidth);
                title_str = sprintf("Neg. Triggers: %s, Rand-Init: %s, Rand-Recalc: %s",...
                    trigger_str(p),trigger_str(q),trigger_str(r));
                t = title(ax, title_str);
                % Bit of trickery to index into the cell array
                cell_idcs = find(reduced_idcs==1);
                xticklabels(ax, name_vec(cell_idcs));
                xtickangle(45);
                set(ax, 'FontSize', ftsize);
                set(t, 'FontSize', t_ftsize);
                ylim(ax, limits);
                legend(ax);
            end
        else
            r=1;
%             idx = ((p-1)*2 + q-1)*2+r;
            idx = idx+1;
            ax = subplot(2, 3, idx);
            own_vals = BigArray(1,:,:,:,p,q,r,1);
            greedy_vals = BigArray(2,:,:,:,p,q,r,1);
            % Actual plotting stuff
            own_vec = reshape(own_vals, [], 1);
            greedy_vec = reshape(greedy_vals, [], 1);
            reduced_idcs = greedy_vec ~= 1;
            own_vec = own_vec(reduced_idcs);
            greedy_vec = greedy_vec(reduced_idcs);
            rand_vec = rand_vec_glob(reduced_idcs);
            x = 1:size(own_vec,1);
            plot(x,own_vec,'g-','DisplayName','Own','LineWidth',lwidth);
            hold on;
            plot(x,greedy_vec,'r:','DisplayName','Greedy','LineWidth',lwidth);
            plot(x,rand_vec, 'k-.', 'DisplayName','Random','LineWidth',lwidth);
            title_str = sprintf("Neg. Triggers: %s, Rand-Init: %s, Rand-Recalc: %s",...
                trigger_str(p),trigger_str(q),trigger_str(r));
            cell_idcs = find(reduced_idcs==1);
            xticklabels(ax, name_vec(cell_idcs));
            xtickangle(45);
            set(ax, 'FontSize', ftsize);
            t = title(ax, title_str);
            set(t, 'FontSize', t_ftsize);
            legend(ax);
            ylim(ax, limits);
        end
    end
end
hold off;
%% Get General statistics - Look at best case from ablation

% mean and std_dev of number of successes for all test cases
% omit the cases where no results are available for greedy
no_own_succ = reshape(BigArray(1,:,:,:,2,2,2,1), [], 1);
no_greedy_succ = reshape(BigArray(2,:,:,:,2,2,2,1), [], 1);
no_rand_succ = reshape(Rand_Array(:,:,:,1), [], 1);
reduced_idx = no_greedy_succ ~= 1;
no_greedy_succ = no_greedy_succ(reduced_idx);
reduced_idx = no_own_succ ~= 1;
no_own_succ = no_own_succ(reduced_idx);
reduced_idx = no_rand_succ ~= 1;
no_rand_succ = no_rand_succ(reduced_idx);
% own_succ_norm = no_own_succ./no_of_simulations;
% greedy_succ_norm = no_greedy_succ./no_of_simulations;
% rand_succ_norm = no_rand_succ./no_of_simulations;

rand_mean = mean(no_rand_succ);
rand_std = std(no_rand_succ);
own_mean = mean(no_own_succ);
own_std = std(no_own_succ);
greedy_mean = mean(no_greedy_succ);
greedy_std = std(no_greedy_succ);

%% Grab the values for only the case p = 2, q = 2, r = 2
p=2; q=2; r=2;
% 
% pt_thresh = [4 7 10 15];
% dist_thresh = [0.5 0.75 1.0 1.25];
% interm_pts = [1 2 3 5 8];

figure;
idx = 0;
x_limits = [0.5 1.25];
limits = [0 0.1];
x_idcs = num2cell(x);

for k =1:interm_len
    for i =1:pt_len
        idx = idx+1;
        ax = subplot(interm_len, pt_len, idx);
        own_vals = BigArray(1,i,:,k,p,q,r,1);
        own_vals = reshape(own_vals, [], 1);
        gr_vals = BigArray(2,i,:,k,p,q,r,1);
        gr_vals = reshape(gr_vals, [], 1);
        rand_vals = Rand_Array(i,:,k,1);
        rand_vals = reshape(rand_vals, [],1);
        % Cleaning by results deleted in the simulation
        reduced_idcs = gr_vals ~= 1;
        gr_vals = gr_vals(reduced_idcs);
        own_vals = own_vals(reduced_idcs);
        rand_vals = rand_vals(reduced_idcs);
        x = dist_thresh(reduced_idcs);
        plot(x,own_vals,'g-x','DisplayName','Own','LineWidth',lwidth);
        hold on;
        plot(x,gr_vals,'r:^','DisplayName','Greedy','LineWidth',lwidth);
        plot(x,rand_vals, 'k-.+', 'DisplayName','Random','LineWidth',lwidth);
        title_str = sprintf("Interm. Pts p: %d, Point Thresh t: %d",...
            interm_pts(k), pt_thresh(i));
        set(ax, 'FontSize', ftsize);
        t = title(ax, title_str);
        set(t, 'FontSize', t_ftsize);
        ylim(ax, limits);
        xtickangle(45);
        xlim(ax, x_limits);

    end
end
legend();
hold off;








