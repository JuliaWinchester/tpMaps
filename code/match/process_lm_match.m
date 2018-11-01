function lmMatchGenusMap = process_lm_match()
% process_lm_match - Create per-genus GP landmark map
% Written by Julie Winchester <julie.winchester@duke.edu> 10/5/2018

% Output
%	MatchLMGenusMap - Map object with keys as genus names and values as structs
%		with values:
%		* idx: Indices of meshes matched in genus
%		* lm_match: Cell array where {i, i} is matrix of matches LMs
%		* R: Cell array where {i, i} is rotation matrix

outputDir = fullfile(pwd, '../output/');
matchDir = fullfile(outputDir, '/etc/match/');

genusMap = load(fullfile(outputDir, '/etc/genusMap.mat'));
genusMap = genusMap.genusMap;

matchLMGenusMap = containers.Map;
for g = genusMap.keys
	g = g{1};
	disp(g);
	tmp = load(fullfile(matchDir, g, [g '_lm_match.mat']));
	tmp = tmp.tmp;
	matchLMGenusMap(g) = tmp;
end

save(fullfile(matchDir, ['matchLMGenusMap.mat']), 'matchLMGenusMap');

end