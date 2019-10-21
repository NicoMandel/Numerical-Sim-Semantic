#!/bin/bash

# These are the limits for the hpc script
memory_limit="2000mb"
time_limit="3:30:00"
cputype="6140"
header_1="#!/bin/bash -l"
header_2="#PBS -l walltime=${time_limit}"
header_3="#PBS -l mem=${memory_limit}"
header_4="#PBS -l cputype=${cputype}"

# Body for the hpc script
body_1="module load matlab/2018b"
body_2="cd \$PBS_O_WORKDIR"

# General stuff for the script
gen_stat_file="general_status_overview.txt"

# Value changes here - counter to ensure to stay below limit
# Current iteration count = 560
p=1
q=0
r=0
for i in 4 7 10 15
do
	for j in 0.5 0.75 1.0 1.25
	do
		for k in 1 2 3 5 8
		do	
			this_script_file="sim_case-${i}-${j}-${k}-${p}-${q}-${r}.sh"
			echo ${header_1} >> ${this_script_file}
			echo ${header_2} >> ${this_script_file}
			echo ${header_3} >> ${this_script_file}
			echo ${header_4} >> ${this_script_file}
			echo "#PBS -N NM_${i}_${j}_${k}_${p}_${q}_${r}" >> ${this_script_file}
			
			echo ${body_1} >> ${this_script_file}
			echo ${body_2} >> ${this_script_file}
			
			# Will this hang up the hpc by using /r instead of -r ?
			echo "matlab -nodisplay -r 'bigfunction(${i}, ${j}, ${k}, ${p}, ${q}, ${r})' quit" >> ${this_script_file}
			qsub ${this_script_file}
			mv ${this_script_file} script_files/
	
		done
	done
done


# This is to save where we currently are
echo "Last Submitted iteration:" >> ${gen_stat_file}
echo "Bin Threshold i=${i}" >> ${gen_stat_file}
echo "Distance Threshold j=${j}" >> ${gen_stat_file}
echo "Intermediate Points k=${k}" >> ${gen_stat_file}
echo "With Negative Triggers p=${p}" >> ${gen_stat_file}
echo "With Random Initialisation (The same for all cases) q=${q}" >> ${gen_stat_file}
echo "With Random Recalculation r=${r}" >> ${gen_stat_file}
