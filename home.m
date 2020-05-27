%�˺���������ƽ����B����ȡ��ƽ����A�������Чλ������ԭԭʼ����ͼ��

function[restore]=home(decrypted,embedRate,AInd,A,m)
%����������Ϊ����֮�������ͼ��decrypted��Ƕ����embedRate����ƽ����A����ʼ����AInd,�Լ�������Ϣ�ĳ���m
%���������Ϊ��ԭ��ԭʼ����ͼ��restore

%============================�����嵥======================================
%decrypted:����֮�������ͼ��
%h:decrypted������  w:decrypted������
%embedRate:Ƕ����
%dataLength��������Ϣ�ĳ���
%AHeight����ƽ����A������
%N���ֿ�ĸ���
%index��ָ���ƽ����A����ʼ����
%AInd����ƽ����A����ʼ����
%finalA:�ָ���ķ�ƽ����A
%finalB:�ָ����ƽ����B
%pixelFlag�����ڱ��ѡ�еİ�ɫ���ػ��ɫ����
%BW��B���кڰ���������
%B����ԭ�ĺڰ���������
%LSB����ȡ����A��������Чλ
%restore_image����ԭ����ԭʼͼ��
%LN��Ԥ�����ֱ��ͼ�������
%LM��Ԥ�����ֱ��ͼ�����ֵ��
%RM��Ԥ�����ֱ��ͼ���ҷ�ֵ��
%RN��Ԥ�����ֱ��ͼ������ֵ��
%val����ʱ��������Ԥ������ʵ�ʵĻҶ�ֵ
%C����Ԥ�����غ���Χ������ɵķֿ�
%x_mean����Ԥ���������������ĸ������ϵ����صĻҶ�ֵ�ľ�ֵ
%xe_0����Ԥ�����������������ػҶ�ֵ�ľ�ֵ
%xe_90����Ԥ�����������������ػҶ�ֵ�ľ�ֵ
%sigma_0����Ԥ�������������������ػҶ�ֵ�ķ���
%sigma_90����Ԥ�������������������ػҶ�ֵ�ķ���
%w_0��w_90�����������ϵ�Ȩ��
%pred�����صĻҶ�Ԥ��ֵ
%e:���ص�Ԥ�����

%============================��ȡͼ�� ����ֿ��С==========================
I=double(decrypted);
[h,w]= size(I);%��ȡ���ܺ������ͼ�������ֵ��ֵ
dataLength = embedRate * h * w; %����Ƕ�����ر������ĳ���
AHeight = ceil(dataLength/w); %�����ƽ���������
H=AHeight; 
N = h - H + 1; %����ֿ����
index=AInd; %��ȡ��ƽ�������ʼ����
%=========================�ָ��ƽ����ͷ�ƽ����============================
if index == N %��ƽ����Ϊ���һ����
    finalA =  I(index : end, 1:w);
    finalB = I(1: index - 1, 1:w);
elseif index == 1 %��ƽ����Ϊ��һ����
    finalA = I(index : index + H -1 , 1:w);
    finalB = I(index + H : end, 1:w);
else  %finalAΪ�ָ���ķ�ƽ���飬finalBΪ�ָ����ƽ����
    finalA = I(index : index + H -1, 1:w);
    finalB = [I(1:index -1, 1:w);
         I(index + H : end, 1:w)];
end
pixelFlag = 0; % ���ڱ�ǰ�ɫ���ػ��ߺ�ɫ���أ�pixelFlag = 0ʱѡ�а�ɫ����
[diffHist, LN, LM, RN, RM] = histGen(finalB,pixelFlag);  
LSB=zeros();%lsb=m;restore=lsb;
[m,n]=size(finalB);
BW=finalB(2:m-1,2:n-1);
B=finalB(2:m-1,2:n-1);
%�Ժڰ����ؿ��ÿ�����ؼ���Ԥ�����õ�Ԥ�����ֱ��ͼ���õ�ֱ��ͼ�����ҷ�ֵ��
count=1;
%�ӵڶ��еڶ��п�ʼ������ÿ����ɫ���ص�Ԥ�����e
for i=2:m-1
    for j=2:n-1
            if mod(i+j,2) == pixelFlag  %ѡ�а�ɫ����
            val=BW(i-1,j-1); %valΪʵ�����صĻҶ�ֵ
            C = finalB(i-1:i+1,j-1:j+1); %��Ԥ�����غ���Χ������ɵķֿ�
            x_mean = 0.25 * ( C(2,1) + C(2,3) + C(1,2) + C(3,2) );
            %��Ԥ���������������ĸ������ϵ����صĻҶ�ֵ�ľ�ֵ
            xe_0 = 0.5 * ( C(2,1) + C(2,3) );
            %��Ԥ�����������������ػҶ�ֵ�ľ�ֵ
            xe_90 = 0.5 * ( C(1,2) + C(3,2) );
            %��Ԥ�����������������ػҶ�ֵ�ľ�ֵ
            S_0 = [ C(2,1) C(2,3) xe_0 ];
            S_90= [ C(1,2) C(3,2) xe_90 ];
            sigma_0 = 1/3 * sum( (S_0-x_mean).^2 );
            %��Ԥ�������������������ػҶ�ֵ�ķ���
            sigma_90 = 1/3 * sum( (S_90-x_mean).^2 );
             %��Ԥ�������������������ػҶ�ֵ�ķ���
            w_0 = sigma_90 / ( sigma_0 + sigma_90 + 1e-6 );
            w_90 = sigma_0 / ( sigma_0 + sigma_90 + 1e-6 );%�������������ϵ�Ȩ��
            pred = round( w_0 * xe_0 + w_90 * xe_90 ); %�������ػҶ�ֵ��Ԥ��ֵ
            e_decrypted(i,j) = val - pred; %�������
