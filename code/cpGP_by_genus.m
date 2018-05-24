function [cpGPGenusMap] = cpGP_by_genus(genusMap)
% CPGP_BY_GENUS - Continuous Procrustes with GP landmark maps and dists by genus
% Written by Julie Winchester <julie.winchester@duke.edu> 3/9/2018

	cpGPGenusMap = containers.Map;
	for g = genusMap.keys
		key = g{1};
		disp(key);
		
		idx = genusMap(g);
		
	end
end 