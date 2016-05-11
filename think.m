function table=think(corpus)
%% ------------------------------------------------------------------------
% think
% -------------------------------------------------------------------------
% author: Manuel Mörtelmayer, Andreas Arnold (comments)
% 
% -------------------------------------------------------------------------
% syntax: table = think (corpus)
% -------------------------------------------------------------------------
%
% THINK evaluates how often, in a list of scalar values, individual values
% appear. This can e.g. be used to calculate the length of many indivudual
% trajectories simultanuously by analyzing how often the individual
% id-numbers appear in a list.
%
% INPUT:  1) corpus    ... N x 1 list of scalar values
% 
% OUTPUT: 1) table     ... N x 2 array containing
%                          -->  1 col: all appearing scalar values
%                               2 col: number of appearences for each value

%% ENGINE:
% sort scalars
h=sort(corpus);
% shift sorted list of scalars by one field
i=[h;0];
j=[0;h];
% compare original list and shifted list
contr=(i~=j);
% find indices where a new scalar value appears
isnew=find(contr);
isnew=isnew(1:end-1);
% get corresponding scalar values
ocs=i(isnew);
% get number of times a scalar appears in list
ends=isnew(2:end);
[m,n]=size(j);
ends=[ends;m];
nums=ends-isnew;
% summarize for output
table=[ocs,nums];