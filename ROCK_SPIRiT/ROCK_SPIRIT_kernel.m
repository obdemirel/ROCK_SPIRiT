function [data_kspace,data_ak_set,kernel_r,kernel_s] = ROCK_SPIRIT_kernel(kspace,RO_acs,kernel_row,kernel_col,slice_R)


conc_acs_fregion = RO_acs;
reg = 1e-2; 

%%% KERNEL %%%%%%%%%
% XXX        XXX
% XXX    ->  X1X
% XXX        XXX
%%%%%%%%%%%%%%%%%%%%


kernel_dim = kernel_row*kernel_col;

MA = zeros((size(conc_acs_fregion,1)-(kernel_row-1))*(size(conc_acs_fregion,2)-(kernel_col-1)),kernel_dim*size(conc_acs_fregion,3));

%% MA matrix filling
%% Kernels are shifted over the ACS region to form the calibration marix
for coil_selec = 1:size(conc_acs_fregion,3)
    selected_acs = conc_acs_fregion(:,:,coil_selec);
    row_count = 1;
        for col = 1:size(selected_acs,2)-(kernel_col-1)
            for row = 1:size(selected_acs,1)-(kernel_row-1)
                neighbors = selected_acs(row:row+(kernel_row-1),col:col+(kernel_col-1));
                neighbors = neighbors(:).';
                MA(row_count,(coil_selec-1)*(kernel_dim) +1:coil_selec*(kernel_dim)) = neighbors;
                row_count = row_count+1;
            end
        end
    %disp(['MA ' num2str(coil_selec) ' coil is ready!'])
end


row_start = ceil(kernel_row/2);
row_end = size(conc_acs_fregion,1)-floor(kernel_row/2);
col_start = ceil(kernel_col/2);
col_end = size(conc_acs_fregion,2)-floor(kernel_col/2);


%%%% Corresponding middle points of the kernels are formed into destination vectors.
Mk = zeros(size(MA,1),size(conc_acs_fregion,3));
%% Mk vectors filling
for coil_selec = 1:size(conc_acs_fregion,3)
    selected_acs = conc_acs_fregion(row_start:row_end,col_start:col_end,coil_selec);
    Mk(:,coil_selec) = selected_acs(:);
end




ak = zeros(kernel_dim*size(conc_acs_fregion,3) -  1,size(conc_acs_fregion,3));

%% Pre calculation of the matrix multiplications
A = MA'*MA;
B = MA'*Mk;

lambda = norm(A,'fro')/sqrt(size(A,1))*reg;

%parpool(maxNumCompThreads)
parfor coil_selec = 1:size(conc_acs_fregion,3)
    
    A1 = A(1:ceil(kernel_dim/2)-1 + (coil_selec-1)*kernel_dim,:);
    A2 = A(ceil(kernel_dim/2)+1+ (coil_selec-1)*kernel_dim :end,:);
    newA = [A1;A2];
    A3 = newA(:,1:ceil(kernel_dim/2)-1 + (coil_selec-1)*kernel_dim);
    A4 = newA(:,ceil(kernel_dim/2)+1+ (coil_selec-1)*kernel_dim:end);
    newA = [A3 A4];
    
    B1 = B(1:ceil(kernel_dim/2)-1+ (coil_selec-1)*kernel_dim,:);
    B2 = B(ceil(kernel_dim/2)+1+(coil_selec-1)*kernel_dim:end,:);
    newB = [B1;B2];
    
    
    ak(:,coil_selec) = (newA + eye(size(newA))*lambda)\squeeze(newB(:,coil_selec));
    
    %disp(['Coil ' num2str(coil_selec) ' weights are ready!'])
end

new_ak = zeros(kernel_dim*size(conc_acs_fregion,3),size(conc_acs_fregion,3));


for coil_selec = 1:size(conc_acs_fregion,3)
    p1 = ak(1:ceil(kernel_dim/2) + (coil_selec-1)*kernel_dim -1,coil_selec);
    p2 = ak(ceil(kernel_dim/2) + (coil_selec-1)*kernel_dim:end,coil_selec);
    new_ak(:,coil_selec) = [p1;0;p2];
end

data_ak_set(:,:) = new_ak;

disp('Kernel Calibration is done!')

clear A B MA Mk

for ss=1:size(kspace,4)
    multi_slice_kspace = kspace(:,:,:,ss);
    small_art_kspace1 = zeros(size(multi_slice_kspace,1)*slice_R,size(multi_slice_kspace,2),size(multi_slice_kspace,3),'single');
    small_art_kspace1(1:slice_R:end,:,:) = multi_slice_kspace;
    %% When SMS acceleration is even, 1/SMS*2 shift is need!
    if(mod(slice_R,2)==0)
        [small_art_kspace1] = shifter_ro_direc(small_art_kspace1,[1],slice_R*2);
    end
    data_kspace(ss,:,:,:) = small_art_kspace1;
end

data_kspace = permute(data_kspace,[2 3 4 1]);


kernel_r = kernel_row;
kernel_s = kernel_col;

%delete(gcp('nocreate'))
end

