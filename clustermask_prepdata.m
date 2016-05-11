function temp = clustermask_prepdata(pathname,filename,pixelsize)
%% -----------------------------------------------------------------------
% clustermask_prepdata
% ------------------------------------------------------------------------
% author: Andreas Arnold
% ------------------------------------------------------------------------
% syntax: temp = clustermask_prepdata(pathname, filename, pixelsize)
% ------------------------------------------------------------------------
%
% CLUSTERMASK_PREPDATA copies localization coordinates and brightness values
% from ThunderStorm *.csv – files into the working-array temp, which is then
% further processed by "clustermask_gaussblur.m".
% Here, alternative input file % formats can easily be implemented.
% 
% INPUT:  1) filename
%         2) pathname
%         3) pixelsize  ... camera pixel size of recorded image (nm/px)
%
% OUTPUT: 1) temp       ... array containing localization coordinates and
%                           brightness:
%                           col 1: x-coordinates
%                           col 2: y-coordinates
%                           col 3: brightness

 
 
%% LOAD AND PREPARE DATA:
if nargin==0
    [filename,pathname]=uigetfile('','Select file');
    pixelsize=str2double(cell2mat(inputdlg('Specify pixel size (nm)!')));
%     in nm
end
 
%IN CASE OF SINGLE CSV FILE
if strcmp(filename(end-3:end),'.csv')
    % load selected file
    tmp=csvread(fullfile(pathname,filename),1,0);
    %extract xy
    temp(:,1,1)=tmp(:,2)/pixelsize;
    temp(:,2,1)=tmp(:,3)/pixelsize;
    temp(:,3,1)=tmp(:,5);
end

