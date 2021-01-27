function [recon,recon_images] = ROCKSPIRIT(data_kspace,sense_maps,data_ak_set,kernel_r,kernel_s,slice_R,cg_iter)

disp('Reconstruction starts...')

ksb = size(data_kspace,1)/slice_R;
[m,n,no_c,ims]= size(data_kspace);

sigma = 1;

%parpool(maxNumCompThreads)
% parfor ss=1:size(data_kspace,4)
parfor ss=1:size(data_kspace,4)
    disp(['Dynamic: ',num2str(ss),' in progress'])
    tic
    
    ksms = (squeeze(data_kspace(:,:,:,ss)));
    
    %%% sampling points%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [m,n,no_c]= size(ksms);
    non_acq_p = ksms==0;
    acq_p = ones(m,n,no_c,'single')-non_acq_p;
    non_acq_p = logical(non_acq_p);
    loc_mask = logical(acq_p);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    %% Following objective function is solved:
    %% arg min_(K_ext) ||P_OmeageK_ext - K_SMS||_2^2 + ||G_RockK_ext - K_ext||_2^2
    %% mat_op calculates the A^TA operation when the above function
    %% is formed as ||Ax-b||_2^2 format
    mat_op = @(x) ATA_op(x,m,n,no_c,data_ak_set,kernel_r,kernel_s,sigma,loc_mask);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    D = @(x) selection_operator(x,loc_mask,m,n,no_c); %locations specify
    DT = @(x) adjoint_selection_operator(x,loc_mask,m,n,no_c);
    
    %%% DT(D(K_SMS)) operation equals to select
    select = reshape(DT(D(ksms)),[m n no_c]);
    DTDksms = [select];
    
    ATA =  @(x) mat_op(x);
    ATb = DTDksms; %% When ||Ax-b||_2^2 format is considered
   
    x = ksms(:); %%input is the zero filled one
    
    [x,error] = conjgrad(cg_iter,ATA, ATb(:), x(:)); %% conjugate gradient operations
    
    recon(:,:,:,ss) = reshape(x,[m n no_c]);
    
    toc
end

%%% SENSE-1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ss=1:size(data_kspace,4)
    concatenated_imags = encoder(recon(:,:,:,ss),m,n,no_c,slice_R,sense_maps,ksb);
    for slis = 1:slice_R
        recon_images(:,:,slis,ss) = concatenated_imags(ksb*(slis-1) + 1:slis*ksb,:);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('ROCK-SPIRiT Reconstruction ended!')
%delete(gcp('nocreate'))
end

