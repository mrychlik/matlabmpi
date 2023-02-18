% FILE: race1FixedBroadcast.m
% This file demonstrates a simple race condition
% when trying to share a value between all workers
% NOTE: In this version, we avoid the race condition
% by using labBroadcast.

p=gcp('nocreate');
if isempty(p)
    p = parpool('local', 8)
end

disp(sprintf('Number of workers: %d', p.NumWorkers));

value = Composite();

% An incorrect way to broadcast a value and
% receive it in all workers

root=1;
spmd 
    pause(rand()./10);
    if labindex == root
        value = 7;
        value = labBroadcast(root, value);
        display(sprintf('Root==%d broadcast %d',labindex,value));
    else
        value = labBroadcast(root, 666); % Second inut ignored on root
        display(sprintf('%d received %d from root==%d',labindex,value,root));
    end
end

for w=1:p.NumWorkers
    disp([w,value{w}]);
end
