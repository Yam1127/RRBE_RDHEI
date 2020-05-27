%extract�Ӻ������ڴӽ���֮�������ͼ��֮����ȡ��Ƕ���������Ϣ������DATA
function [DATA] = extract(decrypted,embedRate,AInd)
%����������Ϊ����֮�������ͼ��decrypted����ʼ���õ�Ƕ����embedRate��Ԥ��֪���ķ�ƽ����A����ʼ����
%���������Ϊ��ȡ��Ƕ���������Ϣ������DATA

%============================�����嵥======================================
%decrypted:����֮�������ͼ��
%h:decrypted������ w:decrypted������
%dataLength��Ƕ���������Ϣ�ĳ���
%embedRate����ʼ���õ�Ƕ����
%AInd��A�����ʼ����
%AHeight��A�������
%DATA����ȡ��Ƕ���������Ϣ

%============================��ȡ������Ϣ===================================
decrypted = double(decrypted);
[h,w]= size(decrypted);
dataLength = embedRate * h * w;
AHeight = ceil(dataLength/w);
A=decrypted(AInd:AInd+AHeight,:);
A=A(:);
start=1;
for i=start:(start+dataLength)
     m(i) = mod(A(i),2);  %��ȡA�����ص������Чλ
     
end
DATA=m; %�����ȡ����������Ϣ
save extract.mat; %����extract�Ӻ����ı�����Ϣ



