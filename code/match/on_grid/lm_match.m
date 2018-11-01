function lm_match(genus)
% LM_MATCH - Match GP landmarks for a single genus
% Written by Julie Winchester <julie.winchester@duke.edu> 9/26/2018

outputDir = fullfile(pwd, '../output/');
matchDir = fullfile(outputDir, '/etc/match/');

genusMap = load(fullfile(outputDir, '/etc/genusMap.mat'));
genusMap = genusMap.genusMap;
inds = genusMap(genus);

g_dir = fullfile(matchDir, genus);
touch(g_dir);

cpDist = load(fullfile(outputDir, '/etc/cpd/cpDistMatrix.mat'));
cpDist = cpDist.cpDist;

n = size(cpDist, 1);

cpMaps = load(fullfile(outputDir, '/etc/cpd/cpMapsMatrix.mat'));
cpMaps = cpMaps.cpMaps;

flowGenusMap = load(fullfile(outputDir, '/etc/flows/flowGenusMap.mat'));
flowGenusMap = flowGenusMap.flowGenusMap;
flows = flowGenusMap(genus);

tmp = struct;
tmp.matchedLmks = cell(n, n);
tmp.R = cell(n, n);
tmp.idx = inds;

for i = inds
	for j = inds
		if i~= j
			[matchedLmks, R] = TaliLandmarkMatching(1, .995, .001, i, j, 45, 2, 1, .05, .5, cpMaps, cpDist, flows);
			tmp.matchedLmks{i, j} = matchedLmks;
			tmp.R{i, j} = R;
		end
	end
end

save(fullfile(g_dir, [genus '_lm_match.mat']), 'tmp');

end