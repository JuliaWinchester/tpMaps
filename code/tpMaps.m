% Experimental script to construct tree phylogeny (tp) Maps

path(pathdef);
addpath(path,genpath(pwd));

inputDir = fullfile(pwd, '../input/');
meshDir = fullfile(inputDir, '/mesh/');

outputDir = fullfile(pwd, '../output/');

% Get mesh names
[meshNames, meshPaths] = get_mesh_names(meshDir, '.ply');

% Load and flatten all input meshes, output mesh Mats go to ../out/etc/flatten/mesh/
%cluster_run('cluster_flatten', '', pwd, fullfile(pwd, '../output/etc/flat/'), ...
%	'flat', 1);

% Run cPDist for all meshes in sample, output Maps and Dist mat will be in ../output/etc/cpd/
% cluster_run('cluster_cpd', '', pwd, fullfile(pwd, '../output/etc/cpd/'), ...
% 	'cpd', 1, 'cluster_flatten');
% cluster_run('process_cpd_results', '', pwd, fullfile(pwd, '../output/etc/cpd/'), ...
% 	'pcr', 0, 'cpdjob*');

%genusMap = create_genusMap(fullfile(outputDir, '/etc/flat/mesh/'), fullfile(inputDir, 'prime_sample_master_list.csv'));
%save(fullfile(outputDir, '/etc/genusMap.mat'), 'genusMap');

% cluster_run('directed_flows_by_genus', '', pwd, fullfile(pwd, '../output/etc/flows/'), ...
% 	'flow', 1);

% cluster_run('process_genus_flows', '', pwd, fullfile(pwd, '../output/etc/flows/'), ...
% 	'pgf', 1, 'flow*');

% [flatNames, flatPaths] = get_mesh_names(fullfile(outputDir, '/etc/flat/mesh/'), '.mat');
% for i = 1:lengt4h(flatPaths)
% 	disp(flatPaths{i});
% 	load(flatPaths{i});
% 	[lm, ptuq] = GetGPLmk(G, 45);
% 	G.Aux.GPLmkInds = lm;
% 	G.Aux.ptuq = ptuq;
% 	save(flatPaths{i}, 'G');
% end

% MATCH GP LANDMARKS

% cluster_run('lm_match_by_genus', '', pwd, fullfile(pwd, '../output/etc/match/'), 'match', 1);

% cluster_run('process_lm_match', '', pwd, fullfile(pwd, '../output/etc/match'), 'plm', 0, 'match*');

%%% GENERATE NEW CPMAPS FROM MATCHED LANDMARKS %%%

% cluster_run('cluster_cpd_lmk', '', pwd, fullfile(pwd, '../output/etc/cpd_lmk/'), ...
% 	'cpdlmk', 1);

% cluster_run('process_cpd_genus_results', '', pwd, fullfile(pwd, '../output/etc/cpd_lmk/'), ...
% 	'pcgr', 0, 'cpdjob*');

cluster_run('combine_cpd', '', pwd, fullfile(pwd, '../output/etc/cpd_combined/'), ...
	'combine_cpd', 0, 'pcgr');

