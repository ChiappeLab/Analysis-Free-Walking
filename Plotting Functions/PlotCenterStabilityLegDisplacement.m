%% Plot center of stability displacement
clear
clc
% load leg parameters during forward runs
path = '\';
params = GetParams();
[LegMovForwSeg, pTypes] = GetForwSegLegData(path, params);

thr = 0.02;
DeltaStFL = cell(size(LegMovForwSeg, 1),size(LegMovForwSeg, 2));
DeltaStSCL = cell(size(LegMovForwSeg, 1),size(LegMovForwSeg, 2));
DeltaStFR = cell(size(LegMovForwSeg, 1),size(LegMovForwSeg, 2));
DeltaStSCR = cell(size(LegMovForwSeg, 1),size(LegMovForwSeg, 2));
DeltaSwFL = cell(size(LegMovForwSeg, 1),size(LegMovForwSeg, 2));
DeltaSwSCL = cell(size(LegMovForwSeg, 1),size(LegMovForwSeg, 2));
DeltaSwFR = cell(size(LegMovForwSeg, 1),size(LegMovForwSeg, 2));
DeltaSwSCR = cell(size(LegMovForwSeg, 1),size(LegMovForwSeg, 2));
DeltaFL = cell(size(LegMovForwSeg, 1),size(LegMovForwSeg, 2));
DeltaSCL = cell(size(LegMovForwSeg, 1),size(LegMovForwSeg, 2));
DeltaFR = cell(size(LegMovForwSeg, 1),size(LegMovForwSeg, 2));
DeltaSCR = cell(size(LegMovForwSeg, 1),size(LegMovForwSeg, 2));
for j = 1 : 1 : size(LegMovForwSeg, 1)
    for n = 1 : size(LegMovForwSeg, 2)
        % clean the leg position traces
        [lD] = GetCleanLegData(LegMovForwSeg{j,n}, thr);
        for i = 1 : length(lD.VR)
            % get the parameters of the triangle in stance at each step
            [TrSt, TrSw] = GetStepTriangle(lD.FLLY{i}, lD.FRLY{i}, lD.MLLY{i}, lD.MRLY{i}, lD.HLLY{i}, ...
                lD.HRLY{i}, lD.FLLX{i}, lD.FRLX{i}, lD.MLLX{i}, lD.MRLX{i}, lD.HLLX{i}, lD.HRLX{i}, lD.ThX{i}, lD.ThY{i});
            for t = 1 : size(TrSt.Tr1X,2)
                if ~isempty(TrSt.Tr1X) && ~isempty(TrSw.Tr1X) && TrSt.Tr1X(1,t)~=0 && TrSw.Tr1X(1,t)~=0 
                    DeltaStFL{j,n} = vertcat(DeltaStFL{j,n}, TrSt.Tr1X(1,t));
                    DeltaStSCL{j,n} = vertcat(DeltaStSCL{j,n}, TrSt.cTr1X(t));
                    DeltaSwFL{j,n} = vertcat(DeltaSwFL{j,n}, TrSw.Tr1X(1,t));
                    DeltaSwSCL{j,n} = vertcat(DeltaSwSCL{j,n}, TrSw.cTr1X(t));
                    DeltaFL{j,n} = vertcat(DeltaFL{j,n}, TrSt.Tr1X(1,t)-TrSw.Tr1X(1,t));
                    DeltaSCL{j,n} = vertcat(DeltaSCL{j,n}, TrSt.cTr1X(t)-TrSw.cTr1X(t));
                end
            end
            for t = 1 : size(TrSw.Tr2X,2)
                if ~isempty(TrSt.Tr2X) && ~isempty(TrSw.Tr2X)&& TrSt.Tr2X(1,t)~=0 && TrSw.Tr2X(1,t)~=0 
                    DeltaStFR{j,n} = vertcat(DeltaStFR{j,n}, TrSt.Tr2X(1,t));
                    DeltaStSCR{j,n} = vertcat(DeltaStSCR{j,n}, TrSt.cTr2X(t));
                    DeltaSwFR{j,n} = vertcat(DeltaSwFR{j,n}, TrSw.Tr2X(1,t));
                    DeltaSwSCR{j,n} = vertcat(DeltaSwSCR{j,n}, TrSw.cTr2X(t));
                    DeltaFR{j,n} = vertcat(DeltaFR{j,n}, TrSt.Tr2X(1,t)-TrSw.Tr2X(1,t));
                    DeltaSCR{j,n} = vertcat(DeltaSCR{j,n}, TrSt.cTr2X(t)-TrSw.cTr2X(t));
                end
            end
        end
    end
end
% plot the changes in the center of stability as a function of the changes
% in lateral leg placement
figure,
hold on
step = 5;
auxCents = -50:step:50;
aux = 1;
cmap = hot(5);
for j = 1: 2 : length(pTypes)
    kk = [];
    nn = [];
    for n = 1 : size(DeltaFL,2)
        ssp = DeltaSCL{j,n};
        probX = zeros(length(auxCents)-1, 1);
        nnX = zeros(length(auxCents)-1, 1);
        for k = 1 : length(auxCents)-1
            inds = find(DeltaFL{j,n} > auxCents(k) & DeltaFL{j,n} <= auxCents(k+1));
            if ~isempty(inds)
                probX(k) = nanmean(ssp(inds));
                nnX(k) = length(inds);
            else
                probX(k) = 0;
                nnX(k) = 0;
            end
        end
        kk = horzcat(kk, probX);
        nn = horzcat(nn, nnX);
    end
    gm = [];
    sem = [];
    for k = 1 : length(auxCents)-1
        if sum(nn(k,:)) > 10
            gm(k) = kk(k,:)*nn(k,:)'/sum(nn(k,:));
            sem(k) = sqrt(((kk(k,:)-gm(k)).*(kk(k,:)-gm(k)))*nn(k,:)'/sum(nn(k,:)))/sqrt(length(find(nn(k,:)~=0)));
        else
            gm(k) = nan;
            sem(k) = nan;
        end
    end
    hold on
    plot(auxCents(1:(end-1)), (gm), 'color', cmap(aux,:), 'linewidth', 3)
    plot(auxCents(1:(end-1)), (gm+sem), 'color', cmap(aux,:), 'linewidth', 1)
    plot(auxCents(1:(end-1)), (gm-sem), 'color', cmap(aux,:), 'linewidth', 1)
    title(pTypes{j})
    xlabel('Center of stability displacement')
    ylabel('Left front leg lateral placement')
    axis([-35 35 -20 20])
    aux = aux + 1;
end