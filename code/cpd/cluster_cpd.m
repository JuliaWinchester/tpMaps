function [resultPath, chunkSize] = cluster_cpd(cfgPath)
% CLUSTER_CPD - Submit on_grid/cPdist jobs to cluster

chunkSize = 200;
featureType = 'ConfMax';
numFeatureMatch = 3;

[flatNames, flatSamples] = get_mesh_names(fullfile(pwd, '../output/etc/flat/mesh/'), '.mat');
disp(flatSamples);

cpdPath = fullfile(pwd, '../output/etc/cpd/');
resultPath = fullfile(cpdPath, '/job_rslt_mats/')
disp(cpdPath);
errPath    = fullfile(cpdPath, '/cluster/error/');
outPath    = fullfile(cpdPath, '/cluster/out/');
scriptPath = fullfile(cpdPath, '/cluster/script/');

disp('++++++++++++++++++++++++++++++++++++++++++++++++++');
disp(['Submitting jobs for comparing flatten sample files...' ]);

cnt = 0;
jobID = 0;
for k1=1:length(flatSamples)
    for k2=1:length(flatSamples)
        if mod(cnt,chunkSize) == 0
            if jobID > 0 %%% not the first time
                %%% close the script file (except the last one, see below)
                fprintf(fid, '%s ', 'exit; "\n');
                fclose(fid);
                
                %%% qsub
                jobName = ['cpdjob_' num2str(jobID)];
                err = fullfile(errPath, ['e_job_' num2str(jobID)]); 
                out = fullfile(outPath, ['o_job_' num2str(jobID)]);
                tosub = ['!qsub -N ' jobName ' -o ' out ' -e ' err ' ' ...
                         scriptName];
                eval(tosub);
            end
            
            jobID = jobID + 1;
            scriptName = fullfile(scriptPath, ['script_' num2str(jobID)]);
            
            %%% open the next (first?) script file
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
        
        scriptText = [' cPdist_ongrid ' ...
            filename1 ' ' ...
            filename2  ' ' ...
            fullfile(resultPath, ['rslt_mat_' num2str(jobID)]) ' ' ...
            num2str(k1) ' ' ...
            num2str(k2) ' ' ...
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
jobname = ['cpdjob_' num2str(jobID)];
err = fullfile(errPath, ['e_job_' num2str(jobID)]); 
out = fullfile(outPath, ['o_job_' num2str(jobID)]);
tosub = ['!qsub -N ' jobname ' -o ' out ' -e ' err ' ' scriptName ];
eval(tosub);

end

