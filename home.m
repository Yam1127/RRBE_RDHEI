%此函数用于在平滑块B中提取非平滑块A的最低有效位，并还原原始载体图像

function[restore]=home(decrypted,embedRate,AInd,A,m)
%函数的输入为解密之后的载密图像decrypted，嵌入率embedRate，非平滑块A的起始行数AInd,以及隐秘信息的长度m
%函数的输出为还原的原始载体图像restore

%============================变量清单======================================
%decrypted:解密之后的载密图像
%h:decrypted的行数  w:decrypted的列数
%embedRate:嵌入率
%dataLength：隐秘信息的长度
%AHeight：非平滑块A的行数
%N：分块的个数
%index：指向非平滑块A的起始行数
%AInd：非平滑块A的起始行数
%finalA:分割出的非平滑块A
%finalB:分割出的平滑块B
%pixelFlag：用于标记选中的白色像素或黑色像素
%BW：B块中黑白像素区域
%B：还原的黑白像素区域
%LSB：提取出的A块的最低有效位
%restore_image：还原出的原始图像
%LN：预测误差直方图的左零点
%LM：预测误差直方图的左峰值点
%RM：预测误差直方图的右峰值点
%RN：预测误差直方图的右零值点
%val：临时变量，待预测像素实际的灰度值
%C：待预测像素和周围像素组成的分块
%x_mean：待预测像素上下左右四个方向上的像素的灰度值的均值
%xe_0：待预测像素左右两侧像素灰度值的均值
%xe_90：待预测像素上下两侧像素灰度值的均值
%sigma_0：待预测像素上中下三个像素灰度值的方差
%sigma_90：待预测像素左中右三个像素灰度值的方差
%w_0，w_90：两个方向上的权重
%pred：像素的灰度预测值
%e:像素的预测误差

%============================读取图像 计算分块大小==========================
I=double(decrypted);
[h,w]= size(I);%读取解密后的载密图像和其行值列值
dataLength = embedRate * h * w; %计算嵌入隐秘比特流的长度
AHeight = ceil(dataLength/w); %计算非平滑块的行数
H=AHeight; 
N = h - H + 1; %计算分块个数
index=AInd; %读取非平滑块的起始行数
%=========================分割出平滑块和非平滑块============================
if index == N %非平滑块为最后一个块
    finalA =  I(index : end, 1:w);
    finalB = I(1: index - 1, 1:w);
elseif index == 1 %非平滑块为第一个块
    finalA = I(index : index + H -1 , 1:w);
    finalB = I(index + H : end, 1:w);
else  %finalA为分割出的非平滑块，finalB为分割出的平滑块
    finalA = I(index : index + H -1, 1:w);
    finalB = [I(1:index -1, 1:w);
         I(index + H : end, 1:w)];
end
pixelFlag = 0; % 用于标记白色像素或者黑色像素，pixelFlag = 0时选中白色像素
[diffHist, LN, LM, RN, RM] = histGen(finalB,pixelFlag);  
LSB=zeros();%lsb=m;restore=lsb;
[m,n]=size(finalB);
BW=finalB(2:m-1,2:n-1);
B=finalB(2:m-1,2:n-1);
%对黑白像素块的每个像素计算预测误差得到预测误差直方图，得到直方图的左右峰值点
count=1;
%从第二行第二列开始，计算每个白色像素的预测误差e
for i=2:m-1
    for j=2:n-1
            if mod(i+j,2) == pixelFlag  %选中白色像素
            val=BW(i-1,j-1); %val为实际像素的灰度值
            C = finalB(i-1:i+1,j-1:j+1); %待预测像素和周围像素组成的分块
            x_mean = 0.25 * ( C(2,1) + C(2,3) + C(1,2) + C(3,2) );
            %待预测像素上下左右四个方向上的像素的灰度值的均值
            xe_0 = 0.5 * ( C(2,1) + C(2,3) );
            %待预测像素左右两侧像素灰度值的均值
            xe_90 = 0.5 * ( C(1,2) + C(3,2) );
            %待预测像素上下两侧像素灰度值的均值
            S_0 = [ C(2,1) C(2,3) xe_0 ];
            S_90= [ C(1,2) C(3,2) xe_90 ];
            sigma_0 = 1/3 * sum( (S_0-x_mean).^2 );
            %待预测像素上中下三个像素灰度值的方差
            sigma_90 = 1/3 * sum( (S_90-x_mean).^2 );
             %待预测像素左中右三个像素灰度值的方差
            w_0 = sigma_90 / ( sigma_0 + sigma_90 + 1e-6 );
            w_90 = sigma_0 / ( sigma_0 + sigma_90 + 1e-6 );%计算两个方向上的权重
            pred = round( w_0 * xe_0 + w_90 * xe_90 ); %计算像素灰度值的预测值
            e_decrypted(i,j) = val - pred; %计算误差
%====================提取自嵌入过程中嵌入的块A的最低有效位===================           
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
            e_decrypted = val - pred; %计算误差    
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





