%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Readout Concatenated K-Space SPIRiT (ROCK-SPIRIT) 
%% SMS MRI Reconstruction
%% Author: Omer Burak Demirel
%% Last Update: 01/25/2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ROCK SPIRiT requires following inputs:
%%
%% kspace (RO x PE x NO_C x Dynamics) - R2 undersampled with 24 ACS kept      
%% acs (RO x PE x NO_C x Slices) with CAIPI shitfs 
%% sense_maps (RO x PE x NO_C x Slices) with CAIPI shitfs 

%% RO:       # of readout lines
%% PE:       # of phase encode lines
%% NO_C:     # of coil elements
%% Dynamics: # of cardiac phases

clear all
run setPath

%% Loading the data
load cine_data
kspace = squeeze(kspace(:,:,:,1));
%parpool(maxNumCompThreads)
% parpool(5)

%%% This part handles the readout concatenation of the k-space and acs
[RO_acs,slice_R] = readout_conc_prep(kspace,acs);

%%% This part calibrates the ROCK-SPIRiT kernels
[data_kspace,kernel_set,kernel_r,kernel_s] = ROCK_SPIRIT_kernel(kspace,RO_acs,9,9,slice_R);

% ROCK-SPIRIT Reconstruction
[recon,recon_images] = ROCKSPIRIT(data_kspace,sense_maps,kernel_set,kernel_r,kernel_s,slice_R,45);
save('recon_images40','recon_images')

%% ROCK-SPIRIT Reconstruction with LLR
[recon_reg,recon_reg_images] = ROCKSPIRIT_reg(data_kspace,sense_maps,kernel_set,kernel_r,kernel_s,slice_R,5,20);
save('recon_reg_images','recon_reg_images')

delete(gcp('nocreate'))

%% Results
dyn = 1;  %% select a dynamic
result_plotter(dyn,reference_images,recon_images,recon_reg_images)
