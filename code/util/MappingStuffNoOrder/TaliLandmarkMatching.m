function [matchedLmks,R]=TaliLandmarkMatching(temp,wtB,wtDecr,initMesh,...
    finalMesh,landmarks,neighborhoodSize,minPerc,percDecr,lowBndPerc,...
    cPMapsMatrix, cPDistMatrix, Flows)

% Demo for computing the set of matched landmarks based off of forward
% propagation. Works by gradual matching, decreasing amount of sureness
% needed as time goes on in order to capture fuzzier correspondences. Extra
% means that curvature extrema are added to GP landmarks.
%
% Input:
% temp: bandwidth parameter for kernel.
% wtB: lower bound on minimum weight of path
% wtDecr: weight decrement in case wtB set too high
% initMesh/finalMesh: meshes to match landmarks for, arguments are
% symmetric
% landmarks: number of Gaussian process landmarks used in matching process.
% neighborhoodSize: size of neighborhood of GP landmark to count as match
% minPerc: initial minimum percent of probability mass required for match
% percDecr: decrement parameter for percent matching
% lowBndPerc: final percentage required.

close all
if nargin < 1
    cPMapsMatrix = [];
end
%% Initialize variables, temporarily here until proper form figured out

%% Load necessary variables

[Names, meshPaths] = get_mesh_names('../output/etc/flat/mesh/', '.mat');
% maps_path = '../output/etc/cpd/cpMapsMatrix.mat';
% dist_path = '../output/etc/cpd/cpDistMatrix.mat';
% fg = load('../output/etc/flowGenusMap.mat');
% Flows = fg.flowGenusMap('Alouatta');
samples_path = '../output/etc/flat/mesh/';

%% Don't unnecessarily run
if initMesh == finalMesh
    error('Same mesh, nothing to do')
end
 
%% Declare and assign global variables to pass to compile results from recursion
global cPMap;           cPMap = cPMapsMatrix;      %relabel map matrix to pass to global           %
global maxDepth;        maxDepth = 116;                     %Maximum number of vertices in path, sanity check 
global numPaths;        numPaths = 1;                       %Counts the number of paths traversed
global numLandmarks;    numLandmarks = landmarks;                                        %Number of meshes to load/consider
t =temp;                                                %temperature parameter for diffusion
cPDistances = cPDistMatrix;        %matrix of cP distances
cPDistances = (cPDistances+cPDistances')/2;
meshes = cell(length(Names),1);
%% Load meshes
for i = 1:length(Names)
    if i == initMesh
        load(meshPaths{i});
        meshes{i} = G;
        cPMap{i,i} = 1:G.nV;
    elseif i == finalMesh
        load(meshPaths{i});
        meshes{i} = G;
        cPMap{i,i} = 1:G.nV;
    end
end

%landmarksToTest = landmarks% 12 13 14 15 16];
%landmarksToTest_1 = [meshes{initMesh}.Aux.GPLmkInds(1:landmarks) meshes{initMesh}.Aux.GaussMinInds'...
%    meshes{initMesh}.Aux.ConfMaxInds' meshes{initMesh}.Aux.GaussMaxInds'];
%landmarksToTest_2 = [meshes{finalMesh}.Aux.GPLmkInds(1:landmarks) meshes{finalMesh}.Aux.GaussMinInds'...
%    meshes{finalMesh}.Aux.ConfMaxInds' meshes{finalMesh}.Aux.GaussMaxInds'];
landmarksToTest_1 = meshes{initMesh}.Aux.GPLmkInds(1:landmarks);
landmarksToTest_2 = meshes{finalMesh}.Aux.GPLmkInds(1:landmarks); 
global vertWeight_12;      
vertWeight_12 = zeros(length(landmarksToTest_1),size(meshes{finalMesh}.V,2));
global vertWeight_21;
vertWeight_21 = zeros(length(landmarksToTest_2),size(meshes{initMesh}.V,2));

