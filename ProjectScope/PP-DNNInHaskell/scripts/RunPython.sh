##
## CNN-PhD version 0.1, Copyright (C) 3/Mar/2018
## Modifier: rval735
## This code comes with ABSOLUTELY NO WARRANTY; it is provided as "is".
## This is free software under GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version. Check the LICENSE file at the root
## of this repository for more details.
##
## Description: This bash script will execute the python Neural Network
## in the NNMNIST for variable parameters to obtain an statistical
## sample of the execution for the time and error of it.
## ¡NOTE! Consider its execution within the same folder of the python code

#!/bin/bash

PYCODE="NNMNIST.py"
HNODES=(5 10 20 50 100)
LRATE=(0.001 0.01 0.1)
EPOCHS=(3 5 8 13)
RESULTS="NNMNIST-Results.cvs"

echo "This code will execute $PYCODE for the following parameters:"
echo "Hidden Nodes: ${HNODES[@]}"
echo "Learning Rate: ${LRATE[@]}"
echo "Epochs: ${EPOCHS[@]}"
echo "Will be saved in the file $RESULTS"

for i in ${HNODES[@]}; do
    for j in ${LRATE[@]}; do
        for k in ${EPOCHS[@]}; do
            time python $PYCODE $i $j $k >> $RESULTS
        done
    done
done

perl -ne 'print if ! $a{$_}++' $RESULTS > TEMP
mv TEMP $RESULTS
