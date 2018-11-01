function flowGenusMap = process_genus_flows()
% process_genus_flows - Create per-genus flow map
% Written by Julie Winchester <julie.winchester@duke.edu> 9/7/2018

outputDir = fullfile(pwd, '../output/');
flowDir = fullfile(outputDir, '/etc/flows/');

genusMap = load(fullfile(outputDir, '/etc/genusMap.mat'));
genusMap = genusMap.genusMap;

flowGenusMap = containers.Map;
for g = genusMap.keys
	g = g{1};
	disp(g);
	Flows = load(fullfile(flowDir, g, [g '_flows.mat']));
	Flows = Flows.Flows;
	flowGenusMap(g) = Flows;
end

save(fullfile(flowDir, ['flowGenusMap.mat']), 'flowGenusMap');

end