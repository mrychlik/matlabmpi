% FILE: reductionVar.m
% This file demonstrates a useful notion of a 'Reduction Variable'
% Makes it possible to accumulate values in a parfor without using
% spmd/gop.

p=gcp('nocreate');
if isempty(p)
    p = parpool('local', 8)
end

disp(sprintf('Number of workers: %d', p.NumWorkers));

x=[];

parfor i = 1:10
    pause(rand());
    disp(i);
    x = [x, i];
end

x
