function Flows = ComputeDirectedFlowsSubset(genus)
% Returns the directed flow matrix a la "Eyes on the Prize I" for given indices 
%
%Input
%dists: matrix of size m x n
%inds: matrix of size 1 x z, list of indices in dists to calculate flow for 
%
%Output:
%Flows: cell of size z x z with each entry denoting the directed adjacency
%matrix of flows from i to j

outputDir = fullfile(pwd, '../output/');
flowDir = fullfile(outputDir, '/etc/flows/');

genusMap = load(fullfile(outputDir, '/etc/genusMap.mat'));
genusMap = genusMap.genusMap;
inds = genusMap(genus);

g_dir = fullfile(flowDir, genus);
touch(g_dir);

cpDist = load(fullfile(outputDir, '/etc/cpd/cpDistMatrix.mat'));
dists = cpDist.cpDist;

[m,n] = size(dists);
z     = length(inds);
dists = .5*dists+.5*dists';         %symmetrize as sanity check
Flows = cell(m,n);

nInds = length(inds);

for i = inds
    for j = inds
        fprintf('%d %d \n',i,j);
        Flows{i,j} = sparse(m,n);
        if i ~= j
            dummy = sparse(m,n);
            for k = 1:nInds
                for q = 1:nInds
                    d_ik = graphshortestpath(sparse(dists),i,inds(k));
                    d_iq = graphshortestpath(sparse(dists),i,inds(q));
                    if d_ik < d_iq
                        d_jk = graphshortestpath(sparse(dists),j,inds(k));
                        d_jq = graphshortestpath(sparse(dists),j,inds(q));
                        if d_jk > d_jq
                            dummy(inds(k),inds(q)) = 1;
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

save(fullfile(g_dir, [genus '_flows.mat']), 'Flows');

end