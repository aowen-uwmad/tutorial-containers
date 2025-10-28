#!/bin/bash

cat << EOF

Requesting an interactive session.
Once it starts, remember to 'exit' before running any 'srun' or 'sbatch' commands!

EOF

sleep 1s

cat << EOF
You should be logged into an interactive node shortly...

EOF

sleep 1s

# The following command launches an interactive session on Slurm.
srun --mpi=pmix --ntasks=4 --nodes=1 --time=240 --partition int --pty bash

cat << EOF

You have exited the interactive session.

EOF