%====================��ȡ��Ƕ�������Ƕ��Ŀ�A�������Чλ===================           
        if  mod(i+j,2)== 0 && e_decrypted(i,j)==RM 
            LSB(count,1)=0;
            B(i,j)=BW(i-1,j-1);
            count=count+1;        
        elseif mod(i+j,2)== 0 && e_decrypted(i,j)==(RM+1)
            LSB(count,1)=1;
            B(i,j)=BW(i-1,j-1)-1;
            count=count+1;           
        elseif mod(i+j,2)==0 &&e_decrypted(i,j)>(RM+1)
            B(i,j)=BW(i-1,j-1)-1;
                   
        elseif mod(i+j,2)==0 &&e_decrypted(i,j)==LM
            LSB(count,1)=0;
            B(i,j)=BW(i-1,j-1);
            count=count+1;           
        elseif mod(i+j,2)==0 &&e_decrypted(i,j)==(LM-1)
            LSB(count,1)=1;
            B(i,j)=BW(i-1,j-1)+1;
            count=count+1;           
        elseif mod(i+j,2)==0 &&e_decrypted(i,j)<(LM-1)
            B(i,j)=BW(i-1,j-1)+1;
        end
            end
   end
end

if   pixelFlag ==1;
  for i=2:m-1
    for j=2:n-1
            val=BW(i-1,j-1);
            C = finalB(i-1:i+1,j-1:j+1);
            x_mean = 0.25 * ( C(2,1) + C(2,3) + C(1,2) + C(3,2) );
            xe_0 = 0.5 * ( C(2,1) + C(2,3) );
            xe_90 = 0.5 * ( C(1,2) + C(3,2) );
            S_0 = [ C(2,1) C(2,3) xe_0 ];
            S_90= [ C(1,2) C(3,2) xe_90 ];
            sigma_0 = 1/3 * sum( (S_0-x_mean).^2 );
            sigma_90 = 1/3 * sum( (S_90-x_mean).^2 );
            w_0 = sigma_90 / ( sigma_0 + sigma_90 + 1e-6 );
            w_90 = sigma_0 / ( sigma_0 + sigma_90 + 1e-6 );
            pred = round( w_0 * xe_0 + w_90 * xe_90 );
            e_decrypted = val - pred; %�������    
        if  mod(i+j,2)==1 && e_decrypted==RM
            LSB(i,j)=0;
            B(i,j)=BW(i-1,j-1);
                        
        elseif mod(i+j,2)==1 && e_decrypted==(RM+1)
            LSB(i,j)=1;
            B(i,j)=BW(i-1,j-1)-1;
                      
        elseif mod(i+j,2)==1 &&e_decrypted>(RM+1)
            B(i,j)=BW(i-1,j-1)-1;
            
        elseif mod(i+j,2)==1 &&e_decrypted==LM
            LSB(i,j)=0;
            B(i,j)=BW(i-1,j-1);
                       
        elseif mod(i+j,2)==1 &&e_decrypted==(LM-1)
            LSB(i,j)=1;
            B(i,j)=BW(i-1,j-1)+1;
                        
        elseif mod(i+j,2)==1 &&e_decrypted<(LM-1)
            B(i,j)=BW(i-1,j-1)+1;
            
        end
     end
   end
end

for i=1:m
        restore_B(i,1)=finalB(i,1);
end
for j=1:n
    restore_B(1,j)=finalB(1,j);
end
for i=2:m-1
    for j=2:n-1
        restore_B(i,j)=B(i,j);
    end
end
restore_image=catenate(A,restore_B,AInd,AHeight);
figure;
imshow(restore_image,[]);
title('restore image');
save home.mat;





