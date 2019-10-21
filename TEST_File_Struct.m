% A file to test the structure developed for the .sh script and the bigfile
% function, which passes stuff on
% CAREFUL! have to change no_of_simulations in bigfile.

% Everything is defined in bigfunction

% bigfunction(i,j,k,p,q,r);

%% Testing the GPU stuff
% 1 - Preliminaries
source_dir = "Sims";
source_fname = "Simulation_";
target_dir_gpu = fullfile('Results','GPU_Cases');
target_dir_cpu = fullfile('Results','CPU_Cases');

no_of_simulations = 6;          %% _CAREFUL! HAVE TO CHANGE_ 
max_r = 10;
ang_bins = 18;

%% Test_case_1 - GPU for a reduced set of 6 simulations, for 2 of each parameter
pt_thresh = [4 10];
dist_thresh = [0.5 1.25];
interm_pts = [1 8];
pt_len = size(pt_thresh, 2);
inter_len = size(interm_pts,2);
dist_len = size(dist_thresh,2);
total_len = pt_len*dist_len*inter_len;
counter = 0;
g = gpuDevice;
t = tic();
for i=1:pt_len
    for j =1:dist_len
        for k=1:inter_len
            ownAlgoGPU(g, source_dir, source_fname, target_dir_gpu, no_of_simulations,...
                max_r, ang_bins, pt_thresh(i), dist_thresh(j), interm_pts(k), true, true, true);
            GreedyGPU(g, source_dir, source_fname, target_dir_gpu, no_of_simulations,...
                max_r, ang_bins, pt_thresh(i), dist_thresh(j), interm_pts(k), true, true, true);
            counter = counter+1;
            fprintf("Finished iteration %d of %d\n", total_len);
            reset(g);
            wait(g);
        end
    end
end
GPU_Time = toc(t);
fprintf("\n%1.3f secs for GPU\n", GPU_Time);
reset(g);
wait(g);

%% Test case CPU
counter =0;
tt = tic();
for i=1:pt_len
    for j =1:dist_len
        for k=1:inter_len
            ownAlgoHPC(source_dir, source_fname, target_dir_cpu, no_of_simulations,...
                max_r, ang_bins, pt_thresh(i), dist_thresh(j), interm_pts(k), true, true, true);
            GreedyHPC(source_dir, source_fname, target_dir_cpu, no_of_simulations,...
                max_r, ang_bins, pt_thresh(i), dist_thresh(j), interm_pts(k), true, true, true);
            counter =counter+1;
            fprintf("Finished Iteration %d of %d\n", counter, total_len)
            
        end
    end
end
CPU_Time = toc(tt);
fprintf("\n%1.3f secs for CPU\n", CPU_Time);
