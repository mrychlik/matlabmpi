% FILE: norace1.m
% This file demonstrates the best way for
% workers to share a value.
% NOTE: The new command is spmdBroadcast and it replaces labBroadcast.
p=gcp('nocreate');
if isempty(p)
    p = parpool('local', 8)
end

disp(sprintf('Number of workers: %d', p.NumWorkers));

value = Composite();

% The correct and best way to broadcast a value and
% receive it in all workers
spmd
    pause(rand()./10);
    % Send 7 to all workers from root 1
    value = spmdBroadcast(1, 7);
    display(sprintf('%d received broadcast %d',labindex,value));
end

for w=1:p.NumWorkers
    disp(value{w});
end
