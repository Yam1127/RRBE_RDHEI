%RRBE子函数用于完成明文载体图像的预处理以及将隐秘信息嵌入到载体图像中

function [wI,actualEmbedRate,PSNR,AInd,A,wB,AHeight,m] = RRBE(I,embedRate,T1,T2)
%函数输入为明文载体图像I；设置的嵌入率embedRate
%函数输出为嵌入了额外隐秘信息的载密图像wI；实际嵌入率actualEmbedRate；峰值信噪比PSNR

%============================变量清单======================================
%I：原始载体图像
%m:原始载体图像行值  n：原始载体图像列值
%embedRate：设定的嵌入率
%datalength:计算的载体能够嵌入的最大位数
%H：分块的行值
%N:分块的数量
%f:每块的平滑度
%index：索引，指到块A的位置
%finalA:不平滑块A
%finalB:平滑块B
%m:记录A块原始的LSB位
%embeddingRound：记录自嵌入的回合数
%payload:有效的自嵌入比特位数
%boundaryMap：自嵌入过程中未嵌入的溢出边界
%wB:嵌入了A块LSB的B块
%actualEmbedRate：实际嵌入率
%random{i,j}:加密随机密钥
%encrypted：加密图像
%data：嵌入的隐秘信息
%wA：嵌入了隐秘信息的A块
%wI：嵌入了隐秘信息的载密图像
%psnr:峰值信噪比

%====================判断函数的输入参数个数是否符合要求======================
if (nargin < 2 || nargin > 4) %输入参数不符合要求报错
   wI = -Inf;
   actualEmbedRate = -Inf;
   PSNR = -Inf;
   return;
end

if (nargin == 2)
    T1 = 0.25;
    T2 = 0.2; %T1和T2为先前实验计算出来的嵌入率，用于判断是否在嵌入和自嵌入过程中需要进行多轮嵌入
end

if (nargin == 3)
    T2 = 0.2;
end

%============================图像分割======================================
%读取载体图像
I = double(I); %将载体图像由unit8类型转换成double类型，方便后面的矩阵运算
[h,w]= size(I); %读取载体图像的像素行值和列值
dataLength = embedRate * h * w; %根据设定的嵌入率计算载体可嵌入的隐秘信息最大长度

%挑选出不平滑块A和平滑块B
if embedRate <= T1 %设定的嵌入率小于0.25，只需进行一轮嵌入
    T1Ind = false; %T1Ind用于标记是否需要多轮的嵌入
    AHeight = ceil(dataLength/w); %根据待嵌入隐秘信息的长度，设定块A的行数
    [A, B, AInd] = imgPartition(I, AHeight); % 调用imgPartition子函数，返还得到非平滑块A和平滑块B
else
    T1Ind = true; %需要进行多轮嵌入
    AHeight = ceil(dataLength/(w * 2));
    [A, B, AInd] = imgPartition(I, AHeight); 
end
save image_partition.mat; %保存图像分割部分的变量

%=====================将隐秘信息嵌入到块A的最低有效位========================
data = round(rand(dataLength,1));
%根据计算所得的载体可嵌入的隐秘信息最大长度，生成随机二进制序列，作为待嵌入的隐秘信息
wA = embedA(A,data,T1Ind); %调用embedA子函数，返回输出为嵌入了隐秘信息的A块
save wA.mat; %保存隐秘信息嵌入部分的变量

%===============================自嵌入=====================================
%提取块A中原始像素的最低有效位
if ~T1Ind  %检测是否需要进行多轮嵌入
    m = mod(A,2);
    m = m(:);
    m = m(1:dataLength); %m为提取出来的块A中原始像素的最低有效位
else 
    m1 = mod(A,2);
    m1 = m1(:);
    m2 = mod(floor(A/2),2);
    m2 = m2(:);
    m = [m1;m2];
    m = m(1:dataLength);
end 
embeddingRound = 1; %embeddingRound为记录自嵌入的回合数，每一轮自嵌入调用一次embedB子函数
fprintf('  Embedding round %d:\n ',embeddingRound); %显示当前的自嵌入回合数
[wB,payload,boundaryMap,multiInd]= embedB(B,m,T2); 
%调用embedB子函数，返还输出为完成自嵌入的B块wB；有效的嵌入比特位数payload;未嵌入的溢出边界boundaryMap

while multiInd  % 如果需要进行多轮嵌入
    embeddingRound = embeddingRound + 1; %自嵌入回合数加一
    fprintf(' Embedding round %d:\n ',embeddingRound); %显示当前的自嵌入回合数
    d = m(payload + 1:end);  %此时的d位未嵌入的A块中像素的原始最低有效位
    [wB,payload_m,boundaryMap_m,multiInd]= embedB(wB,d,T2); %再一次调用embedB子函数
    payload = payload + payload_m; %更新再一次嵌入之后的有效嵌入位数
    boundaryMap = [boundaryMap;boundaryMap_m];  %更新再一次自嵌入之后的未嵌入溢出边界boundaryMap
end
save wB.mat; %保存完成自嵌入的变量信息

%==================连接嵌入了隐秘信息的A块和自嵌入的B块======================
wI = catenate(wA,wB,AInd,AHeight);
%调用catenate子函数，返回输出为连接了A块和B块的载密图像
save wI.mat; %保存载密图像的变量信息

%==========================计算峰值信噪比PSNR===============================
PSNR = psnr(I,wI); %调用PSNR子函数，计算载体图像的保真度
actualEmbedRate = payload /(h*w) ; %计算实际嵌入率actualEmbedRate 
    
    

    





