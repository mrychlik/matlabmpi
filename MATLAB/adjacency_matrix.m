function I=adjacency_matrix(nb)
%ADJACENCY_MATRIX converts the neighbors cell array to adjacency matrix.
% I=ADJACENCY_MATRIX(NB) accepts a cell array NB of cells containing
% neighbors of nodes of the graph and it constructs the corresponding adjacency matrix I.
    N=length(nb);
    %I=sparse(N,N);
    I=zeros(N,N);
    for i=1:N;
        I(i,nb{i})=1;
    end
end
