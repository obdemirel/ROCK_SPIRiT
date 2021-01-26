function outp = ATA_op_ADMM(x,m,n,no_c,data_ak_ind,kernel_r_ind,kernel_s_ind,ksb,slices,lambda,rho,loc_mask,Coil_sensitivites)

x = reshape(x,m,n,no_c);
D = @(x) selection_operator(x,loc_mask,ksb,n,no_c); %locations specify
DT = @(x) adjoint_selection_operator(x,loc_mask,ksb,n,no_c);
E = @(x) encoder(x,m,n,no_c,slices,Coil_sensitivites,ksb/slices);
ET = @(x) encoder_t(x,m,n,no_c,slices,Coil_sensitivites,ksb/slices);

adder1 = DT(D(x(:,:,:)));

adder = reshape(adder1,[ksb n no_c]);

ak_ind = data_ak_ind;
x1 = x(:);

G_ind = @(y) conv_op_ind(ak_ind,y,kernel_r_ind,kernel_s_ind,ksb,n,no_c);
GT_ind = @(y) conv_op_ind_t(ak_ind,y,kernel_r_ind,kernel_s_ind,ksb,n,no_c);

GminusI_ind = @(y) G_ind(y) - y;
GTminusI_ind = @(y) GT_ind(y) - y;

mid = lambda * GTminusI_ind(GminusI_ind(x1));
mid1 = reshape(mid,[ksb n no_c]);

p = x;

pe = p;

mid2 = adder + mid1;

pp = pe;
pp = (rho/2)*ET(E(pp));

outp = mid2+ pp;


outp = outp(:);
end


