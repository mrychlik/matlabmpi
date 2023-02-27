#!/bin/bash
# EXAMPLE: Print 'Hello, ' and 'World!'
# in random order w/o a random number generator.
# HINT: We deliberately create a race condition.
if (($#)) ;then ntimes=$1 ;else ntimes=10; fi
function hello {
    echo -n "Hello, "
}
function world {
    echo -n "World!"
}
dlay=1e-2  # Change to 5 to see processes
for (( j=0; $j<$ntimes; j=$j+1 ))
do
    # Fork with '&'
    (sleep $dlay; hello) & (sleep $dlay; world)
    echo " --Done with iteration: $j"
done
