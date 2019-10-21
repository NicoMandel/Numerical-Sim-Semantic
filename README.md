# Numerical-Sim-Semantic
 MATLAB Numerical Simulations for Semantic Navigation - including results
 
## 1. Setup

The HPC-Scripts create a shell script which logs a job for all _valid_ combinations of i,j,k,p,q,r calling bigfunction.m, which in turn
will once call Greedy and once our own Algorithm. These functions subsequently call all 200 Simulation files with the parameters given before.
Each combination of the algorithms will run and write the results with the filename in order Algorithm-i-j-k-p-q-r.mat into the results. 
These functions return the results too, but they are unused.
The random algorithm is run without a script for all combinations of i,j,k and stored in the random-Algorithm folder.

## 2. Results
Are structured in the Results folder. All cases are all 909 combinations finished from above, Random cases are the additional ones.
Some GPU Cases for trial and error reasons
The Files `A_Parse_All` is used to inspect results, reading results into an 8-Dimensional Array according to their filenames and then structuring the output
in desired formats. 


## Known Issues
The GPU versions accelerate the process, but do not allow for parfor processing of all files, due to memory errors 
The bigfunction.m 
