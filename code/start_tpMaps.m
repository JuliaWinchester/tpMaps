path(pathdef);
addpath(path,genpath(pwd));

cluster_run('tpMaps', '', pwd, fullfile(pwd, '../output/etc/'), 'tpMaps');