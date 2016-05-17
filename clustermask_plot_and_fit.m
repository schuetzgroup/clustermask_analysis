
function result=clustermask_plot_and_fit(handles,result)
%% -----------------------------------------------------------------------
% clustermask_plot_and_fit
% ------------------------------------------------------------------------
% authors: Andreas Arnold
% ------------------------------------------------------------------------
% syntax: clustermask_plot_and_fit(handles,result)
% ------------------------------------------------------------------------
%
% CLUSTERMASK_PLOT_AND_FIT uses results from clustermask_createset.m to
% generate plots of density inside clusters (rho) vs. the relative covered
% area (eta). If enough files (at least 3) were selected for analysis, the
% data will also be fitted with a parabolic fit to enable data
% normalization.
%
% INPUT:  1) handles     ... handles-struct from clustermask_createset
%                               --> contains all relevant parameters
%         2) result      ... struct containing results from
%                               clustermask_createset
%
% OUTPUT: 1) result      ... struct cointaining all results
%                               added: rho, eta, results of fit

%% PREPARATIONS:
% only fit data if at least three files were selected
if length(handles.files)>=3
    check_fit=true;
else
    warndlg('Data could not be fitted because less than 3 files were selected!');
    check_fit=false;
end

% Preallocation
eta=NaN(size(result.clust_area,1),length(handles.TH));
rho=NaN(size(result.clust_area,1),length(handles.TH));
if check_fit
    fit_results.rho_0=NaN(1,length(handles.TH));
    fit_results.a=NaN(1,length(handles.TH));
    fit_results.b=NaN(1,length(handles.TH));
end


%% PLOT AND FIT:
% loop over all thresholds
for t=1:length(handles.TH)
    % calculate eta and rho from data
    eta(:,t)=result.clust_area(:,t)./result.cell_area;
    rho(:,t)=result.num_locs(:,(t-1)*2+2)./result.clust_area(:,t);
    
    if check_fit
        % define model function for fitring
        modelfun = @(a,x) a(1)+a(2)*x.^a(3);
        % define upper and lower boundaries for fitting
        ub = [inf,inf,inf];
        lb = [0, 0, 1];
        % define startpoints for fitting
        start = [0,0,0];
        % specify fit options
        options = optimset('Display','off');
        
        % fit data
        par = lsqcurvefit(modelfun,start,eta(:,t),rho(:,t),lb,ub,options);
        % copy fit results
        fit_results.rho_0(t)=par(1);
        fit_results.a(t)=par(2)/par(1);
        fit_results.b(t)=par(3);
    end
    
    % plot results
    if get(handles.plot_checkbox,'value')==1
        figure
        % plot data
        if check_fit
            plot(eta(:,t),rho(:,t)./fit_results.rho_0(t),'bo',...
                'Markersize',6,'Linewidth',1.5);
            ylabel('\rho / \rho_0')
            axis([0 1 0 4])
        else
            plot(eta(:,t),rho(:,t),'bo',...
                'Markersize',6,'Linewidth',1.5);
            ylabel('\rho / #_i_n/nm^2')
            axis([0 1 0 max(rho(:,t))+max(rho(:,t))/3])
        end
        xlabel('\eta')
        title(['Threshold = ' num2str(handles.TH(1,t))]);
        hold on
        
        % plot reference curve
        if get(handles.ref_curve_checkbox,'value')==1 && check_fit
            eta_ref=0:0.01:1;
            rho_ref=1+str2double(get(handles.a_edit,'String'))*...
                eta_ref.^str2double(get(handles.b_edit,'String'));
            plot(eta_ref,rho_ref,'r','Linewidth',2);
        end
    end
end


%% POSTPROCESSING:
% store data in result struct
result.eta=eta;
result.rho=rho;
if check_fit
    result.fit=fit_results;
end