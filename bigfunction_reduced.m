function [counter] = bigfunction_reduced(i,j,p,q,r, counter)
%BIGSCRIPT Function to call the different Algorithms dependant on their
%config in p,q and r. i, j, just get passed into the algorithms
% k has to be defined myself in here
%   Storing the files should be executed within the functions
%   Functions should not return anything
%   Functions should store variables success(q) and steps(q)
%   Functions should combine source_dir and source_fname with fullfile();
%   Functions should load the initial list of waypoints from a SINGLE file

source_dir = "Sims";
source_fname = "Simulation_";
target_dir = fullfile('Results','All_Cases');

% preliminary stuff
no_of_simulations = 12;          %% _CAREFUL! HAVE TO CHANGE_ 
max_r = 10;
ang_bins = 18;

% Decisions are being made on the p, q and r variables
% p is Negative triggers
% q is Random Initialization
% r is random recalculation
pt_count = [1 2 3 5 8];
pt_len = size(pt_count,2);
for k = 1:pt_len
    if p ==0
        if q==0
            if r==0
                % case: NO Neg triggers, no rand init, also no rand recalc
                ownAlgoHPC(source_dir, source_fname, target_dir, no_of_simulations,...
                    max_r, ang_bins, i, j, pt_count(k), false, false, false);
                GreedyHPC(source_dir, source_fname, target_dir, no_of_simulations,...
                    max_r, ang_bins, i, j, pt_count(k), false, false, false);
                counter = counter+1;
            else
                fprintf("Nothing to do. This case does not exist\n");
            end
        else
            if r==0
                % case: NO Neg triggers, rand init, no rand recalc
                ownAlgoHPC(source_dir, source_fname, target_dir, no_of_simulations,...
                    max_r, ang_bins, i, j, pt_count(k), false, true, false);
                GreedyHPC(source_dir, source_fname, target_dir, no_of_simulations,...
                    max_r, ang_bins, i, j, pt_count(k), false, true, false);
                counter = counter+1;
            else
                % case: NO Neg triggers, Rand init, Rand recalc
                ownAlgoHPC(source_dir, source_fname, target_dir, no_of_simulations,...
                    max_r, ang_bins, i, j, pt_count(k), false, true, true);
                GreedyHPC(source_dir, source_fname, target_dir, no_of_simulations,...
                    max_r, ang_bins, i, j, pt_count(k), false, true, true);
                counter = counter+1;
            end
        end
    else
        if q==0
            if r==0
                % case: Neg triggers, NO rand init, also NO rand recalc
                ownAlgoHPC(source_dir, source_fname, target_dir, no_of_simulations,...
                    max_r, ang_bins, i, j, pt_count(k), true, false, false);
                GreedyHPC(source_dir, source_fname, target_dir, no_of_simulations,...
                    max_r, ang_bins, i, j, pt_count(k), true, false, false);
                counter = counter+1;
            else
                fprintf("Nothing to do. This case does not exist\n");
            end
        else
            if r==0
                % case: Neg triggers, rand init, NO rand recalc
                ownAlgoHPC(source_dir, source_fname, target_dir, no_of_simulations,...
                    max_r, ang_bins, i, j, pt_count(k), true, true, false);
                GreedyHPC(source_dir, source_fname, target_dir, no_of_simulations,...
                    max_r, ang_bins, i, j, pt_count(k), true, true, false);
                counter = counter+1;
            else
                % case: Neg triggers, rand init, rand recalc
                ownAlgoHPC(source_dir, source_fname, target_dir, no_of_simulations,...
                    max_r, ang_bins, i, j, pt_count(k), true, true, true);
                GreedyHPC(source_dir, source_fname, target_dir, no_of_simulations,...
                    max_r, ang_bins, i, j, pt_count(k), true, true, true);
                counter = counter+1;
            end
        end
    end
end
end

