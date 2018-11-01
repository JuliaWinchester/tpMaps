function combine_cpd()
% COMBINE_CPD - Combine cpd and cpd_lmk results into one set of results

outputDir = fullfile(pwd, '../output/');
cpdPath = fullfile(outputDir, '/etc/cpd/'); 
cpdLmkPath = fullfile(outputDir, '/etc/cpd_lmk/');
combinePath = fullfile(outputDir, '/etc/cpd_combined/');

[flatNames, flatSamples] = get_mesh_names(fullfile(outputDir, '/etc/flat/mesh/'), '.mat');
meshNum = length(flatNames);

matchLMGenusMap = load(fullfile(outputDir, '/etc/match/matchLMGenusMap.mat'));
matchLMGenusMap = matchLMGenusMap.matchLMGenusMap;
genusKeys = matchLMGenusMap.keys;

chunkSize = 200;

cpd_cpDist = load(fullfile(cpdPath, 'cpDistMatrix.mat'));
cpd_cpMaps = load(fullfile(cpdPath, 'cpMapsMatrix.mat'));
cpd_tc1Path = fullfile(cpdPath, '/texture_coords_1/');
cpd_tc2Path = fullfile(cpdPath, '/texture_coords_2/');

cpdLmk_cpDist = load(fullfile(cpdLmkPath, 'cpDistMatrix.mat'));
cpdLmk_cpMaps = load(fullfile(cpdLmkPath, 'cpMapsMatrix.mat'));
cpdLmk_tc1Path = fullfile(cpdLmkPath, '/texture_coords_1/');
cpdLmk_tc2Path = fullfile(cpdLmkPath, '/texture_coords_2/');

combine_cpDist = zeros(meshNum);
combine_cpMaps = cell(meshNum);
combine_tc1Path = fullfile(combinePath, '/texture_coords_1/');
combine_tc2Path = fullfile(combinePath, '/texture_coords_2/');

for i = 1:length(genusKeys)
    g = genusKeys{i};
    disp(g);
    idx = matchLMGenusMap(g).idx;

    for k1=1:meshNum
        if ~ismember(k1, idx)
            continue
        end
        for k2=1:meshNum
            if ~ismember(k2, idx) || k1 == k2
                continue
            end
            if cpdLmk_cpDist.cpDist(k1, k2) == 0 || cpd_cpDist.cpDist(k1, k2) < cpdLmk_cpDist.cpDist(k1, k2)
            	% Use the original maps
                disp(['Pair ' num2str(k1) ' and ' num2str(k2) ': using original maps']);
            	combine_cpDist(k1, k2) = cpd_cpDist.cpDist(k1, k2);
                disp(['Original cpDist: ' num2str(cpd_cpDist.cpDist(k1, k2))]);
            	combine_cpMaps{k1, k2} = cpd_cpMaps.cpMaps{k1, k2};
                disp(['GPLMK cpDist: ' num2str(cpdLmk_cpDist.cpDist(k1, k2))]);
            	
            	% Texture coords
            	tcNum = bin_number(meshNum, k1, k2, chunkSize);
            	cpd_tc1 = load(fullfile(cpd_tc1Path, ['TextureCoords1_mat_' num2str(tcNum) '.mat']));
            	cpd_tc2 = load(fullfile(cpd_tc2Path, ['TextureCoords2_mat_' num2str(tcNum) '.mat']));
            	
            	combine_tc1 = cell(meshNum);
            	combine_tc1{k1, k2} = cpd_tc1.tc1{k1, k2};
            	touch(fullfile(combine_tc1Path, num2str(k1)));
            	save(fullfile(combine_tc1Path, num2str(k1), ['TextureCoords1_mat_' num2str(k1) '_' num2str(k2) '.mat']), 'combine_tc1');
            	clear combine_tc1;

            	combine_tc2 = cell(meshNum);
            	combine_tc2{k1, k2} = cpd_tc2.tc2{k1, k2};
            	touch(fullfile(combine_tc2Path, num2str(k1)));
            	save(fullfile(combine_tc2Path, num2str(k1), ['TextureCoords2_mat_' num2str(k1) '_' num2str(k2) '.mat']), 'combine_tc2');
            	clear combine_tc2;

            	clear cpd_tc1 cpd_tc2;
            	
            else
            	% Use the landmark match maps
                disp(['Pair ' num2str(k1) ' and ' num2str(k2) ': using GPLMK maps']);
            	combine_cpDist(k1, k2) = cpdLmk_cpDist.cpDist(k1, k2);
                disp(['Original cpDist: ' num2str(cpd_cpDist.cpDist(k1, k2))]);
            	combine_cpMaps{k1, k2} = cpdLmk_cpMaps.cpMaps{k1, k2};
                disp(['GPLMK cpDist: ' num2str(cpdLmk_cpDist.cpDist(k1, k2))]);

            	% Texture coords
            	cpdLmk_tc1 = load(fullfile(cpdLmk_tc1Path, num2str(k1), ['TextureCoords1_mat_' num2str(k1) '_' num2str(k2) '.mat']));
            	cpdLmk_tc2 = load(fullfile(cpdLmk_tc2Path, num2str(k1), ['TextureCoords2_mat_' num2str(k1) '_' num2str(k2) '.mat']));

            	combine_tc1 = cell(meshNum);
            	combine_tc1{k1, k2} = cpdLmk_tc1.tc1{k1, k2};
            	touch(fullfile(combine_tc1Path, num2str(k1)));
            	save(fullfile(combine_tc1Path, num2str(k1), ['TextureCoords1_mat_' num2str(k1) '_' num2str(k2) '.mat']), 'combine_tc1');
            	clear combine_tc1;

            	combine_tc2 = cell(meshNum);
            	combine_tc2{k1, k2} = cpdLmk_tc2.tc2{k1, k2};
            	touch(fullfile(combine_tc2Path, num2str(k1)));
            	save(fullfile(combine_tc2Path, num2str(k1), ['TextureCoords2_mat_' num2str(k1) '_' num2str(k2) '.mat']), 'combine_tc2');
            	clear combine_tc2;

            	clear cpdLmk_tc1 cpdLmk_tc2;
            end
        end
    end
end

cpDist = combine_cpDist;
cpMaps = combine_cpMaps;

save(fullfile(combinePath, 'cpDistMatrix.mat'), 'cpDist', '-v7.3');
save(fullfile(combinePath, 'cpMapsMatrix.mat'), 'cpMaps', '-v7.3');

end