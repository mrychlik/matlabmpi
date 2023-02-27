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
        value_to_broadcast = 7;
        display(sprintf('Root==%d will broadcast %d',labindex,value_to_broadcast));
        value = labBroadcast(root, value_to_broadcast);
    else
        value = labBroadcast(root, 666); % works on root, the second input is ignored
        display(sprintf('%d received %d from root==%d',labindex,value,root));
    end
end

for w=1:p.NumWorkers
    disp([w,value{w}]);
end
