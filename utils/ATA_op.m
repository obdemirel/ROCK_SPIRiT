function outp = ATA_op(x,m,n,no_c,data_ak,kernel_r_ind,kernel_s_ind,sigmas,loc_mask)

x = reshape(x,m,n,no_c);
D = @(x) selection_operator(x,loc_mask,m,n,no_c); %locations specify
DT = @(x) adjoint_selection_operator(x,loc_mask,m,n,no_c);
adder1 = DT(D(x(:,:,:)));

adder = reshape(adder1,[m n no_c]);

ak_ind = (data_ak(:,:));

x1 = x;
x1 = x1(:);

G_ind = @(y) conv_op_ind(ak_ind,y,kernel_r_ind,kernel_s_ind,m,n,no_c);
GT_ind = @(y) conv_op_ind_t(ak_ind,y,kernel_r_ind,kernel_s_ind,m,n,no_c);

GminusI_ind = @(y) G_ind(y) - y;
GTminusI_ind = @(y) GT_ind(y) - y;

mid = sigmas * GTminusI_ind(GminusI_ind(x1));
mid1 = reshape(mid,[m n no_c]);

mid_all = mid1+adder;
outp = mid_all;


outp = outp(:);
end


