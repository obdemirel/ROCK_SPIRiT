function [kspace] = shifter_ro_direc(kspace,fov_shifts,fov_amount);

for ii=1:size(kspace,4)
[m,n,no_c] = size(squeeze(kspace(:,:,:,ii)));
phases = exp(sqrt(-1)*(fov_shifts(ii))*2*pi/fov_amount*(0:m-1)).';
phas = repmat(phases,[1 n no_c]);
kspace(:,:,:,ii) = squeeze(kspace(:,:,:,ii)) .* phas;
end

end

