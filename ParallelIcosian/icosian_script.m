p = gcp('nocreate');
numWorkers = 20; % Desired number of workers
if isempty(p) || p.NumWorkers < numWorkers
    delete(p)
    p=[]
end
if isempty(p)
    p = parpool('local',numWorkers); % Create a local parpool
end
mpiInit;


[A, V, W] = icosian;

% Visualize Icosian graph and its Hamiltonian circuit
G = graph(A);
H = circuit_to_subgraph(V, W);
h = plot(G,'Layout', 'force3');
highlight(h, H, ...
          'EdgeColor', 'r', ...
          'LineWidth', 2);
drawnow;

D = double(~A);                      % Distance matrix for Hamiltonian
                                        % circuit
rng(666,'twister');

% Create tsp_solver with default cost matrix
obj = tsp_solver(D, ...
                 'beta', 0.01, ...
                 'betaIncrement', 0.04, ...
                 'numRuns', 1000, ...
                 'tau', .5,...
                 'visualize', false,...
                 'energyChangeThreshold', 6e-2,...
                 'energyThreshold', .5);

% Compute the Hamiltonian circuit as matrix
X = circuit_to_matrix(V, W);
assert( energy(obj, X) == 0);

assert( validate(obj) );

% Run simulation
tic;
obj = sim(obj);
toc;


% Print best cost
disp(obj.best);

if obj.best.E == 0
    figure;
    K = matrix_to_subgraph(obj.best.x);
    h = plot(G,'Layout', 'force3');
    highlight(h, K, ...
              'EdgeColor', 'b', ...
              'LineWidth', 4);
    title('Found Hamiltonian Circuit');
end
