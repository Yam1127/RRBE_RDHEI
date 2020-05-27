%extract子函数用于从解密之后的载密图像之中提取出嵌入的隐秘信息比特流DATA
function [DATA] = extract(decrypted,embedRate,AInd)
%函数的输入为解密之后的载密图像decrypted；初始设置的嵌入率embedRate；预先知晓的非平滑块A的起始行数
%函数的输出为提取出嵌入的隐秘信息比特流DATA

%============================变量清单======================================
%decrypted:解密之后的载密图像
%h:decrypted的行数 w:decrypted的列数
%dataLength：嵌入的隐秘信息的长度
%embedRate：初始设置的嵌入率
%AInd：A块的起始行数
%AHeight：A块的行数
%DATA：提取出嵌入的隐秘信息

%============================提取隐秘信息===================================
decrypted = double(decrypted);
[h,w]= size(decrypted);
dataLength = embedRate * h * w;
AHeight = ceil(dataLength/w);
A=decrypted(AInd:AInd+AHeight,:);
A=A(:);
start=1;
for i=start:(start+dataLength)
     m(i) = mod(A(i),2);  %提取A块像素的最低有效位
     
end
DATA=m; %输出提取到的隐秘信息
save extract.mat; %保存extract子函数的变量信息



