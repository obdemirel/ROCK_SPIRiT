function [] = result_plotter(dyn,recon_images,recon_reg_images)

roi_select_x = [174-50:174+50];
roi_select_y = [89-50:89+50];

shiftings = [0 45 90];

slices_all = [];
    
figure,
if(nargin==2) 
for slice_n = 1:size(recon_images,3)
    
    if(slice_n==1)
        shift_amo = shiftings(1);
    elseif(slice_n==2)
        shift_amo = shiftings(2);
    elseif(slice_n==3)
        shift_amo = shiftings(3);
    else
        shift_amo = 0;
    end
    
    recon_images(:,:,slice_n,:) = circshift(recon_images(:,:,slice_n,:),[0 shift_amo 0 0]);
    rock = fliplr(flipud(abs(recon_images(:,:,slice_n,dyn))));

    rock = rock(roi_select_x,roi_select_y);
  
    slices_all = [slices_all;ones(1,size(cat(2,rock,ones(size(rock,1),1)),2));cat(2,rock,ones(size(rock,1),1))];


    imshow(slices_all,[]), ...
        title('ROCK-SPIRiT '), ylabel('1st Slice -  2nd Slice - 3rd Slice'),...
        xlabel(['Dynamic: ', num2str(dyn)])
    
end
elseif(nargin==3)
    for slice_n = 1:size(recon_images,3)
    
    if(slice_n==1)
        shift_amo = shiftings(1);
    elseif(slice_n==2)
        shift_amo = shiftings(2);
    elseif(slice_n==3)
        shift_amo = shiftings(3);
    else
        shift_amo = 0;
    end
    
    recon_images(:,:,slice_n,:) = circshift(recon_images(:,:,slice_n,:),[0 shift_amo 0 0]);
    recon_reg_images(:,:,slice_n,:) = circshift(recon_reg_images(:,:,slice_n,:),[0 shift_amo 0 0]);
    rock = fliplr(flipud(abs(recon_images(:,:,slice_n,dyn))));
    reg_rock = fliplr(flipud(abs(recon_reg_images(:,:,slice_n,dyn))));
    
    rock = rock(roi_select_x,roi_select_y);
    reg_rock = reg_rock(roi_select_x,roi_select_y);
    
    
    slices_all = [slices_all;ones(1,size(cat(2,rock,ones(size(rock,1),1),reg_rock),2));cat(2,rock,ones(size(rock,1),1),reg_rock)];

    imshow(slices_all,[]), ...
        title('ROCK-SPIRiT - Regularized ROCK-SPIRiT'), ylabel('1st Slice -  2nd Slice - 3rd Slice'),...
        xlabel(['Dynamic: ', num2str(dyn)])
    
end
end
end

