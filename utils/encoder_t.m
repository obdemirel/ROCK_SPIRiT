function [out] = encoder_t(x,m,n,no_c,slice_n,Coil_sensitivites,ksb)
        
        im_to_kspace = @(x) fft2c(x) / (sqrt(size(x,1) * size(x,2)) * sqrt(slice_n));
        z_im1 = reshape(x,m,n);
        
        for slice_no =1:slice_n
           z_im(:,:,slice_no) = z_im1(ksb*(slice_no-1) + 1:slice_no*ksb,:);
        end

        for slice_no =1:slice_n
            new_z((slice_no-1)*ksb + 1:slice_no*ksb,:,:) = repmat(z_im(:,:,slice_no),[1 1 no_c]).*Coil_sensitivites(:,:,:,slice_no);
        end
        z_kspace = im_to_kspace(new_z);
        
        out =[];
        for slice_no =1:slice_n
           out = [out;z_kspace(ksb*(slice_no-1) + 1:slice_no*ksb,:,:)];
        end
        
end

