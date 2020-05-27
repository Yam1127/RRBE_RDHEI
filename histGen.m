%histGen子函数用于生成平滑块B的预测误差直方图
function [hist, LN, LM, RN, RM,e] = histGen(I,pixelFlag)
%函数的输入为B平滑块I；用于标记选中的是白色像素还是黑色像素的pixelFlag（pixelFlag=0代表选中的是白色像素）
%函数的输出为B块的预测误差直方图hist；直方图的左峰值点LM；左零值点LN；右峰值点RM；右零值点RN

%============================变量清单======================================
%hist：预测误差序列
%h:B块的行数  w：B块的列数
%pixelFlag：用于标记选中的是白色像素还是黑色像素
%C：待预测像素和周围像素组成的分块
%x_mean：待预测像素上下左右四个方向上的像素的灰度值的均值
%xe_0：待预测像素左右两侧像素灰度值的均值
%xe_90：待预测像素上下两侧像素灰度值的均值
%sigma_0：待预测像素上中下三个像素灰度值的方差
%sigma_90：待预测像素左中右三个像素灰度值的方差
%w_0，w_90：两个方向上的权重
%pred：像素的灰度预测值
%delta：像素灰度值的预测误差
%val：像素实际的灰度值
%LM：预测误差直方图的左峰值点    LN:预测误差直方图的左零值点
%RM：预测误差直方图的右峰值点    RN：预测误差直方图的右零值点

%=======================计算像素的预测误差==================================
hist = zeros(511,1);
start = 256; %初始化预测误差序列

[h,w] = size(I); %读取块B的行值和列值

for i=2:h-1 
    for j=2:w-1  %从块B的第二行第二列开始计算像素灰度值的预测误差
        if mod(i+j,2) == pixelFlag 
        %若pixelFlag=0，则利用每个白色像素的灰度值对周围的黑色像素进行估计
        %若pixelFlag=1，则利用每个黑色像素的灰度值对周围的白色像素进行估计
            val = I(i,j); %val为实际像素的灰度值
            C = I(i-1:i+1,j-1:j+1); %待预测像素和周围像素组成的分块
            x_mean = 0.25 * ( C(2,1) + C(2,3) + C(1,2) + C(3,2) );
            %待预测像素上下左右四个方向上的像素的灰度值的均值
            xe_0 = 0.5 * ( C(2,1) + C(2,3) );
            %待预测像素左右两侧像素灰度值的均值
            xe_90 = 0.5 * ( C(1,2) + C(3,2) );
            %待预测像素上下两侧像素灰度值的均值
            S_0 = [ C(2,1) C(2,3) xe_0 ];
            S_90= [ C(1,2) C(3,2) xe_90 ];
            sigma_0 = 1/3 * sum( (S_0-x_mean).^2 ); %待预测像素上中下三个像素灰度值的方差
            sigma_90 = 1/3 * sum( (S_90-x_mean).^2 ); %待预测像素左中右三个像素灰度值的方差
            w_0 = sigma_90 / ( sigma_0 + sigma_90 + 1e-6 ); 
            w_90 = sigma_0 / ( sigma_0 + sigma_90 + 1e-6 ); %计算两个方向上的权重
            pred = round( w_0 * xe_0 + w_90 * xe_90 ); %计算像素灰度值的预测值
            delta = val - pred;  %将实际像素的灰度值减去估计值得到预测误差
            e(i,j)=delta;
            hist(delta+start) = hist(delta+start) + 1;   %生成预测误差序列                
        end
    end
end

%==================找到预测误差直方图的左右峰值点和零值点====================
[~,sortIndex]=sort(hist);
LM = sortIndex(511) - start;   
RM = sortIndex(510) - start;

if LM > RM   %比较LM和RM
    temp = LM;
    LM = RM;
    RM = temp;
end

i = LM + start;
while hist(i) ~= 0
    i = i-1;
end
LN = i - start;   

     
i = RM + start;
while hist(i) ~= 0
    i = i+1;
end
RN = i - start;        

save histGen.mat; %保存histGen子函数中的变量信息





