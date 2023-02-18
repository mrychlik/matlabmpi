% FILE: parforEx.m
%p=gcp();                               
%mpiInit;
n=10;
% Evaluate x^2 for 1:n asynchronously and print results
parfor i=1:n
    x=i^2
    %pause(1);
    disp([i,x]);
end
disp('All done');
