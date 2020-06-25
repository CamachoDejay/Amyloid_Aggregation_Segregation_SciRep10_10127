%	Author: Rafael Camacho
%   github: camachodejay
%   date:   2019 - 07 - 03
%   current address: Centre for cellular imaging - Göteborgs universitet

function main()
% Iterates over all aggregate ROIs stored and calculates S and P according
% to https://doi.org/10.2976/1.2834817
%
%   This program asks for a main directory, which must hold a number of
%   subfolders containing 'ROIs' in their name. If such folder exist then
%   it loada the ROIs tif and calculates the parameters S and P. S is
%   related to the scaterring energy ratio between red and green channels,
%   and P to the dipole like moment of the image between red and green
%   channel.

% get all folders in directory that contain the keyword ROIs
[folderList, dataDir] = getROIfolderList(cd);
if isempty(folderList)
    errordlg('No folders with key ROIs found in directory','Directory Error');
    return
end

% calculate S and P according to https://doi.org/10.2976/1.2834817
sTotal = [];
pTotal = [];
IMidTotal = {};
ROIidTotal = {};

h = waitbar(0,'Please wait...');
steps = length(folderList);

for i = 1:steps
    ROIdir = [dataDir filesep folderList(i).name];
    [Svec, Pvec, ROIid] = singleROIfolder(ROIdir);
    
    IMid = {};
    [IMid{1:length(Svec),1}] = deal(folderList(i).name);
    
    
    sTotal = [sTotal; Svec];
    pTotal = [pTotal; Pvec];
    IMidTotal = cat(1,IMidTotal, IMid);
    ROIidTotal = cat(1,ROIidTotal, ROIid);
    
    waitbar(i / steps)
end
close(h);

T = table(IMidTotal, ROIidTotal, sTotal, pTotal,...
                              'VariableNames', {'image', 'ROI', 'S', 'P'});
fileName = [dataDir filesep 'output.csv'];
writetable(T,fileName,'Delimiter',',','QuoteStrings',true);


    figure()
    plot(pTotal, sTotal, '.b')
    xlabel('P - dipole moment')
    ylabel('S - scattering ratio red/green')
    a = gca;
    a.FontSize = 14;
    grid 'on';
    
    figName = [dataDir filesep 'S-P'];
    saveas(gcf, [figName '.tif']);
    saveas(gcf,[figName '.fig']);

end

function [folderList, dataDir] = getROIfolderList(dir2use)
    dataDir = uigetdir(dir2use);
    content = dir(dataDir);
    idx   = contains({content.name},'ROIs');
    folderList = content(idx);    
end

function [Svec, Pvec, idTotal] = singleROIfolder(ROIdir)
    %Extract the part of the folder that is a tif file
    Folder_Content = dir(ROIdir);
    fileExt = '.tif';
    index2Images   = contains({Folder_Content.name},fileExt);
    file2Analyze = Folder_Content(index2Images);
    nFiles = length(file2Analyze)/2;

    Svec = zeros(nFiles,1);
    Pvec = zeros(nFiles,1);
    idTotal{nFiles,1} = '';
    
    for idx = 0:nFiles-1
        warning('off','all');
        [ G, R, id ] = Load.loadGR( ROIdir, idx );
        warning('on','all');
        [ P, ~, ~ ] = Descriptors.calcP( G, R );
        [ S, ~, ~ ] = Descriptors.calcS( G, R );

        Svec(idx+1) = S;
        Pvec(idx+1) = P;
        idTotal{idx+1}= id;
        
    end

end