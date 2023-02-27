% FILE: race1FixedBroadcast.m
% This is a fix for the file race1.m demonstrating a simple race condition.
% In this version, we avoid the race condition by using labBroadcast.
% This is the best way to share the value in terms of performance.

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
