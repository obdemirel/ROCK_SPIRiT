function [sense_maps] = generate_images_MB(kspace_recon_center)

%this function was written for slie grappa reconstructions
%kspace_grappa_recons: full recon using slice grappa of 3 slices
%kspace_recon_center: slice grappa recon of the ACS region of the MB data
%(this gives you a low resolution dataset from which coil maps are
%generated)

%for your case
%center_start should be where your acs region starts in your MB-data
%center_end is where it ends

%phase_sens is what we use for fitting t1 maps

[m,n,no_c, no_sl,no_ims] = size(kspace_recon_center);
% kspace_to_im = @(x) fftshift(fftshift(ifft2(x), 1),2);
kspace_to_im = @(x) ifft2(x);
rssq = @(x) squeeze(sum(abs(x).^2,3)).^(1/2);
kspace = kspace_recon_center(:,:,:,1,1);
im_mask = double(sum(sum(sum(abs(kspace),1),3),4) >0);
picks = find(im_mask);
d_picks = diff(picks,[],2);
indic = find(d_picks == 1);
center_start = indic(1);
center_end = indic(end);

kspace_coils = zeros(m,n,no_c, no_sl, 'single');
tukey_filt = tukeywin(length(picks(center_start):picks(center_end)),0.5)';
tukey_filt = repmat(tukey_filt, [m 1 no_c no_sl]);
kspace_coils(:,picks(center_start):picks(center_end),:,:,1) = kspace_recon_center(:,picks(center_start):picks(center_end),:,:,1) .* tukey_filt;
im_coils = kspace_to_im(kspace_coils);
sense_maps = repmat(im_coils ./ permute(repmat(rssq(im_coils)+eps,[1 1 1 no_c]),[1 2 4 3]), [1 1 1 1 no_ims]);
%img_grappa_sense1 = squeeze(abs(sum(conj(Coil_sensitivites) .* kspace_to_im(kspace_grappa_recons),3)));

%img_grappa_phase_sens = squeeze(real(sum(conj(Coil_sensitivites) .* kspace_to_im(kspace_grappa_recons),3)));