%% Load weighted flow matrices
% load(flows_path);
curFlow_12 = Flows{initMesh,finalMesh};
curFlow_21 = Flows{finalMesh,initMesh};
weightedFlows_12 = sparse((cPDistances.^2)).*(curFlow_12);
weightedFlows_21 = sparse((cPDistances.^2)).*(curFlow_21);
for i = 1:size(weightedFlows_12,1)
    for j = 1:size(weightedFlows_12,2)
        if (weightedFlows_12(i,j) ~=0)
            weightedFlows_12(i,j) = exp(-weightedFlows_12(i,j)/t);
           
        end
        if (weightedFlows_21(i,j) ~=0)
            weightedFlows_21(i,j) = exp(-weightedFlows_21(i,j)/t);
        end
    end
end
%% Run diffusion to gather points and distributions
while true
    DepthFirstSearchPlotting_12(weightedFlows_12,initMesh,finalMesh,landmarksToTest_1,cPMap,1,wtB,1,initMesh);
    DepthFirstSearchPlotting_21(weightedFlows_21,finalMesh,initMesh,landmarksToTest_2,cPMap,1,wtB,1,finalMesh);
    if norm(vertWeight_12)>0 && norm(vertWeight_21) > 0
        break;
    else %reset and redo computation with smaller weight
        vertWeight_12 = zeros(length(landmarksToTest_1),size(meshes{finalMesh}.V,2));
        vertWeight_21 = zeros(length(landmarksToTest_2),size(meshes{initMesh}.V,2));
        wtB = wtB - wtDecr;
    end
end

