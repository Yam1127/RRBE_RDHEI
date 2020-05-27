%imgPartition�Ӻ�������ѡ����ƽ����A��ƽ����B

function [finalA,finalB,index] = imgPartition(I,H)
%��������Ϊ����ͼ��I���������õķ�ƽ����A������H
%�������Ϊ���շָ����ƽ����A�ͷ�ƽ����B

%============================�����嵥======================================
%I:ԭʼ����ͼ��
%m:����ͼ�����ֵ  n:����ͼ�����ֵ
%N���ֿ�ĸ���
%H:�������õķ�ƽ����A������
%f:ÿ�����ƽ����
%val:��ʱ������ÿ�����ص�ƽ����
%A����ʱ��������ǰ����ƽ���ȵĿ�
%index������ָ���ƽ����A����ʼ����
%finalA:���շָ�����ķ�ƽ����A
%finalB:���շָ������ƽ����B

%=========================����ÿ�����ƽ����f===============================
I = round(I);
[m,n] = size(I); %��ȡ����ͼ����ֵ����ֵ
N = m - H + 1; %����ֿ����
f = zeros(N,1); %��ʼ��ÿ�����ƽ����

%��ÿ�������ƽ����f
for i = 1:N 
    A = I(i: i - 1 + H,1:n); %���ֵ�ǰ����ķֿ�
    [h,w] = size(A); %��ȡ�����ֵ����ֵ
    for j = 1:h
        for k = 1:w
            if h == 1          %��ǰ�ֿ�ֻ��һ��
                if j == 1 && k == 1                  %���ж�������
                    val = abs( A(j,k) - (A(j,k+1))/1);
                elseif j == 1 && k == w
                    val = abs( A(j,k) - (A(j,k-1))/1 );
                else
                    val = abs( A(j,k) - (A(j,k-1) + A(j,k+1))/2 );
                end
            else
                if j == 1 && k == 1                  %���ж�������
                    val = abs( A(j,k) - (A(j+1,k) + A(j,k+1))/2 );
                elseif j == 1 && k == w
                    val = abs( A(j,k) - (A(j+1,k) + A(j,k-1))/2 );                
                elseif j == h && k == 1
                    val = abs( A(j,k) - (A(j-1,k) + A(j,k+1))/2 );
                elseif j == h && k == w
                    val = abs( A(j,k) - (A(j-1,k) + A(j,k-1))/2 );
                elseif j == 1                        %���зǶ����Ե����
                    val = abs( A(j,k) - (A(j+1,k) + A(j,k+1) + A(j,k-1))/3 );
                elseif j == h
                    val = abs( A(j,k) - (A(j-1,k) + A(j,k+1) + A(j,k-1))/3 );
                elseif k == 1
                    val = abs( A(j,k) - (A(j-1,k) + A(j+1,k) + A(j,k+1))/3 );
                elseif k == w
                    val = abs( A(j,k) - (A(j-1,k) + A(j+1,k) + A(j,k-1))/3 );
                else                                 %���зǱ�Ե����
                    val = abs( A(j,k) - (A(j-1,k) + A(j+1,k) + A(j,k-1) + A(j,k+1))/4 );
                end
            end
            f(i) = f(i) + val; %�ۼӿ����������أ��õ��ÿ��ƽ����f
        end
    end
    f(i) = f(i)/( h*w );
end
[~,index] = max(f);  %��ѡ�����п���fֵ����ƽ���Ŀ顣indexָ���ƽ�����λ��

%=========================�ָ��ƽ����ͷ�ƽ����============================
if index == N %��ƽ����Ϊ���һ����
    finalA =  I(index : end, 1:n);
    finalB = I(1: index - 1, 1:n);
elseif index == 1 %��ƽ����Ϊ��һ����
    finalA = I(index : index + H -1 , 1:n);
    finalB = I(index + H : end, 1:n);
else  %finalAΪ�ָ���ķ�ƽ���飬finalBΪ�ָ����ƽ����
    finalA = I(index : index + H -1, 1:n);
    finalB = [I(1:index -1, 1:n);
         I(index + H : end, 1:n)];
end
        
    
    
                
                
            


