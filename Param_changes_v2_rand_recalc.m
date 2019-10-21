%% 1- all the parameters that stay constant
% cd R2019b/CircularSim
% cwd = pwd;
% addpath(cwd);
clear
clc
source_dir = "Sims";
source_fname = "/Simulation_";
target_dir = "Results/SPL-Switch-Neg-Init-Add";

% 2 - All the things that can change
% 2.1 - not really - Simulation dependent
no_of_simulations = 200;
max_r = 10;
ang_bins = 18;

% 2.2 - these can change
pt_count_threshold_bin = [4, 7, 10, 15];
dist_threshold = [0.5, 0.75, 1.0, 1.25];
intermediate_pts_ct = [1, 2, 3, 5, 8];
ctr = 0;

% length of changeable stuff
len_pt_thresh = size(pt_count_threshold_bin,2);
len_dist_thresh = size(dist_threshold,2);
len_interm_ct = size(intermediate_pts_ct,2);
len_algos = 3;

total_opt = len_pt_thresh * len_dist_thresh * len_interm_ct * 2;
% Big array to store it all - 
% 1st Dim - Algorithm - Order: Own, Greedy, Random
% 2nd Dim - pt_count_threshold
% 3rd Dim - dist-threshold
% 4th Dim - interm-pts-ct
% 5th Dim - Negative elements or not
% 6th Dim - Mean, Std, successes
BigArray = zeros(len_algos, len_pt_thresh, len_dist_thresh, len_interm_ct, 2, 4);
h = waitbar(0,'Please wait...');
s = clock;
random_str = "Rand Recalc";
for i=1:len_pt_thresh
    for j=1:len_dist_thresh
        for k=1:len_interm_ct
            for q=1:2
                if q == 1
                    neg_case = "Neg. Triggers";
                    [spl_own, successes_own, mean_own, std_own] = ownAlgo(source_dir, source_fname, target_dir, no_of_simulations,...
                        max_r, ang_bins, pt_count_threshold_bin(i), dist_threshold(j), intermediate_pts_ct(k), true, true);
                    
                    [spl_greedy, successes_greedy, mean_greedy, std_greedy] = GreedyFunc(source_dir, source_fname, target_dir, no_of_simulations,...
                        max_r, ang_bins, pt_count_threshold_bin(i), dist_threshold(j), intermediate_pts_ct(k), true, true);
        
                    [spl_rand, successes_rand, mean_rand, std_rand] = RandomFunc(source_dir, source_fname, target_dir, no_of_simulations,...
                        max_r, ang_bins, pt_count_threshold_bin(i), dist_threshold(j), intermediate_pts_ct(k));
                    
                else
                    neg_case = "No Neg. Triggers";
                    [spl_own, successes_own, mean_own, std_own] = ownAlgo_No_Neg(source_dir, source_fname, target_dir, no_of_simulations,...
                        max_r, ang_bins, pt_count_threshold_bin(i), dist_threshold(j), intermediate_pts_ct(k), true, true);
 
                    [spl_greedy, successes_greedy, mean_greedy, std_greedy] = Greedy_Func_No_Neg(source_dir, source_fname, target_dir, no_of_simulations,...
                        max_r, ang_bins, pt_count_threshold_bin(i), dist_threshold(j), intermediate_pts_ct(k), true, true);
                    
                    [spl_rand, successes_rand, mean_rand, std_rand] = RandomFunc(source_dir, source_fname, target_dir, no_of_simulations,...
                        max_r, ang_bins, pt_count_threshold_bin(i), dist_threshold(j), intermediate_pts_ct(k));
                    
                end
                BigArray(1,i,j,k, q, 1) = mean_own;
                BigArray(1,i,j,k, q, 2) = std_own;
                BigArray(1,i,j,k, q, 3) = successes_own;
                BigArray(1,i,j,k, q, 4) = spl_own;
                BigArray(2,i,j,k, q, 1) = mean_greedy;
                BigArray(2,i,j,k, q, 2) = std_greedy;
                BigArray(2,i,j,k, q, 3) = successes_greedy;
                BigArray(2,i,j,k, q, 4) = spl_greedy;
                % Random values will be the same in both cases
                BigArray(3,i,j,k, q, 1) = mean_rand;
                BigArray(3,i,j,k, q, 2) = std_rand;
                BigArray(3,i,j,k, q, 3) = successes_rand;
                BigArray(3,i,j,k, q, 4) = spl_rand;
                
                ctr = ctr+1;
                fprintf('Processed case: %s, %s, Point Count Threshold: %d, Dist-Threshold: %.2f, Interm. Pt. Count: %d \n',...
                    neg_case,random_str,pt_count_threshold_bin(i), dist_threshold(j), intermediate_pts_ct(k));
                
                if k == 1 && i == 1 && j == 1 && q==1 % only on very first iteration
                    is = etime(clock,s);
                    esttime = is * total_opt;
                end
                h = waitbar((i*j*k*q)/total_opt,h,...
                    ['remaining time = ',num2str(esttime-etime(clock,s),'%4.1f'),'sec' ]);
                fprintf("Finished Iteration %d of %d\n",...
                    ctr,total_opt);                
            end
            
        end
    end
end
save('Result_Overview_SPL_Neg_Rand-Init-Switch-ADD-Rand-Recalc','BigArray');
% CHANGED the prob_detect to be dist_thres * rand and not rand anymore! to
% adjust for dist_threshold length
