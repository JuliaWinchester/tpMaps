function [resultPath, chunkSize] = cpd_lmk_genus(g)
% CPD_LMK_GENUS - Submit cPdist jobs to cluster using matched landmakrs

chunkSize = 20;
featureType = 'Landmarks';
numFeatureMatch = 4;

outputDir = fullfile(pwd, '../output/');

matchLMGenusMap = load(fullfile(outputDir, '/etc/matchLMGenusMap.mat'));
matchLMGenusMap = matchLMGenusMap.matchLMGenusMap;
idx = matchLMGenusMap(g).idx;

[flatNames, flatSamples] = get_mesh_names(fullfile(pwd, '../output/etc/flat/mesh/'), '.mat');

cpdPath = fullfile(outputDir, '/etc/cpd_lmk/', g);
touch(cpdPath);
resultPath = fullfile(cpdPath, '/job_rslt_mats/');
touch(resultPath);
touch(fullfile(cpdPath, '/cluster/'));
errPath    = fullfile(cpdPath, '/cluster/error/');
touch(errPath);
outPath    = fullfile(cpdPath, '/cluster/out/');
touch(outPath);
scriptPath = fullfile(cpdPath, '/cluster/script/');
touch(scriptPath);

disp('++++++++++++++++++++++++++++++++++++++++++++++++++');
disp(['Submitting jobs for per-genus cpDist...' ]);

cnt = 0;
jobID = 0;
for k1=1:length(flatSamples)
    if ~ismember(k1, idx)
        continue
    end
    for k2=1:length(flatSamples)
        if ~ismember(k2, idx) || k1 == k2
            continue
        end
        if mod(cnt,chunkSize) == 0
            if jobID > 0 %%% not the first time
                disp('closing script file');
                %%% close the script file (except the last one, see below)
                fprintf(fid, '%s ', 'exit; "\n');
                fclose(fid);
                
                %%% qsub
                jobName = ['cpdjob_' g '_' num2str(jobID)];
                err = fullfile(errPath, ['e_job_' num2str(jobID)]); 
                out = fullfile(outPath, ['o_job_' num2str(jobID)]);
                tosub = ['!qsub -N ' jobName ' -o ' out ' -e ' err ' ' ...
                         scriptName];
                eval(tosub);
            end
            
            jobID = jobID + 1;
            scriptName = fullfile(scriptPath, ['script_' num2str(jobID)]);
            
            %%% open the next (first?) script file
            disp('opening script file');
            fid = fopen(scriptName, 'w');
            fprintf(fid, '#!/bin/bash\n');
            fprintf(fid, '#$ -S /bin/bash\n');
            scriptText = ['matlab -nodesktop -nodisplay -nojvm -nosplash -r '...
                '" cd ' fullfile(pwd, '/cpd/on_grid/') '; ' ...
                'path(genpath(''../../util/''), path);'];
            fprintf(fid, '%s ',scriptText);
            
            %%% create new matrix
            if ~exist(fullfile(resultPath, ['rslt_mat_' num2str(jobID) '.mat']), 'file')
                cPrslt = cell(length(flatSamples));
                save(fullfile(resultPath, ['rslt_mat_' num2str(jobID)]), 'cPrslt');
            end
        end
        filename1 = flatSamples{k1};
        filename2 = flatSamples{k2};
        
        scriptText = [' cPdist_lmk_genus_ongrid ' ...
            filename1 ' ' ...
            filename2  ' ' ...
            fullfile(resultPath, ['rslt_mat_' num2str(jobID)]) ' ' ...
            num2str(k1) ' ' ...
            num2str(k2) ' ' ...
            g ' ' ...
            featureType ' ' ...
            num2str(numFeatureMatch) '; '];
        fprintf(fid, '%s ',scriptText);
        
        cnt = cnt+1;
    end
    
end

% if mod(cnt,chunkSize)~=0
%%% close the last script file
fprintf(fid, '%s ', 'exit; "\n');
fclose(fid);
%%% qsub last script file
jobname = ['cpdjob_' g '_' num2str(jobID)];
err = fullfile(errPath, ['e_job_' num2str(jobID)]); 
out = fullfile(outPath, ['o_job_' num2str(jobID)]);
tosub = ['!qsub -N ' jobname ' -o ' out ' -e ' err ' ' scriptName ];
eval(tosub);

end

