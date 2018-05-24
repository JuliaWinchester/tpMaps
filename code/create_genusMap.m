function [genusMap] = create_genusMap(flatMeshDir, genusFilePath)
% CREATE_GENUSMAP - Get map of genus with flat mesh indices
% Written by Julie Winchester <julie.winchester@duke.edu> 2/27/2018

% Output
%	genusMap - Map object with keys as genus names and values as 1 x n matrices of flatMesh indices

	genusTable = readtable(genusFilePath);
	[meshNames, meshPaths] = get_mesh_names(flatMeshDir, '.mat');

	genusMap = containers.Map;
	for i = 1:length(genusTable.genus)
		disp(genusTable.genus{i});
		if ~isKey(genusMap, genusTable.genus{i})
			genusMap(genusTable.genus{i}) = [];
		end

		[~, name, ~] = fileparts(genusTable.current_filename{i});
		idx = find(startsWith(meshNames, name));
		genusMap(genusTable.genus{i}) = [genusMap(genusTable.genus{i}) idx];
	end

end