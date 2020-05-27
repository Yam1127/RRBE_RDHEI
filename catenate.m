% catenate子函数用于连接嵌入的隐秘信息的A块和预处理之后的B块
function I = catenate(A,B,index,H)
%函数的输入为嵌入了隐秘信息之后的A块，预处理之后的B块，指向A块起始位置的index，A块的行数H

N =  size(A,1) + size(B,1) - H + 1; 
if index == N
   I = [B;A];
elseif index == 1
   I = [A;B];
else
    I= [B(1:index-1, 1:size(A,2));
         A;
         B(index : end, 1:size(A,2))];
end
save catenate.mat;