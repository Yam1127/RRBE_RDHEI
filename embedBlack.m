%embedBlack子函数用于将块A中原本像素的最低有效位嵌入到B块的黑色像素中
function [W,payload,boundaryMap] = embedBlack(I,d,p)
%函数的输入为平滑块B；本次嵌入过程中要嵌入的块A像素的LSB位d；保存预测误差直方图峰值点零值点的矩阵p
%函数的输出为完成黑色像素嵌入的B块W；本次嵌入的有效嵌入位数payload；由于边界溢出的boundaryMap

%============================变量清单======================================
%I:平滑块B
%h:块B的行数   w:块B的列数
%LN：预测误差直方图的左零值点
%RN：预测误差直方图的右零值点
%LM：预测误差直方图的左峰值点
%RM：预测误差直方图的右峰值点
%C：待预测像素和周围像素组成的分块
%x_mean：待预测像素上下左右四个方向上的像素的灰度值的均值
%xe_0：待预测像素左右两侧像素灰度值的均值
%xe_90：待预测像素上下两侧像素灰度值的均值
%sigma_0：待预测像素上中下三个像素灰度值的方差
%sigma_90：待预测像素左中右三个像素灰度值的方差
%w_0，w_90：两个方向上的权重
%pred：像素的灰度预测值
%e：像素灰度值的预测误差
%val：像素实际的灰度值
%W:完成黑色像素嵌入的B块
%boundaryMap:记录边界溢出


%======================平移预测误差直方图嵌入黑色像素========================
[h,w] = size(I); %读取B块的行值和列值
LN = p(1); RN = p(4);
LM = p(2);  RM = p(3); %从输入中读取左右峰值点和左右零值点

boundaryMap = zeros(1000,1);
bmIndex = 0;
dataIndex = 0; 
W = I;  %初始化

for i = 2:h-1
    for j = 2:w-1    %从B块的第二行第二列开始计算黑色像素的预测误差
        if dataIndex < length(d) &&  mod(i+j,2)== 1  %选中黑色像素
        val = W(i,j); %val为黑色像素实际的灰度值
        if val==0 || val==255             %边界像素计入boundaryMap
            bmIndex = bmIndex + 1;
            boundaryMap(bmIndex) = 0; 
        else
            C = W(i-1:i+1,j-1:j+1);   %待预测黑色像素和周围像素组成的分块
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
            w_90 = sigma_0 / ( sigma_0 + sigma_90 + 1e-6 );  %计算两个方向上的权重
            pred = round( w_0 * xe_0 + w_90 * xe_90 );  %计算像素灰度值的预测值
            e = val - pred; %将实际像素的灰度值减去估计值得到预测误差
            % 嵌入过程
            if e==LM || e==RM   %如果该黑色像素的预测误差位于预测误差直方图额左右峰值点
                dataIndex = dataIndex + 1; 
                b = d(dataIndex);     
                if e==LM   %左边峰值点
                    e_new = e-b; %嵌入块A的LSB位
                else    %右边峰值点
                    e_new = e+b;  %嵌入块A的LSB位
                end              
            elseif  ( LN<e && e<LM ) || ( RM<e && e<RN )   %如果该黑色像素的预测误差不位于峰值点
                if LN<e && e<LM
                    e_new = e-1; %位于直方图左边，将预测误差向左平移
                else
                    e_new = e+1; %位于直方图右边，将预测误差向右平移
                end
            else           
                e_new = e;              
            end
            
            val_new = pred + e_new;  %将原本计算得到的预测灰度值加上平移之后的预测误差生成嵌入之后的灰度值
            W(i,j) = val_new; %生成自嵌入黑色像素之后的B块
            if val_new==0 || val_new==255 %如果嵌入之后的灰度值溢出，则计入boundaryMap
                bmIndex = bmIndex + 1;
                boundaryMap(bmIndex) = 1;   
            end             

        end 
        end
    end
end
payload = dataIndex; %计算本次嵌入过程中的有效嵌入位数
boundaryMap = boundaryMap(1:bmIndex); %输出boundaryMap



