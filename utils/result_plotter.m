function [] = result_plotter(dyn,reference_images,recon_images,recon_reg_images,ref_check)

roi_select_x = [174-50:174+50];
roi_select_y = [89-50:89+50];

shiftings = [0 45 90];

if(ref_check==1)
    slices_all = [];
    for slice_n = 1:size(reference_images,3)
        
        if(slice_n==1)
            shift_amo = shiftings(1);
        elseif(slice_n==2)
            shift_amo = shiftings(2);
        elseif(slice_n==3)
            shift_amo = shiftings(3);
        else
            shift_amo = 0;
        end
        
        reference_images(:,:,slice_n,:) = circshift(reference_images(:,:,slice_n,:),[0 shift_amo 0 0]);
        recon_images(:,:,slice_n,:) = circshift(recon_images(:,:,slice_n,:),[0 shift_amo 0 0]);
        recon_reg_images(:,:,slice_n,:) = circshift(recon_reg_images(:,:,slice_n,:),[0 shift_amo 0 0]);
        fully = fliplr(flipud(abs(reference_images(:,:,slice_n,dyn))));
        rock = fliplr(flipud(abs(recon_images(:,:,slice_n,dyn))));
        reg_rock = fliplr(flipud(abs(recon_reg_images(:,:,slice_n,dyn))));
        
        fully = fully(roi_select_x,roi_select_y);
        rock = rock(roi_select_x,roi_select_y);
        reg_rock = reg_rock(roi_select_x,roi_select_y);
        
        
        slices_all = [slices_all;ones(1,size(cat(2,fully,ones(size(fully,1),1),rock,ones(size(fully,1),1),reg_rock),2));cat(2,fully,ones(size(fully,1),1),rock,ones(size(fully,1),1),reg_rock)];
    end
    
    figure,
    imshow(slices_all,[]), ...
        title('Fully Sampled - ROCK-SPIRiT - Regularized ROCK-SPIRiT'), ylabel('1st Slice -  2nd Slice - 3rd Slice'),...
        xlabel(['Dynamic: ', num2str(dyn)])
    
else
    slices_all = [];
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
    end

    figure,
    imshow(slices_all,[]), ...
        title('ROCK-SPIRiT - Regularized ROCK-SPIRiT'), ylabel('1st Slice -  2nd Slice - 3rd Slice'),...
        xlabel(['Dynamic: ', num2str(dyn)])
    
end
end

