% FILE: gopEx.m
%This example shows how to calculate the sum and maximum values
%for x among all workers.
p = gcp();


% Ensure that we have enough workers or this example.
assert(p.NumWorkers >= 4);

x = Composite() 
x{1} = 3;
x{2} = 1;
x{3} = 4;
x{4} = 2;

x                                       % Examine x

% Make sure there is a value in every worker
for i=5:p.NumWorkers
    x{i} = 0;
end

x                                       % Examine x again

spmd
    xsum = gplus(x);
    xmax = gop(@max,x);
end

for i=1:p.NumWorkers
    disp(sprintf('Sum in worker %d is %d',i, xsum{i}))
    disp(sprintf('Max in worker %d is %d',i, xmax{i}))    
end
