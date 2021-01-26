function [acs] = sg_shifter(m,n,acs)

slice_R = 5;
PE_R = 2;

rssq = @(x) squeeze(sum(abs(x).^2,3)).^(1/2);

ACS_1 = squeeze(acs(:,:,:,1));
ACS_2 = squeeze(acs(:,:,:,2));
ACS_3 = squeeze(acs(:,:,:,3));
ACS_4 = squeeze(acs(:,:,:,4));
ACS_5 = squeeze(acs(:,:,:,5));

[mm,nn,no_c] = size(ACS_1);


 acsdim1 = 1;
 acsdim2 = 16;


ACS1_kspace = zeros(m,n,no_c,'single');
ACS1_kspace(acsdim1:end,acsdim2:acsdim2+nn-1,:) = ACS_1;
ACS1_kspace = circshift(ACS1_kspace,[0 0 0]);
c = sum(abs((ACS1_kspace(:,:,:))),3);
mc = max(c(:));
[c1,c2] = find(c==mc);
ACS2_kspace = zeros(m,n,no_c,'single');
ACS2_kspace(acsdim1:end,acsdim2:acsdim2+nn-1,:) = ACS_2;
ACS2_kspace = circshift(ACS2_kspace,[0 0 0]);
c = sum(abs(squeeze(ACS2_kspace(:,:,:))),3);
mc = max(c(:));
[c1,c2] = find(c==mc);
ACS3_kspace = zeros(m,n,no_c,'single');
ACS3_kspace(acsdim1:end,acsdim2:acsdim2+nn-1,:) = ACS_3;
ACS3_kspace = circshift(ACS3_kspace,[0 0 0]);
c = sum(abs(squeeze(ACS3_kspace(:,:,:))),3);
mc = max(c(:));
[c1,c2] = find(c==mc);
ACS4_kspace = zeros(m,n,no_c,'single');
ACS4_kspace(acsdim1:end,acsdim2:acsdim2+nn-1,:) = ACS_4;
ACS4_kspace = circshift(ACS4_kspace,[0 0 0]);
c = sum(abs(squeeze(ACS4_kspace(:,:,:))),3);
mc = max(c(:));
[c1,c2] = find(c==mc);
ACS5_kspace = zeros(m,n,no_c,'single');
ACS5_kspace(acsdim1:end,acsdim2:acsdim2+nn-1,:) = ACS_5;
ACS5_kspace = circshift(ACS5_kspace,[0 0 0]);
c = sum(abs(squeeze(ACS5_kspace(:,:,:))),3);
mc = max(c(:));
[c1,c2] = find(c==mc);



phases = exp(sqrt(-1)*pi*(0:n-1));
phas = 1;%repmat(phases,[m 1 no_c]);
ACS1 = ACS1_kspace.* phas;
ACS2 = ACS2_kspace.* phas;
ACS3 = ACS3_kspace.* phas;
ACS4 = ACS4_kspace.* phas;
ACS5 = ACS5_kspace.* phas;
%phases2 = (exp(sqrt(-1)*(pi+(4*pi/m))*(0:m-1))).';
phases2 = (exp(sqrt(-1)*(pi)*(0:m-1))).';%% intentionally add 2*pi/m for 1 pixel shift
%% if you want you can uncomment the line below and see what happens
% phases2 = (exp(sqrt(-1)*(pi)*(0:m-1))).';
phas2 = 1;%repmat(phases2,[1 n no_c]);
ACS11 = ACS1 .* phas2;
ACS22 = ACS2 .* phas2;
ACS33 = ACS3 .* phas2;
ACS44 = ACS4 .* phas2;
ACS55 = ACS5 .* phas2;

%%shift the ACS by hand
[m,n,no_c] = size(ACS11);
phases = exp(sqrt(-1)*0*2*pi/3*(0:n-1));
phas = repmat(phases,[m 1 no_c]);
ACS11 = ACS11 .* phas;

[m,n,no_c] = size(ACS22);
phases = exp(sqrt(-1)*-1*2*pi/3*(0:n-1));
phas = repmat(phases,[m 1 no_c]);
ACS22 = ACS22 .* phas;

[m,n,no_c] = size(ACS33);
phases = exp(sqrt(-1)*-2*2*pi/3*(0:n-1));
phas = repmat(phases,[m 1 no_c]);
ACS33 = ACS33 .* phas;

[m,n,no_c] = size(ACS44);
phases = exp(sqrt(-1)*0*2*pi/3*(0:n-1));
phas = repmat(phases,[m 1 no_c]);
ACS44 = ACS44 .* phas;

[m,n,no_c] = size(ACS55);
phases = exp(sqrt(-1)*-1*2*pi/3*(0:n-1));
phas = repmat(phases,[m 1 no_c]);
ACS55 = ACS55 .* phas;

%% restore the zero padding
ACS1_final = ACS11(acsdim1:end,acsdim2:acsdim2+nn-1,:); 
ACS2_final = ACS22(acsdim1:end,acsdim2:acsdim2+nn-1,:);
ACS3_final = ACS33(acsdim1:end,acsdim2:acsdim2+nn-1,:);
ACS4_final = ACS44(acsdim1:end,acsdim2:acsdim2+nn-1,:);
ACS5_final = ACS55(acsdim1:end,acsdim2:acsdim2+nn-1,:);


% save('inital_ind','ACS1_final','ACS2_final','ACS3_final','ACS4_final','ACS5_final','-v7.3')

acs(:,:,:,1) = ACS1_final;
acs(:,:,:,2) = ACS2_final;
acs(:,:,:,3) = ACS3_final;
acs(:,:,:,4) = ACS4_final;
acs(:,:,:,5) = ACS5_final;

end

