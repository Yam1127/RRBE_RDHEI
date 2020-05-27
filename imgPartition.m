%imgPartition子函数用于选出非平滑块A和平滑块B

function [finalA,finalB,index] = imgPartition(I,H)
%函数输入为载体图像I；计算所得的非平滑块A的行数H
%函数输出为最终分割出的平滑块A和非平滑块B

%============================变量清单======================================
%I:原始载体图像
%m:载体图像的行值  n:载体图像的列值
%N：分块的个数
%H:计算所得的非平滑块A的行数
%f:每个块的平滑度
%val:临时变量，每个像素的平滑度
%A：临时变量，当前计算平滑度的块
%index：用于指向非平滑块A的起始行数
%finalA:最终分割出来的非平滑块A
%finalB:最终分割出来的平滑块B

%=========================计算每个块的平滑度f===============================
I = round(I);
[m,n] = size(I); %读取载体图像行值和列值
N = m - H + 1; %计算分块个数
f = zeros(N,1); %初始化每个块的平滑度

%对每个块计算平滑度f
for i = 1:N 
    A = I(i: i - 1 + H,1:n); %划分当前计算的分块
    [h,w] = size(A); %读取块的行值和列值
    for j = 1:h
        for k = 1:w
            if h == 1          %当前分块只有一行
                if j == 1 && k == 1                  %块中顶点像素
                    val = abs( A(j,k) - (A(j,k+1))/1);
                elseif j == 1 && k == w
                    val = abs( A(j,k) - (A(j,k-1))/1 );
                else
                    val = abs( A(j,k) - (A(j,k-1) + A(j,k+1))/2 );
                end
            else
                if j == 1 && k == 1                  %块中顶点像素
                    val = abs( A(j,k) - (A(j+1,k) + A(j,k+1))/2 );
                elseif j == 1 && k == w
                    val = abs( A(j,k) - (A(j+1,k) + A(j,k-1))/2 );                
                elseif j == h && k == 1
                    val = abs( A(j,k) - (A(j-1,k) + A(j,k+1))/2 );
                elseif j == h && k == w
                    val = abs( A(j,k) - (A(j-1,k) + A(j,k-1))/2 );
                elseif j == 1                        %块中非顶点边缘像素
                    val = abs( A(j,k) - (A(j+1,k) + A(j,k+1) + A(j,k-1))/3 );
                elseif j == h
                    val = abs( A(j,k) - (A(j-1,k) + A(j,k+1) + A(j,k-1))/3 );
                elseif k == 1
                    val = abs( A(j,k) - (A(j-1,k) + A(j+1,k) + A(j,k+1))/3 );
                elseif k == w
                    val = abs( A(j,k) - (A(j-1,k) + A(j+1,k) + A(j,k-1))/3 );
                else                                 %块中非边缘像素
                    val = abs( A(j,k) - (A(j-1,k) + A(j+1,k) + A(j,k-1) + A(j,k+1))/4 );
                end
            end
            f(i) = f(i) + val; %累加块中所有像素，得到该块的平滑度f
        end
    end
    f(i) = f(i)/( h*w );
end
[~,index] = max(f);  %挑选出所有块中f值最大，最不平滑的块。index指向最不平滑块的位置

%=========================分割出平滑块和非平滑块============================
if index == N %非平滑块为最后一个块
    finalA =  I(index : end, 1:n);
    finalB = I(1: index - 1, 1:n);
elseif index == 1 %非平滑块为第一个块
    finalA = I(index : index + H -1 , 1:n);
    finalB = I(index + H : end, 1:n);
else  %finalA为分割出的非平滑块，finalB为分割出的平滑块
    finalA = I(index : index + H -1, 1:n);
    finalB = [I(1:index -1, 1:n);
         I(index + H : end, 1:n)];
end
        
    
    
                
                
            


