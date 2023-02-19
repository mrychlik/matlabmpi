This is a parallel implementation of the Icosian Hamilton Circuit
Problem. As we know, this problem is NP-complete in its full generality
(i.e., for arbitrary graphs).

The parallelism is implemented in the method \'sim_aux\' in the class
tsp_solver (file [tsp_solver.m](tsp_solver.m)).

This implementation is based on the \'spmd\' block and MPI constructs:

labindex
:   Gets the number (id) of the lab.

labBarrier
:   Waits for all threads to reach the barrier in their execution.

gop (Global Operation)
:   Peforms a reduction of the values local to threads to obtain a
    global value; for instance, it can be used to calculate sum or
    minimum across all threads.

The word \'spmd\' stands for \'Single Program, Multiple Data\'. The
program within the \'spmd\' block executes in all worker threads (or
labs, using MPI terminology). The number of labs is explicitly set up in
the script [icosian_script.m](icosian_script.m) to be 8. Otherwise, the
default number of labs would be used, as set up by the MATLAB GUI menu
Parallel \> Parallel Preferences.
