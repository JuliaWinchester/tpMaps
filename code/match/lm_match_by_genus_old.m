function [matchLMGenusMap] = lm_match_by_genus_old(nMesh, genusMap, cpMaps, cpDist, flowGenusMap)
% LM_MATCH_BY_GENUS - Match GP landmarks by genus
% Written by Julie Winchester <julie.winchester@duke.edu> 3/9/2018

% Output
%	MatchLMGenusMap - Map object with keys as genus names and values as structs
%		with values:
%		* idx: Indices of meshes matched in genus
%		* lm_match: Cell array where {i, i} is matrix of matches LMs
%		* R: Cell array where {i, i} is rotation matrix

	matchLMGenusMap = containers.Map;
	for g = genusMap.keys
		key = g{1};
		disp(key);
		Flows = flowGenusMap(key);
		tmp = struct;
		tmp.matchedLmks = cell(nMesh, nMesh);
		tmp.R = cell(nMesh, nMesh);
		tmp.idx = genusMap(key);

		for i = genusMap(key)
			for j = genusMap(key)
				if i ~= j
					[matchedLmks, R] = TaliLandmarkMatching(1, .995, .001, i, j, 45, 2, 1, .05, .5, cpMaps, cpDist, Flows);
					tmp.matchedLmks{i, j} = matchedLmks;
					tmp.R{i, j} = R;
				end
			end
		end

		matchLMGenusMap(key) = tmp;
	end
end
