function [outputArg2] = bigfunction(i,j,k,p,q,r)
%BIGSCRIPT Function to call the different Algorithms dependant on their
%config in p,q and r. i, j, k just get passed into the algorithms
%   Storing the files should be executed within the functions
%   Functions should not return anything
%   Functions should store variables success(q) and steps(q)
%   Functions should combine source_dir and source_fname with fullfile();
%   Functions should load the initial list of waypoints from a SINGLE file

source_dir = "Sims";
source_fname = "Simulation_";
target_dir = fullfile('Results','All_Cases');

% preliminary stuff
no_of_simulations = 200;          %% _CAREFUL! HAVE TO CHANGE_ 
max_r = 10;
ang_bins = 18;

% Decisions are being made on the p, q and r variables
% p is Negative triggers
% q is Random Initialization
% r is random recalculation
if p ==0  
    if q==0
        if r==0
            % case: NO Neg triggers, no rand init, also no rand recalc
            ownAlgoHPC(source_dir, source_fname, target_dir, no_of_simulations,...
                max_r, ang_bins, i, j, k, false, false, false);
            GreedyHPC(source_dir, source_fname, target_dir, no_of_simulations,...
                max_r, ang_bins, i, j, k, false, false, false);
        else
            fprintf("Nothing to do. This case does not exist");
        end
    else
        if r==0
            % case: NO Neg triggers, rand init, no rand recalc
            ownAlgoHPC(source_dir, source_fname, target_dir, no_of_simulations,...
                max_r, ang_bins, i, j, k, false, true, false);
            GreedyHPC(source_dir, source_fname, target_dir, no_of_simulations,...
                max_r, ang_bins, i, j, k, false, true, false);
        else
            % case: NO Neg triggers, Rand init, Rand recalc
            ownAlgoHPC(source_dir, source_fname, target_dir, no_of_simulations,...
                max_r, ang_bins, i, j, k, false, true, true);
            GreedyHPC(source_dir, source_fname, target_dir, no_of_simulations,...
                max_r, ang_bins, i, j, k, false, true, true);
        end
    end
else
    if q==0
        if r==0
            % case: Neg triggers, NO rand init, also NO rand recalc
            ownAlgoHPC(source_dir, source_fname, target_dir, no_of_simulations,...
                max_r, ang_bins, i, j, k, true, false, false);
            GreedyHPC(source_dir, source_fname, target_dir, no_of_simulations,...
                max_r, ang_bins, i, j, k, true, false, false);
        else
            fprintf("Nothing to do. This case does not exist");
        end
    else
        if r==0
            % case: Neg triggers, rand init, NO rand recalc
            ownAlgoHPC(source_dir, source_fname, target_dir, no_of_simulations,...
                max_r, ang_bins, i, j, k, true, true, false);
            GreedyHPC(source_dir, source_fname, target_dir, no_of_simulations,...
                max_r, ang_bins, i, j, k, true, true, false);
        else
            % case: Neg triggers, rand init, rand recalc
            ownAlgoHPC(source_dir, source_fname, target_dir, no_of_simulations,...
                max_r, ang_bins, i, j, k, true, true, true);
            GreedyHPC(source_dir, source_fname, target_dir, no_of_simulations,...
                max_r, ang_bins, i, j, k, true, true, true);
        end
    end
end


outputArg2 = 0;
end

