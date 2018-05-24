function [flowGenusMap] = directed_flows_by_genus(genusMap, distMat)
% directed_flows_by_genus - Calculate directed flows per genus
% Written by Julie Winchester <julie.winchester@duke.edu> 2/27/2018

% Output
%	flowGenusMap - Map object with keys as genus names and values as cells
%		with directed flows from mesh i to j per genus

	flowGenusMap = containers.Map;
	for g = genusMap.keys
		key = g{1};
		disp(key);
		flowGenusMap(key) = ComputeDirectedFlowsSubset(distMat, genusMap(key));
	end
end
