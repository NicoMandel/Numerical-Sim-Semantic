function [successWeightedPathLength] = SPL_Acc(no_sims, min_path_length, steps, successes)
%SPL Success Weighted Path Length calculation by formula in Paper
%   uses the formula from the paper to calculate the success weighted path
%   length. 

rel_path_l = min_path_length./steps;
val = rel_path_l.*successes;
aggr = sum(val);
successWeightedPathLength = aggr/no_sims;
end

