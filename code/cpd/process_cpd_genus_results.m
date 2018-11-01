function resultPath = process_cpd_genus_results()
% PROCESS_CPD_RESULTS - Map, distance, and texture coords from cpd job matrices per genus

outputDir = fullfile(pwd, '../output/');
resultPath = fullfile(outputDir, '/etc/cpd_lmk/');


[flatNames, flatSamples] = get_mesh_names(fullfile(outputDir, '/etc/flat/mesh/'), '.mat');
meshNum = length(flatNames);

matchLMGenusMap = load(fullfile(outputDir, '/etc/match/matchLMGenusMap.mat'));
matchLMGenusMap = matchLMGenusMap.matchLMGenusMap;
genusKeys = matchLMGenusMap.keys;

chunkSize = 20;
fileSuffix = '';

cpDist = zeros(meshNum);
cpMaps = cell(meshNum);
cpMapsInv = cell(meshNum);
tc1Temp = cell(meshNum);
tc2Temp = cell(meshNum);

for i = 1:length(genusKeys)
    g = genusKeys{i};
    disp(g);
    idx = matchLMGenusMap(g).idx;

    if length(idx) == 1
        continue
    end

    jobMatPath = fullfile(resultPath, g, '/job_rslt_mats/');
    tc1Path = fullfile(resultPath, '/texture_coords_1/');
    tc2Path = fullfile(resultPath, '/texture_coords_2/');

    %%% read rslt matrices and separate distance and landmarkMSE's
    cnt = 0;
    job_id = 0;
    for k1=1:meshNum
        if ~ismember(k1, idx)
            continue
        end
        for k2=1:meshNum
            if ~ismember(k2, idx) || k1 == k2
                continue
            end
            if mod(cnt,chunkSize)==0
                job_id = job_id+1;
                load(fullfile(jobMatPath, ['rslt_mat_' num2str(job_id)]));
            end
            if exist('cPrslt') && ~isempty(cPrslt{k1,k2})
                disp(['Processing cPrslt results for pair ' num2str(k1) ' and ' num2str(k2)]);
                cpStruct = cPrslt{k1, k2};
                cpDist(k1,k2) = cpStruct.cPdist;
                cpMaps{k1,k2} = cpStruct.cPmap;
                cpMapsInv{k1,k2} = cpStruct.invcPmap;
                tc1Temp{k1,k2} = cpStruct.TextureCoords1;
                tc2Temp{k1,k2} = cpStruct.TextureCoords2;
            elseif exist('Imprrslt')
                disp(['Processing Imprrslt results for pair ' num2str(k1) ' and ' num2str(k2)]);
                ImprStruct = Imprrslt{k1,k2};
                cpDist(k1,k2) = ImprStruct.ImprDist;
                cpMaps{k1,k2} = ImprStruct.ImprMap;
                cpMapsInv{k1,k2} = ImprStruct.invImprMap;
                tc1Temp{k1,k2} = ImprStruct.TextureCoords1;
                tc2Temp{k1,k2} = ImprStruct.TextureCoords2;
            else
                disp(['Comparison for pair ' num2str(k1) ' and ' num2str(k2) ' not present, skipping']);
            end
              
            cnt = cnt+1;
        end
    end

    %%% symmetrize
    for j=1:meshNum
        if ~ismember(j, idx)
            continue
        end
        for k=1:meshNum
            if ~ismember(k, idx) || j == k || isempty(cpDist(j, k))
                continue
            end

            tc1 = cell(meshNum,meshNum);
            tc2 = cell(meshNum,meshNum);

            if cpDist(j,k)<cpDist(k,j)
                cpMaps{k,j} = cpMapsInv{j,k};
                tc1{j,k} = tc1Temp{j,k};
                tc2{j,k} = tc2Temp{j,k};
            else
                cpMaps{j,k} = cpMapsInv{k,j};
                tc1{j,k} = tc2Temp{k,j};
                tc2{j,k} = tc1Temp{k,j};
            end
            
            touch(fullfile(tc1Path, num2str(j)));
            save(fullfile(tc1Path, num2str(j), ...
                ['TextureCoords1_mat_' num2str(j) '_' num2str(k) '.mat']), ... 
                'tc1');
            touch(fullfile(tc2Path, num2str(j)));
            save(fullfile(tc2Path, num2str(j), ...
                ['TextureCoords2_mat_' num2str(j) '_' num2str(k) '.mat']), ...
                'tc2');
            clear tc1 tc2;
        end
    end

end

cpDist = min(cpDist,cpDist');

%%% visualize distance and landmarkMSE matrices
% figure;
% imagesc(cpDist./max(cpDist(:))*64);
% axis equal;
% axis([1,meshNum,1,meshNum]);

%%% save results
save(fullfile(resultPath, ['cpDistMatrix' fileSuffix '.mat']), 'cpDist', '-v7.3');
save(fullfile(resultPath, ['cpMapsMatrix' fileSuffix '.mat']), 'cpMaps', '-v7.3');

end
