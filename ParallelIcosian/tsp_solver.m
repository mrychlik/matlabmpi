%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% M-file : tsp_solver.m
%% Author: Marek Rychlik (10-9-2018)
%% 
%% Implements Hopfield-Tank model from the 1985 paper.
%% In this version, we use an ODE solver to solve the
%% continuous system for Hopfield-Tank.
%%
%% Object-oriented version.
%%
%% It features parallelized computation running continuous-time Hopfield
%% model training algorithm for multiple random initial conditions in
%% parallel.
%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef tsp_solver

    properties

        d;                              % cost matrix
        beta;                           % Inverse temp
        initial_beta;                   % Beta to start withh
        delta_beta;                     % Annealing - inverse temp increment
        gamma;                          % lower bound on optimal cost
        n;
        R;
        num_runs;
        tau;
        visualize;                      % Turn visualization on/off
        num_epochs;                     % Number of epochs (= intervals)
        E_change_threshold;             % Minimum change of energy
        E_threshold;                    % Stop search if best energy
                                        % drops below this

        gradient_delta = 1e-5;          % Delta for numerical gradient
        gradient_err_threshold = 1e-3;  % Gradient validation constant
        done = false;                   % Stop if this is set
        best = [];                      % Best solution
    end

    properties(Constant)
        initial_best = struct('E',Inf, 'x', []);
    end;


    methods
        function obj = tsp_solver(d, varargin)
            p = inputParser;
            validCostMatrix = @(x) size(x,1)==size(x,2);
            addRequired(p,'d',validCostMatrix);

            defaultBeta = 1;                    % Inverse temp.
            validBeta = @(x) isnumeric(x) && isscalar(x) && (x > 0);
            addParameter(p, 'beta', defaultBeta, validBeta);

            defaultDeltaBeta = .1;
            validDeltaBeta = @(x) isnumeric(x) && isscalar(x) && (x > 0);
            addParameter(p, 'betaIncrement', defaultDeltaBeta, validDeltaBeta);

            defaultTau = 1;
            validTau = @(x) isnumeric(x) && isscalar(x) && (x > 0);
            addParameter(p, 'tau', defaultTau, validTau);

            defaultNumRuns = 10;
            validNumRuns = @(x) isnumeric(x) && isscalar(x) && (x > 0);
            addParameter(p, 'numRuns', defaultNumRuns, validNumRuns);

            defaultNumEpochs = 1000;
            validNumEpochs = @(x) isnumeric(x) && isscalar(x) && (x > 0);
            addParameter(p, 'numEpochs', defaultNumEpochs, validNumEpochs);

            defaultEnergyChangeThreshold = 1e-3;
            validEnergyChangeThreshold = @(x) isnumeric(x) && isscalar(x) && (x > 0);
            addParameter(p, 'energyChangeThreshold', ...
                         defaultEnergyChangeThreshold, ...
                         validEnergyChangeThreshold);

            defaultEnergyThreshold = -Inf; % Never stop because energy met
            validEnergyThreshold = @(x) isnumeric(x) && isscalar(x) && (x > 0);
            addParameter(p, 'energyThreshold', defaultEnergyThreshold, ...
                         validEnergyThreshold);

            defaultVisualize = false;
            validVisualize = @(x) islogical(x) && isscalar(x);
            addParameter(p, 'visualize', defaultVisualize, validVisualize);

            parse(p, d, varargin{:});

            obj.d = p.Results.d;
            obj.initial_beta = p.Results.beta;
            obj.delta_beta = p.Results.betaIncrement;
            obj.tau = p.Results.tau;
            obj.num_runs = p.Results.numRuns;
            obj.visualize = p.Results.visualize;
            obj.num_epochs = p.Results.numEpochs;
            obj.E_change_threshold = p.Results.energyChangeThreshold;
            obj.E_threshold = p.Results.energyThreshold;            

            obj.n = size(obj.d, 1);
            obj.R = obj.n;
            obj.gamma = min(sum(max(obj.d,[],1)), sum(max(obj.d,[],2)));
        end

        function obj = sim(obj)
        %Simulates the continuous-time Hopfield training 
        % ODE OBJ=SIM(OBJ) performs multiple runs of the Hopfield model
        % continuous time training ODE for randomly chosen initial
        % conditions.
            E_best = Inf;
            for run = 1:obj.num_runs
                disp(sprintf('Run: %d', run));
                obj = sim_aux(obj);
                if obj.best.E < E_best;
                    E_best = obj.best.E;
                    best_obj = obj;
                    disp(sprintf('Best energy: %6.2g', E_best));
                end
                if E_best < obj.E_threshold
                    break;
                end
            end
            obj = best_obj;

            disp('---------------- RESULTS ----------------');
            disp(sprintf('Best cost: %g', obj.best.E));
            disp(obj.best.x);
        end

        function obj = sim_aux(obj)
        %Runs the continuous Hopfield model training on all labs
        % OBJ = SIM_AUX(OBJ) solves the ODE that trains the
        % weights of the Hopfield model on all labs (workers)
        % in parallel
            obj.best  = tsp_solver.initial_best;
            ret_obj = Composite();
            % Explicitly creating Composite variables.
            % You can think of them as being cell arrays whose
            % cells belong to separate labs (threads). Within the
            % SPMD block you don't need to use the cell syntax.
            % Just use them as if they were ordinary variables.
            E_optimal = Composite();
            x_optimal = Composite();            
            best_idx = Composite();
            spmd
                loc_obj = obj;
                loc_obj.beta = loc_obj.initial_beta;
                [t, x, E] = seek_equilibrium(loc_obj);
                E_final = E(end);

                % Round the final solution to the nearest vertex
                x_optimal = round(squeeze(x(end,:,:)));
                E_optimal = energy(loc_obj, x_optimal);
                loc_obj.best = struct('E', E_optimal, 'x', x_optimal);

                labBarrier;

                E_best = gop(@min,E_optimal);
                
                labBarrier;

                if E_best == E_optimal
                    best_idx = labindex;
                end
            end
            
            % Note that loc_obj is an implicitly created Composite.
            % We need to pick the best solution by selecting
            % the object with index determined by BEST_IDX. However,
            % BEST_IDX is also a composite, whose value is empty
            % in the labs which produced a suboptimal solution. Therefore
            % we use EXIST to figure out which cells of the BEST_IDX are
            % non-empty (the result is a 'mask'). EXIST returns an
            % ordinary array of 0-1. We use FIND to get the lab indices
            % of the optimal solutions. In fact, we only FIND the first
            % optimal solution. Then we extract the optimal object using
            % normal cell array indexing (curl braces syntax).
            
            obj = loc_obj{ find(exist(best_idx), 1) };
        end

        function [tn, xn, En] = seek_equilibrium(obj)
        %Seek equilibrium state of the Hopfield-Tank model
        % [X, E] = SEEK_EQUILIBRIUM(P) accepts parameters P of the
        % Hopfield-Tank model and returns optimual equilibrium configuration
        % X. The second value is the energy of the state X.

            x0 = rand([obj.n, obj.n]);  % Generate random initial condition
            t0 = 0;
            y0 = x0(:);

            tn = [];
            yn = [];
            xn = [];    
            En = [];

            for epoch = 1:obj.num_epochs
                [t, y] = ode23(@(y,t)vector_field(obj,y,t), [t0, t0+1], y0);
                %[t, y] = ode45(@(y,t)vector_field(obj,y,t), [t0, t0+1], y0);                
                y0 = y(end,:);
                t0 = t(end);

                x = reshape(y, [size(y,1), obj.n, obj.n]);
                xx = squeeze( x(end,:,:) );

                E = zeros(size(x,1),1);
                for j=1:size(x,1)
                    E(j) = energy(obj, squeeze(x(j,:,:)) );
                end

                % Gather results
                xn = [xn;x];
                tn=[tn;t];
                yn=[yn;y];        
                En = [En;E];

                % Visualization
                if mod(epoch, 2) == 0 && obj.visualize
                    subplot(2,2,[1,2]),plot(tn,En),
                    title(sprintf('Epoch: %3d, learning: %6.3g, beta: %6.3g', ...
                                  epoch, E(end), obj.beta)),
                    subplot(2,2,3),imagesc(xx),
                    title('Matrix'),
                    subplot(2,2,4),plot(tn,yn),
                    title('Entries vs. time'),
                    drawnow;
                end

                if range(E) < obj.E_change_threshold
                    if obj.visualize
                        disp(sprintf(['Stopping in epoch %3d on threshold ' ...
                                      'met.'], epoch));
                    end
                    break;
                end
                obj.beta = obj.beta + obj.delta_beta;
            end
        end

        function E = energy(obj, x)
        %Computes Hopfield-Tank energy
        % E = ENERGY(X) takes an N-by-N matrix X of values in (0,1)
        % and returns energy E according to the Hopfield-Tank Model
            E = sum(obj.d .* (x * circshift(x, -1, 2)'), 'all') ...
                + obj.gamma .* sum( (sum(x, 1) - 1) .^ 2) ...
                + obj.gamma .* sum( (sum(x, 2) - 1) .^ 2 ) ...
                + obj.R .* sum(x .* (1 - x), 'all') ...
                + obj.gamma .* (x(1,1)-1)^2;
            ;
        end


        function g = energy_gradient(obj, x)
        %Computes the gradient of the Hopfield-Tank energy
        % G = ENERGY_GRADIENT(X) takes an N-by-N matrix X of values in (0,1)
        % and returns the matrix G of the same shape as X, which is
        % the gradient of the Hopfield-Tank energy.
            g = obj.d  * circshift(x,  -1, 2)  + ...
                obj.d' * circshift(x, 1, 2) ...
                + 2 .* obj.gamma .* ( (sum(x,2) - 1) * ones(1, obj.n) ) ...
                + 2 .* obj.gamma .* ( ones(obj.n, 1) * (sum(x,1) - 1) ) ...
                + obj.R .* (ones([obj.n, obj.n]) - 2 .* x);
            g(1,1) = g(1,1) + 2 .* obj.gamma .* (x(1,1)-1);
        end    

        function g = energy_gradient_est(obj, x)
        %Computes the gradient of the Hopfield-Tank energy
        % G = ENERGY_GRADIENT(X) takes an N-by-N matrix X of values in (0,1)
        % and returns the matrix G of the same shape as X, which is
        % the gradient of the Hopfield-Tank energy.
            g = zeros([obj.n,obj.n]);
            for r = 1:obj.n
                for c = 1:obj.n
                    x1 = x; x2 = x;
                    x1(r,c) = x1(r,c) + obj.gradient_delta;
                    x2(r,c) = x2(r,c) - obj.gradient_delta;
                    g(r,c) = ( energy(obj, x1) - energy(obj, x2) ) ./...
                             (2 .* obj.gradient_delta);
                                                                      
                end
            end
        end    

        function dydt = vector_field(obj, t, y)
        %Computes the vector field
        % DYDT = VECTOR_FIELD(OBJ, T, Y) finds the vector dY/DT
        % according to the continuous Hopfield model training equation.
            x = reshape(y, [obj.n, obj.n]);% Translate to 2D array
            g = energy_gradient(obj, x);% Find gradient
            b = tsp_solver.sigmoid( -obj.beta .* g );% find activity
            dxdt = - (x - b) ./ obj.tau;% Define vector field
            dydt = dxdt(:);             % Translate to 1D array
        end

        function r = validate(obj)
        %Validate the gradient expression
        % R = VALIDATE(OBJ) validates the gradient
        % expression by using the exact formula
        % and comparing to the estimate obtained using
        % difference quotients.
            x = rand([obj.n, obj.n]);
            g1 = energy_gradient_est(obj, x);
            g = energy_gradient(obj, x);
            err = norm(g1(:) - g(:))
            if err < obj.gradient_err_threshold
                r = true;
            else
                r = false;
            end
        end
    end;                                

    methods(Static)
        function y = sigmoid(x)
            y = 1 ./ (1 + exp(-x));
        end
    end

end