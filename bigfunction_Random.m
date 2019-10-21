function [counter] = bigfunction_Random(i,j, counter)
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
no_of_simulations = 200;          %% _CAREFUL! HAVE TO CHANGE_ 


% Decisions are being made on the p, q and r variables
% p is Negative triggers
% q is Random Initialization
% r is random recalculation
pt_count = [1 2 3 5 8];
pt_len = size(pt_count,2);
for k = 1:pt_len
    RandomFunc(source_dir, source_fname, target_dir,...
        no_of_simulations, i, j, pt_count(k));
    counter= counter+1;
end
end

