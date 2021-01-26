function [oo] = atb_func(ddts,zs,Ks,rho,Coil_sensitivites,ksb,slices)


[m,n,no_c] = size(ddts);

ET = @(x) encoder_t(x,m,n,no_c,slices,Coil_sensitivites,ksb/slices);

zs = reshape(zs,m,n);
Ks = reshape(Ks,m,n);

ddts1 =  ddts;


z1 = zs;
k1 = Ks;

insider1 = z1 - k1/rho;


insider = ET(insider1);

oo = [ddts1 + (rho/2)*insider];
oo = oo(:);

end

