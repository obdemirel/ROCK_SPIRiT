function [acs_f,slice_R] = readout_conc_prep(kspace_inp,acs_inp)

[m,n,no_c,ims] = size(kspace_inp);
[mm,nn,no_c,slice_R] = size(acs_inp);


%% ReadOut Concatenation is done im image domain
acs_im = [];
for ii = 1:slice_R
    acs_im = [acs_im;ifft2c(acs_inp(:,:,:,ii))];
end

%% Readout Concatenated ACS region is foremd by switching back to k-space
acs_f = fft2c(acs_im);
end