%% Make plots
% maps_12 = zeros(size(vertWeight_12,2),1);
% maps_21 = zeros(size(vertWeight_21,2),1);
% for k = 1:numLandmarks
%     curColors_12 = vertWeight_12(k,:);
%     curColors_21 = vertWeight_21(k,:);
%     %nonZer = find(curColors);
%     intensity_12 = max(curColors_12);
%     intensity_21 = max(curColors_21);
%     maps_12 = maps_12 + (curColors_12'/intensity_12);
%     maps_21 = maps_21 + (curColors_21'/intensity_21);
%     %scatter3(meshes{finalMesh}.V(1,nonZer), ...
%     %    meshes{finalMesh}.V(2,nonZer), ...
%     %    meshes{finalMesh}.V(3,nonZer),60,[ones(length(nonZer),1) (ones(length(nonZer),1)-(curColors(nonZer)'/intensity)) (ones(length(nonZer),1)-(curColors(nonZer)'/intensity))],'filled');
% end
% %maps = (maps>0);
% %maps = tanh(maps);
options.mode = 'native';
options.niter_averaging = 2;
% maps_12 = meshes{finalMesh}.PerformMeshSmoothing(maps_12,options);
% maps_21 = meshes{initMesh}.PerformMeshSmoothing(maps_21,options);
% finalLmks_12 = zeros(meshes{initMesh}.nV,1);
% finalLmks_12(landmarksToTest_1) = 1;
% finalLmks_12 = meshes{initMesh}.PerformMeshSmoothing(finalLmks_12,options);
% finalLmks_21 = zeros(meshes{finalMesh}.nV,1);
% finalLmks_21(landmarksToTest_2) = 1;
% finalLmks_21 = meshes{finalMesh}.PerformMeshSmoothing(finalLmks_21,options);
% h(1) = subplot(2,3,1);
% meshes{initMesh}.ViewFunctionOnMesh(finalLmks_12,options);
% h(2) = subplot(2,3,2);
% meshes{finalMesh}.ViewFunctionOnMesh(maps_12,options);
% h(3)=subplot(2,3,3);
% meshes{finalMesh}.ViewFunctionOnMesh(finalLmks_21,options);
% h(4) = subplot(2,3,4);
% meshes{finalMesh}.ViewFunctionOnMesh(finalLmks_21,options);
% h(5) = subplot(2,3,5);
% meshes{initMesh}.ViewFunctionOnMesh(maps_21,options);
% h(6)=subplot(2,3,6);
% meshes{initMesh}.ViewFunctionOnMesh(finalLmks_12,options);


% Link = linkprop(h, {'CameraUpVector', 'CameraPosition', 'CameraTarget', 'CameraViewAngle'});
% setappdata(gcf, 'StoreTheLink', Link);


%% Find neighborhoods of points
    curMatchedLmks = [];
    while true
        if minPerc < lowBndPerc
            break;
        end
        neighborhoodList_1 = cell(length(landmarksToTest_1),1);
        neighborhoodList_2 = cell(length(landmarksToTest_2),1);
        adjMat_1 = meshes{initMesh}.A; adjMat_2 = meshes{finalMesh}.A;
        neighMat_1 = zeros(meshes{initMesh}.nV,meshes{initMesh}.nV); neighMat_2 = zeros(meshes{finalMesh}.nV,meshes{finalMesh}.nV);
        for q = 0:neighborhoodSize
            neighMat_1 = neighMat_1 + adjMat_1^q;
            neighMat_2 = neighMat_2 + adjMat_2^q;
        end

        for q = 1:length(landmarksToTest_1)
            neighborhoodList_1{q} = find(neighMat_1(landmarksToTest_1(q),:));
        end
        for q = 1:length(landmarksToTest_2)
            neighborhoodList_2{q} = find(neighMat_2(landmarksToTest_2(q),:));
        end
        
        possibleMatches_1 = cell(length(landmarksToTest_1),1);              %possible correspondences for points on first mesh
        possibleMatches_2 = cell(length(landmarksToTest_2),1);              %possible correspondences for points on second mesh
        possibleMatchWeights_1 = cell(length(landmarksToTest_1),1);
        possibleMatchWeights_2 = cell(length(landmarksToTest_2),1);

        for q = 1:length(landmarksToTest_1)
            if ~isempty(curMatchedLmks)
                    if ismember(q,curMatchedLmks(:,1))
                        continue;
                    end
            end
            inds_12 = find(vertWeight_12(q,:));
            for s = 1:length(landmarksToTest_2)
                if ~isempty(curMatchedLmks)
                    if ismember(s,curMatchedLmks(:,2))
                        continue;
                    end
                end
                matchedInds_12 = inds_12(ismember(inds_12,neighborhoodList_2{s}));
                testWeight_12 = sum(vertWeight_12(q,matchedInds_12))/sum(vertWeight_12(q,:));
                if isempty(curMatchedLmks)
                    if (testWeight_12 > minPerc) 
                        possibleMatches_1{q} = [possibleMatches_1{q} s];
                        possibleMatchWeights_1{q} = [possibleMatchWeights_1{q} testWeight_12];
                    end
                else
                    if (testWeight_12 > minPerc) && ~ismember(q,curMatchedLmks(:,1)) && ~ismember(s,curMatchedLmks(:,2))
                        possibleMatches_1{q} = [possibleMatches_1{q} s];
                        possibleMatchWeights_1{q} = [possibleMatchWeights_1{q} testWeight_12];
                    end
                end
            end
        end
        
        for q = 1:length(landmarksToTest_2)
            if ~isempty(curMatchedLmks)
                    if ismember(q,curMatchedLmks(:,2))
                        continue;
                    end
            end
            inds_21 = find(vertWeight_21(q,:));
            for s = 1:length(landmarksToTest_1)
                if ~isempty(curMatchedLmks)
                    if ismember(s,curMatchedLmks(:,1))
                        continue;
                    end
                end
          
                matchedInds_21 = inds_21(ismember(inds_21,neighborhoodList_1{s}));
                testWeight_21 = sum(vertWeight_21(q,matchedInds_21))/sum(vertWeight_21(q,:));
                if isempty(curMatchedLmks)
                    if (testWeight_21) > minPerc 
                        possibleMatches_2{q} = [possibleMatches_2{q} s];
                        possibleMatchWeights_2{q} = [possibleMatchWeights_2{q} testWeight_21];
                    end
                else
                    if (testWeight_21) > minPerc && ~ismember(q,curMatchedLmks(:,2)) && ~ismember(s,curMatchedLmks(:,1))
                        possibleMatches_2{q} = [possibleMatches_2{q} s];
                        possibleMatchWeights_2{q} = [possibleMatchWeights_2{q} testWeight_21];
                    end
                end
            end
        end
% 
% 
% 
% 
%         figure
%         hold on
%         matchedLmks_12_init = zeros(meshes{initMesh}.nV,1);
%         matchedLmks_12_final = zeros(meshes{finalMesh}.nV,1);
%         matchedLmks_21_init = zeros(meshes{finalMesh}.nV,1);
%         matchedLmks_21_final = zeros(meshes{initMesh}.nV,1);
%         for t = 1:landmarks
%             if ~isempty(possibleMatches_1{t})
%                 matchedLmks_12_init(landmarksToTest_1(t)) = 1;
%                 matchedLmks_12_final(landmarksToTest_2(possibleMatches_1{t})) = 1;
%             end
%             if ~isempty(possibleMatches_2{t})
%                 matchedLmks_21_init(landmarksToTest_2(t)) = 1;
%                 matchedLmks_21_final(landmarksToTest_1(possibleMatches_2{t})) = 1;
%             end
%         end

%         matchedLmks_12_init=meshes{initMesh}.PerformMeshSmoothing(matchedLmks_12_init,options);
%         matchedLmks_12_final=meshes{finalMesh}.PerformMeshSmoothing(matchedLmks_12_final,options);
%         matchedLmks_21_init=meshes{finalMesh}.PerformMeshSmoothing(matchedLmks_21_init,options);
%         matchedLmks_21_final=meshes{initMesh}.PerformMeshSmoothing(matchedLmks_21_final,options);
%     
%     h2(1) = subplot(2,2,1);
%     meshes{initMesh}.ViewFunctionOnMesh(matchedLmks_12_init,options);
%     h2(2) = subplot(2,2,2);
%     meshes{finalMesh}.ViewFunctionOnMesh(matchedLmks_12_final,options);
%     h2(3)=subplot(2,2,3);
%     meshes{finalMesh}.ViewFunctionOnMesh(matchedLmks_21_init,options);
%     h2(4) = subplot(2,2,4);
%     meshes{initMesh}.ViewFunctionOnMesh(matchedLmks_21_final,options);
% 
%     Link = linkprop(h2, {'CameraUpVector', 'CameraPosition', 'CameraTarget', 'CameraViewAngle'});
%     setappdata(gcf, 'StoreTheLink', Link);

    %% Distill correspondences: only consider landmarks if they mutually pair
    %% Create voting list
    possiblePairs = [];
    possibleWeights = [];

    %first side: adds all mutual and possible matches for first landmark
    for q = 1:length(landmarksToTest_1)
        for s = 1:length(possibleMatches_1{q})
            if ismember(q,possibleMatches_2{possibleMatches_1{q}(s)})
                possiblePairs = [possiblePairs; [q possibleMatches_1{q}(s)]];
                matchingInd = find(q==possibleMatches_2{possibleMatches_1{q}(s)});
                newWeight =.5*possibleMatchWeights_1{q}(s)+...
                    .5*possibleMatchWeights_2{possibleMatches_1{q}(s)}(matchingInd);
                possibleWeights = [possibleWeights newWeight];
            end
        end
    end

    %second: adds remaining possible matches for second landmark, mutual
    %matches already added

%     for q = 1:length(landmarksToTest_2)
%         for s = 1:length(possibleMatches_2{q})
%             if ~isempty(possiblePairs)
%                 if ~ismember([possibleMatches_2{q}(s) q],possiblePairs,'rows')
%                     possiblePairs = [possiblePairs; [possibleMatches_2{q}(s) q]];
%                     %no need to get the other side, would have been taken care of
%                     %in previous run
%                     possibleWeights = [possibleWeights .5*possibleMatchWeights_2{q}(s)];
%                 end
%             end
%         end
%     end
    
    if ~isempty(possiblePairs)
        [~,orderedIdx] = sort(possibleWeights);
        orderedPairs = possiblePairs(orderedIdx,:);

        %now extract pairs based on stable mutual matching
        trueCorrespondences = [];
        for q = 1:size(orderedPairs,1)
            if q == 1
                trueCorrespondences = orderedPairs(1,:);
            else
                if (~ismember(orderedPairs(q,1),trueCorrespondences(:,1)) && ...
                        ~ismember(orderedPairs(q,2),trueCorrespondences(:,2)))
                    trueCorrespondences = [trueCorrespondences; orderedPairs(q,:)];
                end
            end
        end
        curMatchedLmks = [curMatchedLmks;trueCorrespondences];
    end
    minPerc = minPerc-percDecr;
    end
    determinedLmks_init = zeros(meshes{initMesh}.nV,1);
    determinedLmks_final = zeros(meshes{finalMesh}.nV,1);
    if isempty(curMatchedLmks)
        disp(['No matches detected at init mesh ' num2str(initMesh) ' and final mesh ' num2str(finalMesh)]);
        matchedLmks = [];
        R = eye(3);
        return;
    end
    determinedLmks_init(landmarksToTest_1(curMatchedLmks(:,1))) = 1;
    determinedLmks_final(landmarksToTest_2(curMatchedLmks(:,2))) = 1;

    determinedLmks_init=meshes{initMesh}.PerformMeshSmoothing(determinedLmks_init,options);
    determinedLmks_final=meshes{finalMesh}.PerformMeshSmoothing(determinedLmks_final,options);

%% Alignment step
if isempty(curMatchedLmks)
    matchedLmks = [];
    R = eye(3);
end
%Gather points
ptCloud_1 = meshes{initMesh}.V(:,landmarksToTest_1(curMatchedLmks(:,1)));
ptCloud_2 = meshes{finalMesh}.V(:,landmarksToTest_2(curMatchedLmks(:,2)));

%centralize and normalize
ptCloud_1 = ptCloud_1 - repmat(mean(ptCloud_1')',1,size(ptCloud_1,2));
ptCloud_2 = ptCloud_2 - repmat(mean(ptCloud_2')',1,size(ptCloud_2,2));
ptCloud_1 = ptCloud_1/norm(ptCloud_1,'fro');
ptCloud_2 = ptCloud_2/norm(ptCloud_2,'fro');

[U,~,V] = svd(ptCloud_1*(ptCloud_2'));
R = V*U';
for q = 1:meshes{initMesh}.nV
    meshes{initMesh}.V(:,q) = V*U'*meshes{initMesh}.V(:,q);
end
%% Plot the aligned meshes and landmarks, compare with MST alignments
% figure
% hold on
% h3(1) = subplot(2,3,1);
% meshes{initMesh}.ViewFunctionOnMesh(determinedLmks_init,options);
% h3(2) = subplot(2,3,2);
% meshes{finalMesh}.ViewFunctionOnMesh(determinedLmks_final,options);
% h3(3) = subplot(2,3,3);
% meshes{initMesh}.draw;
% meshes{finalMesh}.draw;

matchedLmks = [landmarksToTest_1(curMatchedLmks(:,1))' landmarksToTest_2(curMatchedLmks(:,2))'];
% fprintf('%d out of %d landmarks in correspondence \n',size(curMatchedLmks,1),landmarks);
empty_1 = 0;
empty_2 = 0;


%% Determine landmarks that can never correspond
minPerc = 0;
possibleMatches_1 = cell(landmarks,1);
possibleMatches_2 = cell(landmarks,2);
for q = 1:landmarks
    inds_12 = find(vertWeight_12(q,:));
    inds_21 = find(vertWeight_21(q,:));
    for s = 1:landmarks
        matchedInds_12 = inds_12(ismember(inds_12,neighborhoodList_2{s}));
        matchedInds_21 = inds_21(ismember(inds_21,neighborhoodList_1{s}));
        if (length(matchedInds_12) > 0)
            possibleMatches_1{q} = [possibleMatches_1{q} s];
        end
        if (length(matchedInds_21)>0)
            possibleMatches_2{q} = [possibleMatches_2{q} s];
        end
    end
end
emptyList_1 = [];
emptyList_2 = [];
for q = 1:landmarks
    if isempty(possibleMatches_1{q})
        for v = 1:landmarks
            if ismember(q,possibleMatches_2{v})
                break;
            elseif v == landmarks
                empty_1=empty_1+1;
                emptyList_1 = [emptyList_1 q];
            end
        end
    end
    if isempty(possibleMatches_2{q})
        for v = 1:landmarks
            if ismember(q,possibleMatches_1{v})
                break;
            elseif v == landmarks
                empty_2=empty_2+1;
                emptyList_2 = [emptyList_2 q];
            end
        end
    end
end

% emptyLmks_1 = zeros(meshes{initMesh}.nV,1); emptyLmks_2 = zeros(meshes{finalMesh}.nV,1);
% emptyLmks_1(landmarksToTest_1(emptyList_1)) = 1;
% emptyLmks_2(landmarksToTest_2(emptyList_2)) = 1;
% emptyLmks_1 = meshes{initMesh}.PerformMeshSmoothing(emptyLmks_1,options);
% emptyLmks_2 = meshes{finalMesh}.PerformMeshSmoothing(emptyLmks_2,options);
% h3(4) = subplot(2,3,4);
% meshes{initMesh}.ViewFunctionOnMesh(emptyLmks_1,options)
% h3(5) = subplot(2,3,5);
% meshes{finalMesh}.ViewFunctionOnMesh(emptyLmks_2,options);
% Link = linkprop(h3, {'CameraUpVector', 'CameraPosition', 'CameraTarget', 'CameraViewAngle'});
% setappdata(gcf, 'StoreTheLink', Link);
% fprintf('Cannot discern any potential correspondence for %d out of %d landmarks on first mesh \n',empty_1,landmarks);
% fprintf('Cannot discern any potential correspondence for %d out of %d landmarks on second mesh \n',empty_2,landmarks);

% figure
% hold on
% hP(1) = subplot(1,2,1);
% meshes{initMesh}.ViewFunctionOnMesh(finalLmks_12,options);
% hP(2) = subplot(1,2,2);
% meshes{finalMesh}.ViewFunctionOnMesh(finalLmks_21,options);
% Link = linkprop(hP, {'CameraUpVector', 'CameraPosition', 'CameraTarget', 'CameraViewAngle'});
% setappdata(gcf, 'StoreTheLink', Link);
end
function DepthFirstSearchPlotting_12(weightedFlows,init,final,lmks,mapMatrix,weight,wtBnd,curDepth,curPath)
%global uniV2 convexComb totalWeight continueCounter
global vertWeight_12
global numLandmarks
global maxDepth
global numPaths
    nextVerts = find(weightedFlows(init,:));
    for i = 1:length(nextVerts)
        nextLmks = mapMatrix{init,nextVerts(i)}(lmks);
        nextWeight = weight*weightedFlows(init,nextVerts(i));
        if (nextWeight < wtBnd) 
            continue;
        end
        nextPath = [curPath nextVerts(i)];
        if nextVerts(i) == final
            %scatter3(meshes{final}.V(1,nextLmks),meshes{final}.V(2,nextLmks),meshes{final}.V(3,nextLmks),40,repmat([1 1-(nextWeight-wtBnd)/(1-wtBnd) 1-(nextWeight-wtBnd)/(1-wtBnd)],length(nextLmks),1),'filled');
            for k = 1:numLandmarks
                vertWeight_12(k,nextLmks(k)) = vertWeight_12(k,nextLmks(k)) + nextWeight;
            end
            nextPath;
            nextWeight;
            numPaths = numPaths+1;
        elseif (curDepth <= maxDepth)
            DepthFirstSearchPlotting_12(weightedFlows,nextVerts(i),final,nextLmks,mapMatrix,nextWeight,wtBnd,curDepth+1,nextPath);
        end
    end
            
end

function DepthFirstSearchPlotting_21(weightedFlows,init,final,lmks,mapMatrix,weight,wtBnd,curDepth,curPath)
%global uniV2 convexComb totalWeight continueCounter
global vertWeight_21
global numLandmarks
global maxDepth
    nextVerts = find(weightedFlows(init,:));
    for i = 1:length(nextVerts)
        nextLmks = mapMatrix{init,nextVerts(i)}(lmks);
        nextWeight = weight*weightedFlows(init,nextVerts(i));
        if (nextWeight < wtBnd) 
            continue;
        end
        nextPath = [curPath nextVerts(i)];
        if nextVerts(i) == final
            %scatter3(meshes{final}.V(1,nextLmks),meshes{final}.V(2,nextLmks),meshes{final}.V(3,nextLmks),40,repmat([1 1-(nextWeight-wtBnd)/(1-wtBnd) 1-(nextWeight-wtBnd)/(1-wtBnd)],length(nextLmks),1),'filled');
            for k = 1:numLandmarks
                vertWeight_21(k,nextLmks(k)) = vertWeight_21(k,nextLmks(k)) + nextWeight;
            end
            nextPath;
        elseif (curDepth <= maxDepth)
            DepthFirstSearchPlotting_21(weightedFlows,nextVerts(i),final,nextLmks,mapMatrix,nextWeight,wtBnd,curDepth+1,nextPath);
        end
    end
            
end