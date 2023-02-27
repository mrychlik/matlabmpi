% FILE: race1Fixed.m
% This file demonstrates a simple race condition
% when trying to share a value between all workers.
% NOTE: We avoid sending to ourselves. This
% avoids the race condition.

p=gcp('nocreate');
if isempty(p)
    p = parpool('local', 8)
end

disp(sprintf('Number of workers: %d', p.NumWorkers));

value = Composite();

% A correct way to broadcast a value and
% receive it in all workers. However, lab 1 runs in O(n) time,
% so it is not an efficient way to broadcast data to others.

spmd 
    pause(rand()./10);

    if labindex == 1
        for w=2:numlabs
            display(sprintf('%d sending 7 to %d',labindex,w));
            labSend(7,w)
        end
        value = 7;
    else
        value = labReceive;
        display(sprintf('%d received %d from 1',labindex,value));
    end

end

for w=1:p.NumWorkers
    disp([w,value{w}]);
end
