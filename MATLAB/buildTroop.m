% FILE:   buildTroop.m

% Efficient graph encoding (often used in MPI programs)
% Adjacency matrix; passed as 1-d aray, in which each vertex is followed
% Row format: node followed by neighbors, sentinel 0.
% A final zero is added to terminate the structure.
adj=[1,2,0,...
     2,1,3,11,0,...
     3,2,4,5,0,...
     4,3,0,...
     5,3,0,...
     6,8,0,...
     7,8,0,...
     8,6,7,9,0,...
     9,8,10,12,0,...
     10,9,11,0,...
     11,2,10,0,...
     12,9,13,14,0,...
     13,12,0,...
     14,12,0,...
     0];

% Automatically determine te number of soldiers (nodes)
numSoldiers = numel(find(adj==0))-1;
commander = 9;                          % Designate the commander

% Start the parpool (thread pool)
p = gcp('nocreate');
if ~isempty(p) && p.NumWorkers < numSoldiers
    delete(p);
    p=[];
end
if isempty(p)
    p = parpool('local',numSoldiers);
end


mpiInit;

% Convert nb to cell array
nb=Composite();
start=1;
for s=1:numSoldiers;
    me=adj(start);
    neighbors=[];
    n=start+1;
    % Make a list of neigbors
    while adj(n)~=0
        neighbors=[neighbors,adj(n)];
        n=n+1;
    end
    nb{me}=neighbors;
    start=n+1;
end
assert(adj(start)==0);

% A normal function call to let soldiers report the neighbors
report(nb);

% A consistency check for graph data
I=adjacency_matrix(nb);
% Check symmetry of the adjacency relation
assert(all(all(I==I')));
% Check for 'no loops' (loop=connection of edge to itself)
assert(all(diag(I)==0));
% Check for 'no cycles'; upper triangular portion of I should be nilpotent
assert(all(all( triu(I)^numSoldiers==0)));

%g = graph(I);
%plot(g,'LineWidth',4,'NodeFontSize',44,'MarkerSize',5,'NodeLabelColor','blue','NodeFontWeight','bold');
