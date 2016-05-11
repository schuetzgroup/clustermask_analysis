function varargout = clustermask_createset(varargin)
%%------------------------------------------------------------------------
% CLUSTERMASK_CREATESET
% ------------------------------------------------------------------------
% authors: Konrad Leskovar, Andreas Arnold
% ------------------------------------------------------------------------
% syntax: clustermask_createset(varargin)
% ------------------------------------------------------------------------
%
% CLUSTERMASK_CREATESET analyzes sets of super-resolution images generated
% by the ImageJ-Plugin ThunderSTORM in *.csv - format (xy-localization files).
% The user can define ROIs in each image before cluster masks are created
% according to the set threshold values in the GUI.
% The calculated cluster area, as well as the number of localizations inside
% and outside the clusters are stored in the output matrix “results.mat”. The
% cluster masks are saved as *.mat and *.tif files and figures including
% the localizations and the used polygon ROIs are saved as *.fig files and 
% high resolution *.png images.
% 
% Parameters that can be chosen by the user in the GUI:
% 
%         1) roi        ... refers to the dimensions of the recorded images
%                           in camera pixels (e.g. roi=128 for a 128x128px
%                           image)
%         2) pixelsize  ... camera pixel size of recorded image (nm/px)
%         3) gridsize   ... number of pixel used for binary mask (default:
%                           1024 for a 1024x1024 pixel mask);
%         4) sig        ... standard deviation of Gaussians used to
%                           represent localizations (in nm)
%         5) cut gauss  ... radius at which Gaussians are set to zero (in
%                           fractions of sig);
%         6) thresholds ... values are applied onto the summed-up Gaussians
%                           that represent individual localizations and cuts
%                           them at the specified heights;
% 
% Settings:
% 
%         1) Use same CellRoi for all ... only one ROI needs to be drawn by
%                                         the user, which is used for all
%                                         files in the folder
%         2) Create loc figure        ... if checked, a figure displaying
%                                         the mask and overlayed 
%                                         localizations is created and
%                                         saved as a *.fig file
%         3) Include CellRoi          ... if checked the ROI is plotted in
%                                         the localization figure
%         4) Save as *.png            ... if checked a high resolution
%                                         *.png image of the figure is
%                                         saved additionally
%                                         
% 
% OUTPUT: 1) coordinates of the ROI:       "'filename'_mask_info"
%         2) mask-file:                    "'filename'_TH**_mask" (**=threshold)
%         3) image (mask, locs, ROI):      "'filename'_TH**_figure" (**=threshold)
%                                          value)
%         4) result.mat:
%                        -cell_area:       cell area as double in nm²
%                        -clust_area:      cluster area as double in nm²
%                        -files:           filenames of processed files
%                        -num_locs_legend:  
%                              - first two lines: 
%                                          threshold value
%                                          legend for columns in "num_locs"
%                              - fourth and fifth line:
%                                          values that can be set in GUI and
%                                          set values 
%                        -num_locs:         number of localizations inside and
%                                          outside clusters

% Edit the above text to modify the response to help clustermask_createset

% Last Modified by GUIDE v2.5 12-Apr-2016 16:06:38

% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @clustermask_createset_OpeningFcn, ...
                   'gui_OutputFcn',  @clustermask_createset_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

