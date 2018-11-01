function cluster_cpd_lmk()
% CLUSTER_CPD_LMK - Generate second cpMaps set from matched GP landmarks

outputDir = fullfile(pwd, '../output/');
cpdLmkDir = fullfile(outputDir, '/etc/cpd_lmk/');

matchLMGenusMap = load(fullfile(outputDir, '/etc/match/matchLMGenusMap.mat'));
matchLMGenusMap = matchLMGenusMap.matchLMGenusMap;

for g = matchLMGenusMap.keys
	g = g{1};
	g_dir = fullfile(cpdLmkDir, g);
	touch(g_dir);
	cluster_run('cpd_lmk_genus', ['''' g ''''], pwd, g_dir, ...
		['cpdlmk_' g], 0);
end