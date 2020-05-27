%encrypted�Ӻ������ڶ�����ͼ��������������
function [encrypted,random] = encrypted(wI)
%��������ΪԤ������Ƕ����������Ϣ������ͼ��wI
%�������Ϊ���������֮���ͼ��encrypted;�����������Կrandom

%===============================�����嵥===================================
%wI������Ԥ�����Ƕ�����������Ϣ֮�������ͼ��
%M:����ͼ�����ֵ N:����ͼ�����ֵ
%random��������ɵĶ�������Կ
%original_bits������ͼ��İ˸�λƽ��
%encrypted_bits�����ܺ�ͼ��İ˸�λƽ��
%encrypted�����ܺ������ͼ��

%=============================ͼ����ܲ���==================================
original=uint8(wI); %Ԥ����֮���ͼ����Ϊԭʼ����ͼ��
[M,N]=size(original); %��ȡ��ֵM����ֵN
%������ͼ���С��ͬ�������������Կ
for i=1:M
for j=1:N
  random{i,j}=round(rand(1,8));
end
end

% ȡ��ÿ�����ص�8bit
for i=1:M
    for j=1:N
        for k=0:7
            original_bits{i,j}(8-k)=mod(fix(original(i,j)/(2^k)),2);%ͼ��Ҷ�ֵ��ʮ����ת���ɶ����Ʊ�ʾ
        end
    end
end

% ������ͼ���������صİ˸�λƽ�涼����������
for i=1:M
    for j=1:N
        for k=1:8
        encrypted_bits{i,j}(k)=xor(original_bits{i,j}(k),random{i,j}(k));%ÿ������λ������������
        end
    end
end

for i=1:M
    for j=1:N
        sum=0;
        for k=1:8
            sum=sum+encrypted_bits{i,j}(k)*2^(8-k);%����λ�ۼӱ��ʮ����
        end
        encrypted(i,j)=sum; %���ɼ���ͼ��
    end
end
 
%��ʾ����ͼ�������ͼ��
figure;
subplot(1,2,1);
imshow(original);
title('wI');
subplot(1,2,2);
imshow(encrypted,[]);
title('Encrypted Image');
