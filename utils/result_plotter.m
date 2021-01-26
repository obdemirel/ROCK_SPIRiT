function [] = result_plotter(dyn,reference_images,recon_images,recon_reg_images,ref_check)

roi_select_x = [174-50:174+50];
roi_select_y = [89-50:89+50];

if(ref_check==1)
    for slice_n = 1:size(reference_images,3)
        
        if(slice_n==1)
            %% first reshift the CAIPI shift
            reference_images(:,:,slice_n,:) = circshift(reference_images(:,:,slice_n,:),[0 0 0 0]);
            recon_images(:,:,slice_n,:) = circshift(recon_images(:,:,slice_n,:),[0 0 0 0]);
            recon_reg_images(:,:,slice_n,:) = circshift(recon_reg_images(:,:,slice_n,:),[0 0 0 0]);
            fully = fliplr(flipud(abs(reference_images(:,:,slice_n,dyn))));
            rock = fliplr(flipud(abs(recon_images(:,:,slice_n,dyn))));
            reg_rock = fliplr(flipud(abs(recon_reg_images(:,:,slice_n,dyn))));
            
            fully = fully(roi_select_x,roi_select_y);
            rock = rock(roi_select_x,roi_select_y);
            reg_rock = reg_rock(roi_select_x,roi_select_y);
            
            slice1s = cat(2,fully,ones(size(fully,1),1),rock,ones(size(fully,1),1),reg_rock);
        elseif(slice_n==2)
            %% first reshift the CAIPI shift
            reference_images(:,:,slice_n,:) = circshift(reference_images(:,:,slice_n,:),[0 45 0 0]);
            recon_images(:,:,slice_n,:) = circshift(recon_images(:,:,slice_n,:),[0 45 0 0]);
            recon_reg_images(:,:,slice_n,:) = circshift(recon_reg_images(:,:,slice_n,:),[0 45 0 0]);
            fully = fliplr(flipud(abs(reference_images(:,:,slice_n,dyn))));
            rock = fliplr(flipud(abs(recon_images(:,:,slice_n,dyn))));
            reg_rock = fliplr(flipud(abs(recon_reg_images(:,:,slice_n,dyn))));
            
            fully = fully(roi_select_x,roi_select_y);
            rock = rock(roi_select_x,roi_select_y);
            reg_rock = reg_rock(roi_select_x,roi_select_y);
            
            slice2s = cat(2,fully,ones(size(fully,1),1),rock,ones(size(fully,1),1),reg_rock);
        elseif(slice_n==3)
            %% first reshift the CAIPI shift
            reference_images(:,:,slice_n,:) = circshift(reference_images(:,:,slice_n,:),[0 90 0 0]);
            recon_images(:,:,slice_n,:) = circshift(recon_images(:,:,slice_n,:),[0 90 0 0]);
            recon_reg_images(:,:,slice_n,:) = circshift(recon_reg_images(:,:,slice_n,:),[0 90 0 0]);
            fully = fliplr(flipud(abs(reference_images(:,:,slice_n,dyn))));
            rock = fliplr(flipud(abs(recon_images(:,:,slice_n,dyn))));
            reg_rock = fliplr(flipud(abs(recon_reg_images(:,:,slice_n,dyn))));
            
            fully = fully(roi_select_x,roi_select_y);
            rock = rock(roi_select_x,roi_select_y);
            reg_rock = reg_rock(roi_select_x,roi_select_y);
            
            slice3s = cat(2,fully,ones(size(fully,1),1),rock,ones(size(fully,1),1),reg_rock);
        end
        
    end
    
    figure,
    imshow(cat(1,slice1s,ones(1,size(slice1s,2)),slice2s,ones(1,size(slice1s,2)),slice3s),[]), ...
        title('Fully Sampled - ROCK-SPIRiT - Regularized ROCK-SPIRiT'), ylabel('1st Slice -  2nd Slice - 3rd Slice'),...
        xlabel(['Dynamic: ', num2str(dyn)])
    
else
    for slice_n = 1:size(recon_images,3)
        
        if(slice_n==1)
            %% first reshift the CAIPI shift
            recon_images(:,:,slice_n,:) = circshift(recon_images(:,:,slice_n,:),[0 0 0 0]);
            recon_reg_images(:,:,slice_n,:) = circshift(recon_reg_images(:,:,slice_n,:),[0 0 0 0]);
            rock = fliplr(flipud(abs(recon_images(:,:,slice_n,dyn))));
            reg_rock = fliplr(flipud(abs(recon_reg_images(:,:,slice_n,dyn))));
            
            rock = rock(roi_select_x,roi_select_y);
            reg_rock = reg_rock(roi_select_x,roi_select_y);
            
            slice1s = cat(2,rock,ones(size(rock,1),1),reg_rock);
        elseif(slice_n==2)
            %% first reshift the CAIPI shift
            recon_images(:,:,slice_n,:) = circshift(recon_images(:,:,slice_n,:),[0 45 0 0]);
            recon_reg_images(:,:,slice_n,:) = circshift(recon_reg_images(:,:,slice_n,:),[0 45 0 0]);
            rock = fliplr(flipud(abs(recon_images(:,:,slice_n,dyn))));
            reg_rock = fliplr(flipud(abs(recon_reg_images(:,:,slice_n,dyn))));
            
            rock = rock(roi_select_x,roi_select_y);
            reg_rock = reg_rock(roi_select_x,roi_select_y);
            
            slice2s = cat(2,rock,ones(size(rock,1),1),reg_rock);
        elseif(slice_n==3)
            %% first reshift the CAIPI shift
            recon_images(:,:,slice_n,:) = circshift(recon_images(:,:,slice_n,:),[0 90 0 0]);
            recon_reg_images(:,:,slice_n,:) = circshift(recon_reg_images(:,:,slice_n,:),[0 90 0 0]);
            rock = fliplr(flipud(abs(recon_images(:,:,slice_n,dyn))));
            reg_rock = fliplr(flipud(abs(recon_reg_images(:,:,slice_n,dyn))));
            
            rock = rock(roi_select_x,roi_select_y);
            reg_rock = reg_rock(roi_select_x,roi_select_y);
            
            slice3s = cat(2,rock,ones(size(rock,1),1),reg_rock);
        end
        
    end
    
    figure,
    imshow(cat(1,slice1s,ones(1,size(slice1s,2)),slice2s,ones(1,size(slice1s,2)),slice3s),[]), ...
        title('ROCK-SPIRiT - Regularized ROCK-SPIRiT'), ylabel('1st Slice -  2nd Slice - 3rd Slice'),...
        xlabel(['Dynamic: ', num2str(dyn)])
    
end
end

