function [successWeightedPathLength] = SPL(no_sims, path_l, successes)
%SPL Success Weighted Path Length calculation by formula in Paper
%   uses the formula from the paper to calculate the success weighted path
%   length. Path_l should already be min_length / steps_taken

val = path_l.*successes;
aggr = sum(val);
successWeightedPathLength = aggr/no_sims;
end

