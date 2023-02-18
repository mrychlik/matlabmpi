d = [ 0 3 9 7;
      3 0 6 5;
      5 6 0 6;
      9 7 4 0 ];

D = d + 4 .* eye(4);

% Create tsp_solver with sample
obj = tsp_solver(D, ...
                 'beta', 1, ...
                 'betaIncrement', .02, ...
                 'numEpochs', 1000,...
                 'tau', 5,...
                 'energyChangeThreshold', 1e-3,...
                 'energyThreshold', 17.5,...                 
                 'visualize', true);

assert( validate(obj) );

% Run simulation
tic;
obj=sim(obj);
toc;

% Print best cost
disp(obj.best);

