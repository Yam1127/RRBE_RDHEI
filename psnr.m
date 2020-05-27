%此函数用于计算图像的峰值信噪比
function PSNR = psnr(I,W)
%函数的输入为原始载体图像I；载密图像W
%函数的输出为载密图像的峰值信噪比PSNR

[m,n] = size(I);
[h,w] = size(W);
if m ~= h && n ~= w
    error('Two images must have the same size.')
end
delta = 1/(m*n) * sum( ( I(:) - W(:) ).^2 );
PSNR = 10 * log10( 255^2/delta );