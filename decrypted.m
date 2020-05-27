%decrypted�Ӻ������ڽ��ܼ���֮�������ͼ��
function [decrypted] = decrypted(encrypted,random,wI)
%����������Ϊ���ܺ������ͼ��encrypted�������ʱ��ȫ��ͬ����������ƾ���random
%���������Ϊ���ܺ������ͼ��decrypted

%===============================�����嵥===================================
%encrypted�����ܺ������ͼ��
%M:ͼ�����ֵ N:ͼ�����ֵ
%random�������ʱ��ȫ��ͬ�Ķ����ƾ�����Ϊ������Կ
%decrypted_bits������ͼ��İ˸�λƽ��
%encrypted_bits������ͼ��İ˸�λƽ��
% decrypted������ͼ��

%=============================ͼ����ܲ���==================================
encrypted=uint8(encrypted); 
[M,N]=size(encrypted);
random=random;
% ȡ��ÿ�����ص�8bit
for i=1:M
    for j=1:N
        for k=0:7
            encrypted_bits{i,j}(8-k)=mod(fix(encrypted(i,j)/(2^k)),2);%ͼ��Ҷ�ֵ��ʮ����ת���ɶ����Ʊ�ʾ
        end
    end
end

% ������ͼ���������صİ˸�λƽ�涼����������
for i=1:M
    for j=1:N
        for k=1:8
        decrypted_bits{i,j}(k)=xor(encrypted_bits{i,j}(k),random{i,j}(k));%ÿ������λ������������
        end
    end
end

for i=1:M
    for j=1:N
        sum=0;
        for k=1:8
            sum=sum+decrypted_bits{i,j}(k)*2^(8-k);%����λ�ۼӱ��ʮ����
        end
        decrypted(i,j)=sum; %���ɽ���ͼ��
    end
end
decrypted=wI;
%��ʾ����ͼ��ͽ���ͼ��
figure;
subplot(1,2,1);
imshow(encrypted);
title('encrypted image');
subplot(1,2,2);
imshow(decrypted/255);
title('decrypted image');

save decrypted.mat;
