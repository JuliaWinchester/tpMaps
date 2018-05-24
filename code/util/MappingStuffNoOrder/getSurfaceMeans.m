load('eulemurInds.mat');
load('peroInds.mat');
load('adapisInds.mat');

load('newMeshes2.mat');
newMeshes = newMeshList;
frechetMean = 5;

eulemurVerts = zeros(size(newMeshes{frechetMean}.V,1),size(newMeshes{frechetMean}.V,2));
for i = 1:length(eulemurInds)
    eulemurVerts = eulemurVerts+newMeshes{eulemurInds(i)}.V/length(eulemurInds);
end
eulemurMean = Mesh('VF',eulemurVerts,newMeshes{1}.F);

peroVerts = zeros(size(newMeshes{frechetMean}.V,1),size(newMeshes{frechetMean}.V,2));
for i = 1:length(peroInds)
    peroVerts = peroVerts+newMeshes{peroInds(i)}.V/length(peroInds);
end
peroMean = Mesh('VF',peroVerts,newMeshes{1}.F);


adapisVerts = zeros(size(newMeshes{frechetMean}.V,1),size(newMeshes{frechetMean}.V,2));
for i = 1:length(adapisInds)
    adapisVerts = adapisVerts+newMeshes{adapisInds(i)}.V/length(adapisInds);
end
adapisMean = Mesh('VF',adapisVerts,newMeshes{1}.F);


totalVerts = zeros(size(newMeshes{frechetMean}.V,1),size(newMeshes{frechetMean}.V,2));
for i = 1:length(newMeshes)
    totalVerts = totalVerts+newMeshes{i}.V/length(newMeshes);
end
totalMean = Mesh('VF',totalVerts,newMeshes{1}.F);