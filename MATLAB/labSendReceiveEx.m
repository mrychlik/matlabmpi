% FILE: labSendReceiveEx.m
% This file demonstrates collective communications done by MPI
% In every worker (lab) we create data (a magic square of the dimension
% equal to the labindex of the worker. Then we spin the data in a circle.
% Note that we **MUST** arrange pairing so that everybody sends one
% message and receives one message. Else, a race condition will
% result.
gcp();                                  % Start parpool with default
                                        % number of workers
mpiInit;

howmany = [];
spmd
    if(labindex == 1)
        disp(sprintf('Number of labs: %d', numlabs));
        howmany = numlabs;
    end;
    mydata    = magic(labindex);
    labTo     = mod(labindex, numlabs) + 1; % one lab to the right
    labFrom   = mod(labindex - 2, numlabs) + 1; % one lab to the left
    otherdata = labSendReceive(labTo, labFrom, mydata);
end

disp(sprintf('Number of labs: %d', numlabs));
disp(sprintf('Parallel code executed on this many labs: %d', howmany{1}));
