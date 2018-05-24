function tc = collate_texture_coords(tc1_dir, tc2_dir)
% COLLATE_TEXTURE_COORDS - Create single texture coordinate struct

	tc = struct;
	tc.tc1 = combine_tc_mats(tc1_dir, 'tc1');
	tc.tc2 = combine_tc_mats(tc2_dir, 'tc2');

end

function tcCell = combine_tc_mats(tcDir, tcCellStr)

	[~, tcFiles] = get_mesh_names(tcDir, '.mat');
	f = load(tcFiles{1});
	tcCell = f.(tcCellStr);
	for i = 2:length(tcFiles)
        disp(i);
		f = load(tcFiles{i});
		x = find(~cellfun(@isempty,f.(tcCellStr)));
		tcCell(x) = f.(tcCellStr)(x);
	end
	
end