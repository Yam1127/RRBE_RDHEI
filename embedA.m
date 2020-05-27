%embedA子函数用于将隐秘信息比特流嵌入到非平滑块A的最低有效位
function W = embedA(A,d,index)
%函数的输入为已经分割好的非平滑块A；待嵌入隐秘信息比特流；index即T1Ind，用于标记是否需要多轮嵌入
%函数的输出为嵌入了隐秘信息比特流的A块

%============================变量清单======================================
%h:非平滑块A的行数   w:非平滑块A的列数
%index：RRBE函数中的T1Ind，用于标记是否需要多轮嵌入
%m:记录块A中原本像素的最低有效位
%d：待嵌入的隐秘信息比特流
%W：嵌入了隐秘信息比特流之后的块A

%=============================LSB替换======================================
[h,w] = size(A);
if ~index %检测是否需要多轮嵌入
    m = mod(A,2);
    m = m(:); %读取块A中像素的原始最低有效位
    W = A(:);  %转成列向量，方便运算
    W(1:length(d)) = W(1:length(d)) - m(1:length(d)) + d;  % LSB替换 
else
    m1 = mod(A,2);
    m2 = mod(floor(A/2),2);
    m1 = m1(:);
    m2 = m2(:);
    W = A(:);
    if length(m1) > length(d)  %待嵌入隐秘信息长度短于m1的长度
        W(1:length(d)) = W(1:length(d)) - m1(1:length(d)) + d;  % LSB替换 
    else   %待嵌入隐秘信息长度长于m1的长度
        W = W - m1 + d(1:length(m1));  
        L = length(d) - length(m1);
        W(1:L) = W(1:L) - 2 * m2(1:L) + 2 * d(length(m1) + 1:end);   % LSB替换 
    end
end
W = reshape(W,h,w); %重新排列矩阵中元素的位置，调整矩阵的大小。reshape函数将返回一个h*w的矩阵

save embedA.mat; %保存子函数embedA中的变量






