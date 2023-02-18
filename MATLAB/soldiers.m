% FILE:     soldiers.m
% Mackay, algorithm 16.1: to count soldiers
% marching in line
%
% NOTE: If you are running the program on a
% processor with n=4 cores and 2*n
% hyperthreads, the setting for the 'local'
% cluster is used, and the number of workers
% in a parpool is set automatically to n,
% ignoring hyperthreading.  You can modify
% the number of worker threads using Matlab
% GUI, using Home > Parallel > Manage Cluster
% Profiles > Edit.  So, if you request 8
% workers, make sure to first edit the local
% profile and increate the number of allowed
% workers to >=8. I changed it to 64.
%
p = gcp('nocreate');
numSoldiers=5;
% Must have at least numSoldiers workers
if ~isempty(p) && p.NumWorkers < numSoldiers
    delete(p);
    p=[];
end
if isempty(p)
    % Create a local parpool with num. workers == num. soldiers
    p = parpool('local',numSoldiers); 
end
mpiInit;
commander=2;
% Must have at least commander+1 workers
assert(p.NumWorkers > commander);
spmd
    me=labindex;
    value=0;
    if me==commander
        [value1,source1,tag1]=labReceive;
        fprintf('%d=commander got %d from %d\n',me,value1,source1);
        [value2,source2,tag2]=labReceive;
        fprintf('%d=commander got %d from %d\n',me,value2,source2);
        value=value1+value2+1;
        fprintf('%d=commander says: count is %d\n',me,value);
    elseif me==1
        value=1;
        dest=2;
        fprintf('%d sending %d to %d\n',me,value,dest);
        labSend(value,dest);
    elseif me==numlabs
        value=1;
        dest=me-1;
        fprintf('%d sending %d to %d\n',me,value,dest);
        labSend(value,dest);
    else
        [value,source,~]=labReceive;
        value=value+1;
        if source==me-1
            dest=me+1;
        elseif source==me+1
            dest=me-1;
        end
        fprintf('%d sending %d to %d\n',me,value,dest);        
        labSend(value,dest);
    end
end



