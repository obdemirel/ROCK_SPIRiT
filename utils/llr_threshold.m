function x_new = llr_threshold(x, b1, b2, thr, thr_flag)

% x is the 3D image array
% [b1 b2] is the patch size, usually 8x8 or 4x4
% thr is the thresholding parameter (empirically tuned)
% thr_flag chooses hard thresholding of singular values (if set to 0) or soft
%                   thresholding of singular values (if set to 1)

% extract patches
[m, n, no_ims] = size(x);
A = zeros(b1*b2, (m-b1+1)*(n-b2+1), no_ims, 'single');
for ind = 1:no_ims
    A(:,:,ind) = im2col(x(:,:,ind), [b1 b2], 'sliding');
end
%Casorati matrices
A = permute(A, [1 3 2]);

%threshold
parfor ind = 1:size(A,3)
    A_sl = A(:,:,ind);
    [U, S, V] = svd(A_sl, 'econ');
    if thr_flag == 0
        S = S .* (S >= thr);
    elseif thr_flag == 1
        S = max(abs(S) - thr, 0);
    end
    A(:,:,ind) = U * S* V';
end
A = permute(A, [1 3 2]);

x_new = zeros(size(x), 'single');
indices = reshape(1:m*n, [m n]);
subs = im2col(indices, [b1 b2], 'sliding');
for ind = 1:no_ims
    vals = A(:,:,ind);
    result = accumarray(subs(:), vals(:))./ accumarray(subs(:),1);
    x_new(:,:,ind) = reshape(result, m,n);
end