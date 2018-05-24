matchesPairs = cell(24,1);
baseLmks = 130;
lmkIter = 10;
for i = 1:24
    if i ~=5
        numLmks = baseLmks;
        while true
        
            [testMatches,~] = TaliLandmarkMatching5000(1,.95,.001,i,5,numLmks,1,1,.05,.5);
            testMatches = unique(testMatches,'rows');
            if size(testMatches,1) >= 25
                matchesPairs{i} = testMatches;
                break;
            else
                numLmks = numLmks+lmkIter;
            end
        end
    end
end
save('matchesPairs5000.mat','matchesPairs');
%pare down to at most 30 via euclidean FPS; start with first landmark as
%seed as that is among most likely matches
load('matchesPairs5000.mat');
load('confMatchesPairs5000.mat');
maxNumMatches = 15;

frechMean = 5;
frechMesh = meshList{5};
for i = 1:24
    if i ~= 5
        if size(matchesPairs{i},1) <= maxNumMatches
            continue;
        end
        curMesh = meshList{i};
        oldMatches = [confMatchesPairs{i};matchesPairs{i}];
        possibleMatches = [matchesPairs{i};confMatchesPairs{i}];
        newMatches = confMatchesPairs{i};
        %newMatches = matchesPairs{i}(1,:);
        
        for j = size(newMatches,1)+1:maxNumMatches
            totalDists = zeros(size(possibleMatches,1),1);
            [D_cur,~,~] = meshList{i}.PerformFastMarching(newMatches(:,1));
            [D_frech,~,~] = meshList{frechMean}.PerformFastMarching(newMatches(:,2));
            for k = 1:size(possibleMatches,1)
                totalDists(k)= D_cur(possibleMatches(k,1))+D_frech(possibleMatches(k,2));
            end
            [~,nextInd] = max(totalDists);
            nextInd = nextInd(1);
            newMatches = [newMatches;possibleMatches(nextInd,:)];
            possibleMatches(nextInd,:) = [];
        end
%         curMeshDists = pdist2(curMesh.V(:,oldMatches(:,1))',curMesh.V(:,oldMatches(:,1))');
%         frechMeshDists = pdist2(frechMesh.V(:,oldMatches(:,2))',frechMesh.V(:,oldMatches(:,2))');
%         newMatches = 1:size(confMatchesPairs{i},1);
%         lmkInds = 1:size(matchesPairs{i},1);
%         for j = size(newMatches,2)+1:maxNumMatches
%             testInds = lmkInds(~ismember(lmkInds,newMatches));
%             testDists = sum(curMeshDists(newMatches,:).^2,1)+sum(frechMeshDists(newMatches,:).^2,1);
%             testDists(newMatches) = 0;
%             newMatches = [newMatches find(testDists == max(testDists))];
%         end
%         matchesPairs{i} = oldMatches(newMatches,:);
        matchesPairs{i} = newMatches;
    end
end
save('matchesPairs5000_thresheld.mat','matchesPairs');