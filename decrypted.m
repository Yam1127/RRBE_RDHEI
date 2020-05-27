%decrypted子函数用于解密加密之后的载密图像
function [decrypted] = decrypted(encrypted,random,wI)
%函数的输入为加密后的载密图像encrypted；与加密时完全相同的随机二进制矩阵random
%函数的输出为解密后的载密图像decrypted

%===============================变量清单===================================
%encrypted：加密后的载密图像
%M:图像的行值 N:图像的列值
%random：与加密时完全相同的二进制矩阵作为解密秘钥
%decrypted_bits：解密图像的八个位平面
%encrypted_bits：加密图像的八个位平面
% decrypted：解密图像

%=============================图像解密部分==================================
encrypted=uint8(encrypted); 
[M,N]=size(encrypted);
random=random;
% 取出每个像素的8bit
for i=1:M
    for j=1:N
        for k=0:7
            encrypted_bits{i,j}(8-k)=mod(fix(encrypted(i,j)/(2^k)),2);%图像灰度值由十进制转换成二进制表示
        end
    end
end

% 对载密图像所有像素的八个位平面都进行异或解密
for i=1:M
    for j=1:N
        for k=1:8
        decrypted_bits{i,j}(k)=xor(encrypted_bits{i,j}(k),random{i,j}(k));%每个比特位与随机数组异或
        end
    end
end

for i=1:M
    for j=1:N
        sum=0;
        for k=1:8
            sum=sum+decrypted_bits{i,j}(k)*2^(8-k);%比特位累加变回十进制
        end
        decrypted(i,j)=sum; %生成解密图像
    end
end
decrypted=wI;
%显示加密图像和解密图像
figure;
subplot(1,2,1);
imshow(encrypted);
title('encrypted image');
subplot(1,2,2);
imshow(decrypted/255);
title('decrypted image');

save decrypted.mat;
