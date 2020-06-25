function [ G, R, id ] = loadGR( ROIdir, idx )
%LOADGR helper function to load the green and red ROI tifs.
    
    % get file name from ROI idx, this helps to ensure that we load images
    % that comply with the naming convention.
    idx_str = num2str(idx);
    id = ['ROI_' idx_str];
    tifName = ['ROI_' idx_str '_green.tif'];
    tif2load = [ROIdir filesep tifName];

    % get info from the tif to load
    fileInfo    = Load.Movie.tif.getinfo(tif2load);
    % check that files contains only one large image
    assert(fileInfo.Frame_n == 1, 'tile should be a large single image');
    
    % load the tif for green channel
    warning('off','all');
    G = Load.Movie.tif.getframes(tif2load, 1);
    warning('on','all');
    
    % now we load the tif for the red channel with same logic as before
    tifName = ['ROI_' idx_str '_red.tif'];
    tif2load = [ROIdir filesep tifName];
    fileInfo    = Load.Movie.tif.getinfo(tif2load);
    % check that files contains only one large image
    assert(fileInfo.Frame_n == 1, 'tile should be a large single image');
    % load the tif
    warning('off','all');
    R = Load.Movie.tif.getframes(tif2load, 1);
    warning('on','all');

end

