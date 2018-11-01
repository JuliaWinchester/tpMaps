function directed_flows_by_genus()
% directed_flows_by_genus - Calculate directed flows per genus
% Written by Julie Winchester <julie.winchester@duke.edu> 2/27/2018

% Output
%	flowGenusMap - Map object with keys as genus names and values as cells
%		with directed flows from mesh i to j per genus

outputDir = fullfile(pwd, '../output/');
flowDir = fullfile(outputDir, '/etc/flows/');

genusMap = load(fullfile(outputDir, '/etc/genusMap.mat'));
genusMap = genusMap.genusMap;

cpDist = load(fullfile(outputDir, '/etc/cpd/cpDistMatrix.mat'));
cpDist = cpDist.cpDist;

% flowGenusMap = containers.Map;
for g = genusMap.keys
	g = g{1};
	disp(g);
	g_dir = fullfile(flowDir, g);
	touch(g_dir);
	% Cluster run step for ComputeDirectedFlowsSubset
	cluster_run('ComputeDirectedFlowsSubset', ['''' g ''''], pwd, g_dir, ...
		['flow_' g], 0);
	%  flowGenusMap(key) = ComputeDirectedFlowsSubset(distMat, genusMap(key));
end

end
