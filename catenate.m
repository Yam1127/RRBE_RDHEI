% catenate�Ӻ�����������Ƕ���������Ϣ��A���Ԥ����֮���B��
function I = catenate(A,B,index,H)
%����������ΪǶ����������Ϣ֮���A�飬Ԥ����֮���B�飬ָ��A����ʼλ�õ�index��A�������H

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