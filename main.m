%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Readout Concatenated K-Space SPIRiT (ROCK-SPIRIT) 
%% SMS MRI Reconstruction
%% Author: Omer Burak Demirel
%% Last Update: 01/28/2021
%% If you would like to use this code in one of your publications,
%% please cite the following:
%% Demirel, O. B., Weingärtner, S., Moeller, S., Akçakaya, M., 
%% "Improved simultaneous multislice cardiac MRI using readout concatenated k-space SPIRiT (ROCK-SPIRiT)",
%% Magnetic Resonance in Medicine, in press.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ROCK SPIRiT requires following inputs:
%%
%% kspace (RO x PE x NO_C x Dynamics) - R2 undersampled with 24 ACS kept      
%% acs (RO x PE x NO_C x Slices) with CAIPI shitfs 
%% sense_maps (RO x PE x NO_C x Slices) with CAIPI shitfs 

%% RO:       # of readout lines
%% PE:       # of phase encode lines
%% NO_C:     # of coil elements
%% Slices:   # of slices
%% Dynamics: # of cardiac phases

clear all
run setPath

%% Loading the data
load cine_data %% File contains kspace,acs,sense_maps

%Please use parpool when data has dynamics
%parpool(maxNumCompThreads)

%%% This part generates the ESPIRiT maps using the acs data. Following paper and it's code is used:
%%% Uecker, Martin, et al. "ESPIRiT—an eigenvalue approach to autocalibrating parallel MRI:
%%% where SENSE meets GRAPPA." Magnetic resonance in medicine 71.3 (2014): 990-1001.
sense_maps = espirit_generator(kspace,acs,[6,6],0.02); 

%%% This part handles the readout concatenation of the k-space and acs
[RO_acs,slice_R] = readout_conc_prep(kspace,acs);

%%% This part calibrates the ROCK-SPIRiT kernels
[data_kspace,kernel_set,kernel_r,kernel_s] = ROCK_SPIRIT_kernel(kspace,RO_acs,9,9,slice_R);

% ROCK-SPIRIT Reconstruction
[recon,recon_images] = ROCKSPIRIT(data_kspace,sense_maps,kernel_set,kernel_r,kernel_s,slice_R,45);
save('recon_images','recon_images')

%% ROCK-SPIRIT Reconstruction with LLR
%% Use when input data has dynamics
%[recon_reg,recon_reg_images] = ROCKSPIRIT_reg(data_kspace,sense_maps,kernel_set,kernel_r,kernel_s,slice_R,5,20);
%save('recon_reg_images','recon_reg_images')

delete(gcp('nocreate'))

%% Results
dyn = 1;  %% select a dynamics
if(exist('recon_reg_images.mat','file')~=0)
result_plotter(dyn,recon_images,recon_reg_images)
else
    result_plotter(dyn,recon_images)
end
