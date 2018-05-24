load('E://Dropbox/clean_tali/Names.mat');
load('E://Dropbox/clean_tali/meshList5000.mat');
load('E://Dropbox/clean_tali/matchesPairs5000_thresheld.mat');

%% Make directories if needed
base_path = 'E://Dropbox/TeethData/Tali5000/';

if ~exist(base_path,'dir')
    mkdir(base_path)
end
options.pointCloud = 0;
frechMean = 5;
for i = 1:length(Names)
        if i~=5
            dirString = [base_path Names{i} '__To__' Names{5} '/'];
            if ~exist(dirString,'dir')
                mkdir(dirString);
            end
            meshList{i}.Write([dirString Names{i} '.off'],'off',options);
            meshList{5}.Write([dirString Names{5} '.off'],'off',options);
            fid = fopen([dirString Names{i} '.txt'],'w');
            frechid = fopen([dirString Names{5} '.txt'],'w');
            curMatches = matchesPairs{i};
            for j = 1:size(curMatches,1)
                fprintf(fid,'%d\n',curMatches(j,1));
                fprintf(frechid,'%d\n',curMatches(j,2));
            end
            fclose(fid); fclose(frechid);
        end
end