% FILE: parfevalEx1.m
p = gcp(); % get the current parallel pool

f = parfeval(p,@magic,1,10);            % Work in the background
x = (1:10).^2;                          % Do this while f is working
value = fetchOutputs(f); % Blocks until dcomplete
value
x
