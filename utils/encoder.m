function [out] = encoder(x,m,n,no_c,slice_n,Coil_sensitivites,ksb)

kspace_to_im = @(x) ifft2c(x) * sqrt(size(x,1) * size(x,2)) * sqrt(slice_n);
z_im = reshape(x,m,n,no_c);


z_im2 = kspace_to_im(z_im);
for slice_no =1:slice_n
    slice_im = (z_im2((slice_no-1)*ksb + 1:slice_no*ksb,:,:));
    sense_images(:,:,slice_no) = sum(conj(Coil_sensitivites(:,:,:,slice_no)).*slice_im,3);
end

out = [];
for slice_no = 1:slice_n
    out = [out;sense_images(:,:,slice_no)];
end

end

