function [map,xyc] = clustermask_gaussblur(roi,pixelsize,gridsize,...
                            sig,sig_r,temp,cellroi_xy)
%% -----------------------------------------------------------------------
% clustermask_gaussblur
% ------------------------------------------------------------------------
% authors: Andreas Arnold, Konrad Leskovar
% ------------------------------------------------------------------------
% syntax: [map,xyc] = clustermask_gaussblur(roi, pixelsize, gridsize,...
%                           sig, sig_r, temp, cellroi_xy)
% ------------------------------------------------------------------------
%
% CLUSTERMASK_GAUSSBLUR represents each localization by a 2D Gaussian. In
% denser regions the Gaussians overlap more and thus result in higher pixel
% values. Subsequently, these density dependent maps are used to create
% binary masks by application of a threshold. Gaussians are trimmed at a set
% radius (sig_r; multiples of sigma) to reduce overestimation of
% cluster-areas.
%
% INPUT:  1) roi        ... number of pixel in quadratic ROI (e.g. roi=128 
%                           for a 128x128 ROI)
%         2) pixelsize  ... pixel size of virtual pixel in created mask
%                           (in nm/px)
%         3) gridsize   ... number of pixel used for binary mask (e.g.
%                           grid size 1024 for a 1024x1024 pixel mask)
%         4) sig        ... standard deviation of Gaussians used to
%                           represent localizations (in nm)
%         5) sig_r      ... radius at which Gaussians are set to zero (in
%                           fractions of sig);
%         6) temp       ... array containing localizations
%         7) cellroi_xy ... array containing coordinates of polygon ROI to
%                           process only localizations on the cell
%
% OUTPUT: 1) map        ... density map 
%         2) xyc        ... localizations used to create density map
 
 
%% PREPARATIONS:
% calculate sig in virtual pixelsize
sig=sig*gridsize/roi/pixelsize;

% prepare localizations
xyc = temp(:,1:2);
% discard all elements that are zero
xyc=xyc(any(xyc~=0,2),:);
% use only localizations that are inside polygon ROI
if ~isempty(cellroi_xy)
    xycIN = xyc;
    IN = inpolygon(xycIN(:,1),xycIN(:,2),cellroi_xy(:,1),cellroi_xy(:,2));
    xyc = xyc(IN,:);
end

% preallocation map
map=zeros(gridsize,gridsize);
% prepare XY - meshgrid
[X,Y] = meshgrid(-sig*sig_r:sig*sig_r);
    
%% GAUSSIAN BlUR:
% round positions to virtual pixel values
xyc_px=ceil(xyc*gridsize/roi);
% convert to linear indices
ind=sub2ind(size(map),xyc_px(:,2),xyc_px(:,1));
% take into account that multiple localisations might be situated on a
% single virtual pixel
ind2=think(ind);
% mark positions in map 
map(ind2(:,1))=ind2(:,2);

% generate gaussian profile for single localization
gauss=exp(-(X.^2/(2*sig^2)+Y.^2/(2*sig^2)));
% cut gaussian at sig_r multiples of sig
gauss(X.^2+Y.^2>=(sig_r*sig)^2)=0;

% make convolution for gaussian blur
map = conv2(map,gauss,'same');

%% POST-PROCESSING:
% get value distribution without very low values
T=reshape(map,gridsize^2,1);
T=T(T>0.01);
 
% "cut off" very high peaks (= very dense areas)
Tmean = mean(T);
Tstd = std(T);
map(map>Tmean+5*Tstd)=Tmean+5*Tstd;


