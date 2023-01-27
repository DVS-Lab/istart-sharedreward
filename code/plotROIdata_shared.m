clear
close all;
clc

% Daniel Sazhin
% Adapted from D.Smith's code in r21-cardgame
% ISTART
% 03/23/21
% DVS Lab
% Temple University

% This code plots ROIs for the Shared Reward task.

% set up dirs

codedir = '/data/projects/istart-sharedreward/code'; % Run code from this path.
addpath(codedir)
maindir = '/data/projects/istart-sharedreward';
roidir = '/data/projects/istart-sharedreward/derivatives/imaging_plots/'; % Results from extractROI script.
resultsdir = '/data/projects/istart-sharedreward/derivatives/imaging_plots/results/'; % Output where results will be saved.

rois = {'act_C14_rew_F-S_z1_main_cluster2'}; %{'resampled_aTPJ-thr50-2mm' 'resampled_pTPJ-thr50-2mm'}; % 'target-pcc_bin' 'target-FFA_bin' 'target-vmPFC_bin'}; %'seed-VS_thr5' 'seed-vmPFC-5mm-thr' 'seed-mPFC-thr' %'ppi_C10_FS-C_z8_sub-neg_cluster1'} 
models = {'_type-act_'}; % {'_type-act_'}; {'_type-ppi_seed-VS_thr5_'};

% Test hypotheses:

H3 = 1; 

%% H3

if H3 == 1
   
        name = 'Act_Result'; %'PPI_Result';
        R_Friend = {'cope-04.txt'};
        R_Stranger = {'cope-06.txt'};
        R_Computer = {'cope-02.txt'};
        P_Friend = {'cope-03.txt'};
        P_Stranger = {'cope-05.txt'};
        P_Computer = {'cope-01.txt'};
        
        
        type=' act'; %' ppi';
        plot_sharedreward(name, roidir, rois, models, R_Friend, R_Stranger, R_Computer, P_Friend, P_Stranger, P_Computer, type)  
end