%encrypted子函数用于对载密图像进行流密码加密
function [encrypted,random] = encrypted(wI)
%函数输入为预处理完嵌入了隐秘信息的载密图像wI
%函数输出为流密码加密之后的图像encrypted;和随机加密秘钥random

%===============================变量清单===================================
%wI：经过预处理和嵌入额外隐秘信息之后的载密图像
%M:载密图像的行值 N:载密图像的列值
%random：随机生成的二进制秘钥
%original_bits：载密图像的八个位平面
%encrypted_bits：加密后图像的八个位平面
%encrypted：加密后的载密图像

%=============================图像加密部分==================================
original=uint8(wI); %预处理之后的图像作为原始载体图像
[M,N]=size(original); %读取行值M，纵值N
%生成与图像大小相同的随机二进制秘钥
for i=1:M
for j=1:N
  random{i,j}=round(rand(1,8));
end
end

% 取出每个像素的8bit
for i=1:M
    for j=1:N
        for k=0:7
            original_bits{i,j}(8-k)=mod(fix(original(i,j)/(2^k)),2);%图像灰度值由十进制转换成二进制表示
        end
    end
end

% 对载密图像所有像素的八个位平面都进行异或加密
for i=1:M
    for j=1:N
        for k=1:8
        encrypted_bits{i,j}(k)=xor(original_bits{i,j}(k),random{i,j}(k));%每个比特位与随机数组异或
        end
    end
end

for i=1:M
    for j=1:N
        sum=0;
        for k=1:8
            sum=sum+encrypted_bits{i,j}(k)*2^(8-k);%比特位累加变回十进制
        end
        encrypted(i,j)=sum; %生成加密图像
    end
end
 
%显示载体图像与加密图像
figure;
subplot(1,2,1);
imshow(original);
title('wI');
subplot(1,2,2);
imshow(encrypted,[]);
title('Encrypted Image');
