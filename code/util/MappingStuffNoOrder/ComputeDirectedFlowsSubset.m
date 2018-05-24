function Flows = ComputeDirectedFlowsSubset(dists, inds)
% Returns the directed flow matrix a la "Eyes on the Prize I" for given indices 
%
%Input
%dists: matrix of size m x n
%inds: matrix of size 1 x z, list of indices in dists to calculate flow for 
%
%Output:
%Flows: cell of size z x z with each entry denoting the directed adjacency
%matrix of flows from i to j

[m,n] = size(dists);
z     = length(inds);
dists = .5*dists+.5*dists';         %symmetrize as sanity check
Flows = cell(m,n);

for i = inds
    
    for j = inds
        fprintf('%d %d \n',i,j);
        Flows{i,j} = sparse(m,n);
        if i ~= j
            dummy = sparse(m,n);
            parfor k = inds
                for q = inds
                    d_ik = graphshortestpath(sparse(dists),i,k);
                    d_iq = graphshortestpath(sparse(dists),i,q);
                    if d_ik < d_iq
                        d_jk = graphshortestpath(sparse(dists),j,k);
                        d_jq = graphshortestpath(sparse(dists),j,q);
                        if d_jk > d_jq
                            dummy(k,q) = 1;
                        end
                    end
                end
            end
            Flows{i,j} = dummy;
        else
            Flows{i,j}(i,j) = 1;
        end
    end
end
end