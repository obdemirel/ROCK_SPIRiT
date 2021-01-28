function [recon_reg,recon_reg_images] = ROCKSPIRIT_reg(data_kspace,Coil_sensitivites,kernel_set,kernel_r,kernel_s,slice_R,cg_iter,outer_loop);



DTDksms = zeros(size(data_kspace),'single');
lambda_orig_s = zeros(size(data_kspace),'single');
ATb = zeros(size(data_kspace,1)*size(data_kspace,2)*size(data_kspace,3),size(data_kspace,4),'single');
x = zeros(size(data_kspace,1)*size(data_kspace,2)*size(data_kspace,3),size(data_kspace,4),'single');

% cg_iter = 5;
% outer_loop = 20; %10+1;

ksb = size(data_kspace,1);
num_images = size(data_kspace,4);

%% parameters for ADMM and LLR
lambda = 1; 
%%% use these ones for LLR
rho = 1e-1;
llr_th_sca = 0.1; % 4.4 and 4.7
p1 = 8;
soft_sign = 1; %% zero means hard
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% preperation of x z and K
for ss= 1:num_images
    
    
    ksms = (squeeze(data_kspace(:,:,:,ss)));
    input = ksms;
    
    [m,n,no_c] = size(input);
    
    %%% sampling points%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% uncomment if you want to let itself find the points
    non_acq_p = ksms==0;
    acq_p = ones(ksb,n,no_c,'single')-non_acq_p;
    non_acq_p = logical(non_acq_p);
    loc_mask = logical(acq_p);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% some usefull functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    kspace_to_im = @(x) ifft2c(x);
    im_to_kspace = @(x) fft2c(x);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    E = @(x) encoder(x,m,n,no_c,slice_R,Coil_sensitivites,ksb/slice_R);
    ET = @(x) encoder_t(x,m,n,no_c,slice_R,Coil_sensitivites,ksb/slice_R);
    
    
    %% the whole ATA matrix is inside
    mat_op = @(x) ATA_op_ADMM(x,m,n,no_c,kernel_set,kernel_r,kernel_s,ksb,slice_R,lambda,rho,loc_mask,squeeze(Coil_sensitivites(:,:,:,:)));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    D = @(x) selection_operator(x,loc_mask,ksb,n,no_c); %locations specify
    DT = @(x) adjoint_selection_operator(x,loc_mask,ksb,n,no_c);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%% DT(D(ksms)) operation equals to select
    select = reshape(DT(D(ksms)),[ksb n no_c]);
    DTDksms(:,:,:,ss) = [select];
    
    z(:,ss) = reshape(E(input(:)),m*n,1);
    K = zeros(size(z),'single');
    
    
    ATA =  @(x) mat_op(x);
    ddts = DTDksms(:,:,:,ss);
    
    
    %ATb(:,ss) = lls(:) + ddts(:) + 0.5*rho*(z(:,ss) - K(:,ss)/rho);
    
    x(:,ss) = 1.*ddts(:);  %% if you want initialize from aliased images
    z(:,ss) = reshape(E(x(:,ss)),m*n,1);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


%parpool(maxNumCompThreads)
for main_loop = 1:outer_loop
    

    parfor ss=1:num_images
        disp(['Outer loop at: ' num2str(main_loop) ', from a total of: ' num2str(ss)])
        
        ddts = DTDksms(:,:,:,ss);
        ATb = @(zzz,kkk) atb_func(ddts,zzz,kkk,rho,Coil_sensitivites,ksb,slice_R);
        
        [x(:,ss),error] = conjgrad(cg_iter,ATA, ATb(z(:,ss),K(:,ss)), x(:,ss));

        %%% z iteration
        z_plus_k(:,:,ss) = E(x(:,ss)) + reshape(K(:,ss)/rho,m,n);
    end

    
    slice_n = slice_R;
    shift_amounts = ([1:slice_R]-1)*45;
    parfor slice_no=1:slice_n
        
        sense1 = z_plus_k((slice_no-1)*ksb/slice_n + 1:slice_no*ksb/slice_n,:,:);         
        %% Shifting images to the midddles to avoid border artifacts
        %% Can be discarded as well. PE shifting amount depends on the acceleration
        %% factor. Please change the shifting amount accordinly. 
  
        sense1 = circshift(sense1,[0 shift_amounts(slice_no) 0]);
        
        llr_th = llr_th_sca* max(abs(sense1(:)));
        denoised_sense1(:,:,:,slice_no) = llr_threshold(sense1, p1, p1, llr_th, soft_sign);  
    end
    
    for slice_no=1:slice_n
    denoised_sense1(:,:,:,slice_no) = circshift(denoised_sense1(:,:,:,slice_no),[0 -shift_amounts(slice_no) 0]);
    end

    
    %% update for aux variable
    for ss = 1:num_images
                dd1 = [];
        for slice_no=1:slice_n
            dd1 = [dd1;squeeze(denoised_sense1(:,:,ss,slice_no))];
        end
        z(:,ss) = dd1(:);
        xx = E(x(:,ss));
        K(:,ss) = K(:,ss) + rho*(xx(:)-z(:,ss));
        
    end
end


%%% Saving 
for ss=1:num_images
    recon_reg(:,:,:,ss) = reshape(x(:,ss),[m n no_c]);
end

recon_reg_images = permute(denoised_sense1,[1 2 4 3]);


%delete(gcp('nocreate'))


end

