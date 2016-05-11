function mask = clustermask_binary(map,threshold,locs,filename,handles,info)
%% ------------------------------------------------------------------------
% clustermask_binary
% -------------------------------------------------------------------------
% author: Andreas Arnold, Konrad Leskovar
% -------------------------------------------------------------------------
% syntax: mask = clustermask_binary(map,TH,filename,handles)
% -------------------------------------------------------------------------
%
% CLUSTERMASK_BINARY creates binary masks by applying uniform thresholds to
% given density maps. Subsequently, statistics of localizations ON and OFF
% clustered area are collected.
%
% INPUT:  1) map        ... density dependent map of localisations (aquired
%                           e.g. from gaussian bluring)
%         2) threshold  ... threshold to create binary masks
%                           in figure
%         3) locs       ... localizations used to create mask
%         4) filename   ... name of original localisation file (without
%                           file-extension)
%         5) handles    ... containing parameters from GUI
%         6) info       ... containing mask parameters and polygon ROI
% 
% OUTPUT: 1) mask       ... binary mask
%                           --> pixelvalues of 1 correspond to ON-cluster
%                           --> pixelvalues of 0 correspond to OFF-cluster

%% ENGINE:
% apply threshold
mask = map>threshold;

% save mask as *.tif file
imwrite(mask,fullfile(handles.path,[filename, '_TH',...
    strrep(num2str(threshold),'.',','),'_mask.tif']),'Compression','none');
% save mask as *.mat file
save(fullfile(handles.path,[filename, '_TH',strrep(num2str(threshold),...
    '.',','), '_mask.mat']),'mask');

% create and save figure
if handles.create_fig
    
    % define grid for correct plotting
    X=handles.roi/(2*handles.gridsize):handles.roi/handles.gridsize:...
        handles.roi*(1-1/(2*handles.gridsize));
    
    % open empty figure
    fig=figure;
    % plot mask
    imagesc(X,X,mask)
    axis ij; axis equal; axis tight; colormap gray;
    hold on
    % plot localizations
    plot(locs(:,1),locs(:,2),'r.','Markersize',2);
    % plot polygon ROI
    if handles.include_roi && ~isempty(info.cellroi_xy) 
        plotc(info.cellroi_xy(:,1),info.cellroi_xy(:,2),'b',...
            'Linewidth',1);
    end
    % save as *.fig
    savefig(fig,fullfile(handles.path,[filename, '_TH',strrep(num2str...
        (threshold),'.',','),'_figure.fig']));
    % save as high resolution *.png
    if handles.save_png
        print(fig,fullfile(handles.path,[filename, '_TH',strrep(num2str...
        (threshold),'.',','),'_figure.png']),'-dpng',['-r',num2str(1200)],'-opengl');
    end
    
    % close figure
    close(fig);
    pause(0.001);
end

%% SUPPORT FUNCTIONS:
% plot used polygon ROI as closed polygon
function plotc(x,y,varargin)  
x = [x(:);x(1)];   
y = [y(:);y(1)];  
plot(x,y,varargin{:})
    
    
    