% Experimental script to construct tree phylogeny (tp) Maps

path(pathdef);
addpath(path,genpath(pwd));

inputDir = fullfile(pwd, '../input/');
meshDir = fullfile(inputDir, '/mesh/');

outputDir = fullfile(pwd, '../output/');

% Get mesh names
[meshNames, meshPaths] = get_mesh_names(meshDir, '.ply');

% Load and flatten all input meshes, output mesh Mats go to ../out/etc/flatten/mesh/
cluster_run('c_flat', '', pwd, fullfile(pwd, '../output/etc/flat/'), ...
	'flatten', 1);

% Run cPDist for all meshes in sample, output Maps and Dist mat will be in ../output/etc/cpd/
cluster_run('c_cpd', '', pwd, fullfile(pwd, '../output/etc/cpd/'), ...
	'cpd', 1, 'cluster_flatten');