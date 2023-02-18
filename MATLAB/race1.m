% FILE: race1.m
% This file demonstrates a simple race condition
% when trying to share a value between all workers
p=gcp('nocreate');
if isempty(p)
    p = parpool('local', 8)
end

disp(sprintf('Number of workers: %d', p.NumWorkers));

value = Composite();

% An incorrect way to broadcast a value and
% receive it in all workers

spmd 
    pause(rand()./10);

    if labindex == 1
        for w=1:numlabs
            display(sprintf('%d sending 7 to %d',labindex,w));
            labSend(7,w);
        end
    end

    value = labReceive;
    display(sprintf('%d received %d from 1',labindex,value));


end

for w=1:p.NumWorkers
    disp(value{w});
end