%%% ------------------------------------------------------------------ %%%
%%%    OPEN GUI:                                                       %%%
%%% ------------------------------------------------------------------ %%%
% --- Executes just before clustermask_createset is made visible.
function clustermask_createset_OpeningFcn(hObject, eventdata, handles,varargin)
% Choose default command line output for clustermask_createset
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = clustermask_createset_OutputFcn(hObject, eventdata,handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;



%%% ------------------------------------------------------------------ %%%
%%%    CALLBACK FUNCTIONS:                                             %%%
%%% ------------------------------------------------------------------ %%%
% --- Executes on button press in browse_button.
function browse_button_Callback(hObject, eventdata, handles)
% get directory with files to process
handles.path = uigetdir;
cd(handles.path);
% list all *.csv files
files = dir( fullfile(handles.path,'*.csv') ); 
handles.files = {files.name};
% clear file-list
set(handles.file_list,'String',[]);
% write selected files into file-list
for cnt=1:numel(handles.files)
    filename=fullfile(handles.files{cnt});
    last_str=get(handles.file_list,'String');
    new_str=strvcat(last_str,filename);
    set(handles.file_list,'String',new_str);
end
% update handles
guidata(hObject, handles);

% --- Executes on button press in create_fig_checkbox.
function create_fig_checkbox_Callback(hObject, eventdata, handles)
if get(handles.create_fig_checkbox,'value')==0
    set(handles.include_roi_checkbox,'value',0);
    set(handles.save_png_checkbox,'value',0);
end

% --- Executes on button press in process_button.
function process_button_Callback(hObject, eventdata, handles)
% set BUSY sign visible
set(handles.busy_txt,'visible','on');
pause(0.001);

%% PARAMTERS:
% read data parameters from GUI
handles.roi = str2double(get(handles.roi_edit,'string'));
handles.pixelsize = str2double(get(handles.pixelsize_edit,'string'));

% read mask parameters from GUI
handles.gridsize = str2double(get(handles.gridsize_edit,'string'));
handles.sig = str2double(get(handles.sig_edit,'string'));
handles.sig_r = str2double(get(handles.sig_r_edit,'string'));

% read analysis parameters from GUI
handles.same_cellroi = get(handles.same_roi_checkbox,'value');

% read figure parameters from GUI
handles.create_fig = get(handles.create_fig_checkbox,'value');
handles.include_roi = get(handles.include_roi_checkbox,'value');
handles.save_png = get(handles.save_png_checkbox,'value');

% read tresholds from GUI
handles.TH(1)=str2double(get(handles.TH1_edit,'string'));
handles.TH(2)=str2double(get(handles.TH2_edit,'string'));
handles.TH(3)=str2double(get(handles.TH3_edit,'string'));
handles.TH(4)=str2double(get(handles.TH4_edit,'string'));
handles.TH(5)=str2double(get(handles.TH5_edit,'string'));
handles.TH(6)=str2double(get(handles.TH6_edit,'string'));
% remove zeros
handles.TH=handles.TH(handles.TH~=0);


%% PREPARATIONS:
% preallocation
result.num_locs=zeros(length(handles.files),length(handles.TH)*2);
result.num_locs_legend=cell(2,length(handles.TH)*2);
result.clust_area=zeros(length(handles.files),length(handles.TH));
result.cell_area=zeros(length(handles.files),1);
handles.use_cell=true(length(handles.files),1);

% get polygon ROIs to limit analyisis to area covered by a cell
for f=1:length(handles.files)
    % check if ROIs from previous analysis are available
    if exist(fullfile(handles.path,...
            strrep(handles.files{f},'.csv','_mask_info.mat')),'file')...
            && f==1
        answer=questdlg('Do you want to use ROIs from previous analysis?'...
            ,'','Yes','No','Yes');
    end
    
    % draw new ROIs (if necessary)
    if ~exist(fullfile(handles.path,...
            strrep(handles.files{f},'.csv','_mask_info.mat')),'file') ||...
            strcmp(answer,'No')
        if ~handles.same_cellroi || f==1
            % draw polygon ROI
            [cellroi_xy,handles.use_cell(f)]=clustermask_recordROI(...
                handles.roi,handles.gridsize,handles.files{f},...
                handles.path,handles.pixelsize);
            
            % pause for closing the figure of "clustermask_recordROI.m"
            pause(0.001);
            
            % summarize and safe parameters used to generate a mask for 
            % this file
            info.gridsize=handles.gridsize;
            info.pixelsize=handles.pixelsize;
            info.roi=handles.roi;
            info.sig=handles.sig;
            info.use=handles.use_cell(f);
            info.cellroi_xy=cellroi_xy;
            info.cellroi_xy_nm=cellroi_xy*handles.pixelsize;
            if isempty(cellroi_xy) && handles.use_cell(f)
                info.cellarea_nm2=handles.roi^2*handles.pixelsize^2;
            elseif isempty(cellroi_xy) && ~handles.use_cell(f)
                info.cellarea=[];
            else
                info.cellarea_nm2=polyarea(info.cellroi_xy_nm(:,1),...
                    info.cellroi_xy_nm(:,2));
            end
        end
        % save mask parameters and cellROI in info-file
        save(fullfile(handles.path,...
            strrep(handles.files{f},'.csv','_mask_info.mat')),'info');
    end
end

%% GENERATE CLUSTERMASKS:
for f=1:length(handles.files)
    % get filename without extension
    filename=strrep(handles.files{f},'.csv','');
    % load info file
    load(fullfile(handles.path,[filename, '_mask_info.mat']));
    
    if info.use
        % prepare localization data
        temp = clustermask_prepdata(handles.path,handles.files{f},...
            handles.pixelsize);
        
        % generate density-dependent map
        [map,locs_in_roi]=clustermask_gaussblur(handles.roi,...
            handles.pixelsize,handles.gridsize,handles.sig,handles.sig_r,...
            temp,info.cellroi_xy);

        % save density-dependent map
        save(fullfile(handles.path,[filename, '_density_map.mat']),'map');
        
        % loop over all selected thresholds
        for t=1:length(handles.TH)
            % create and save binary masks
            mask = clustermask_binary(map,handles.TH(t),locs_in_roi,...
                filename,handles,info);
            
            % count localizations inside clusters and outside of clusters 
            [result.num_locs(f,t*2),result.num_locs(f,t*2-1)]=...
                clustermask_sortlocs(mask,locs_in_roi,handles.roi,...
                handles.gridsize);
 
            % calculate the cluster area
            % in number of pixel
            ON=sum(sum(mask));
            % in nm²
            ON_nm2=ON*((handles.roi/handles.gridsize)*handles.pixelsize)^2;
            
            % copy data to output matrix files
            result.files(f,1)=cellstr(filename);
            result.cell_area(f)=info.cellarea_nm2;
            result.clust_area(f,t)=ON_nm2;
            result.num_locs_legend(1,(t*2))=num2cell(handles.TH(1,t));
            result.num_locs_legend(1,(t*2)-1)=num2cell(handles.TH(1,t));
            result.num_locs_legend(2,(t*2))=cellstr('ON_LOCS');
            result.num_locs_legend(2,(t*2)-1)=cellstr('OFF_LOCS');
        end
        % save collected data
        save(fullfile(handles.path,'result.mat'),'result');
    end
end

% hide "BUSY" sign
set(handles.busy_txt,'visible','off');
pause(0.001);



%%% ------------------------------------------------------------------ %%%
%%%    EMPTY CALLBACK FUNCTIONS:                                       %%%
%%% ------------------------------------------------------------------ %%%
% --- Executes on selection change in file_list.
function file_list_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function file_list_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function sig_r_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function sig_r_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function sig_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function sig_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function gridsize_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function gridsize_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in include_roi_checkbox.
function include_roi_checkbox_Callback(hObject, eventdata, handles)

function TH1_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function TH1_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function TH2_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function TH2_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function TH3_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function TH3_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function TH4_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function TH4_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function TH6_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function TH6_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function TH5_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function TH5_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in same_roi_checkbox.
function same_roi_checkbox_Callback(hObject, eventdata, handles)

function roi_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function roi_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pixelsize_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function pixelsize_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function save_png_checkbox_Callback(hObject, eventdata, handles)
