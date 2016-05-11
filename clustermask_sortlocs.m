function [num_ON,num_OFF]=clustermask_sortlocs(mask,locs,roi,gridsize)
%% -----------------------------------------------------------------------
% clustermask_sortlocs                                                                
% ------------------------------------------------------------------------
% author: Andreas Arnold 
% ------------------------------------------------------------------------
% syntax: [num_ON, num_OFF] = clustermask_sortlocs(mask,locs,roi,gridsize)                                                
% ------------------------------------------------------------------------
%
% CLUSTERMASK_SORTLOCS uses a given binary mask to sort a given list of 
% localizations into an ON- and OFF-cluster fraction.
%
% INPUT:  1) mask       ... binary cluster mask
%         2) locs       ... xy-coordinates of localizations
%         3) roi        ... image size (from camera eg.: 128)
%         4) gridsize   ... size of mask (e.g. 6400)
%
% OUTPUT: 1)num_ON      ... number of localizations on clusters
%         2)num_ON      ... number of localizations off clusters
% 


%% ENGINE
% round positions in localisation list to pixel values
locs_px=ceil(locs*gridsize/roi);

% convert to linear indices
ind=sub2ind(size(mask),locs_px(:,2),locs_px(:,1));

% check if positions are ON or OFF cluster
on_locs = mask(ind);

% split source file in ON and OFF
locs_ON=locs(on_locs,:);
locs_OFF=locs(~on_locs,:);

% output of ON and OFF localisations
num_ON=size(locs_ON,1);
num_OFF=size(locs_OFF,1);