%RRBE�Ӻ������������������ͼ���Ԥ�����Լ���������ϢǶ�뵽����ͼ����

function [wI,actualEmbedRate,PSNR,AInd,A,wB,AHeight,m] = RRBE(I,embedRate,T1,T2)
%��������Ϊ��������ͼ��I�����õ�Ƕ����embedRate
%�������ΪǶ���˶���������Ϣ������ͼ��wI��ʵ��Ƕ����actualEmbedRate����ֵ�����PSNR

%============================�����嵥======================================
%I��ԭʼ����ͼ��
%m:ԭʼ����ͼ����ֵ  n��ԭʼ����ͼ����ֵ
%embedRate���趨��Ƕ����
%datalength:����������ܹ�Ƕ������λ��
%H���ֿ����ֵ
%N:�ֿ������
%f:ÿ���ƽ����
%index��������ָ����A��λ��
%finalA:��ƽ����A
%finalB:ƽ����B
%m:��¼A��ԭʼ��LSBλ
%embeddingRound����¼��Ƕ��Ļغ���
%payload:��Ч����Ƕ�����λ��
%boundaryMap����Ƕ�������δǶ�������߽�
%wB:Ƕ����A��LSB��B��
%actualEmbedRate��ʵ��Ƕ����
%random{i,j}:���������Կ
%encrypted������ͼ��
%data��Ƕ���������Ϣ
%wA��Ƕ����������Ϣ��A��
%wI��Ƕ����������Ϣ������ͼ��
%psnr:��ֵ�����

%====================�жϺ�����������������Ƿ����Ҫ��======================
if (nargin < 2 || nargin > 4) %�������������Ҫ�󱨴�
   wI = -Inf;
   actualEmbedRate = -Inf;
   PSNR = -Inf;
   return;
end

if (nargin == 2)
    T1 = 0.25;
    T2 = 0.2; %T1��T2Ϊ��ǰʵ����������Ƕ���ʣ������ж��Ƿ���Ƕ�����Ƕ���������Ҫ���ж���Ƕ��
end

if (nargin == 3)
    T2 = 0.2;
end

%============================ͼ��ָ�======================================
%��ȡ����ͼ��
I = double(I); %������ͼ����unit8����ת����double���ͣ��������ľ�������
[h,w]= size(I); %��ȡ����ͼ���������ֵ����ֵ
dataLength = embedRate * h * w; %�����趨��Ƕ���ʼ��������Ƕ���������Ϣ��󳤶�

%��ѡ����ƽ����A��ƽ����B
if embedRate <= T1 %�趨��Ƕ����С��0.25��ֻ�����һ��Ƕ��
    T1Ind = false; %T1Ind���ڱ���Ƿ���Ҫ���ֵ�Ƕ��
    AHeight = ceil(dataLength/w); %���ݴ�Ƕ��������Ϣ�ĳ��ȣ��趨��A������
    [A, B, AInd] = imgPartition(I, AHeight); % ����imgPartition�Ӻ����������õ���ƽ����A��ƽ����B
else
    T1Ind = true; %��Ҫ���ж���Ƕ��
    AHeight = ceil(dataLength/(w * 2));
    [A, B, AInd] = imgPartition(I, AHeight); 
end
save image_partition.mat; %����ͼ��ָ�ֵı���

%=====================��������ϢǶ�뵽��A�������Чλ========================
data = round(rand(dataLength,1));
%���ݼ������õ������Ƕ���������Ϣ��󳤶ȣ�����������������У���Ϊ��Ƕ���������Ϣ
wA = embedA(A,data,T1Ind); %����embedA�Ӻ������������ΪǶ����������Ϣ��A��
save wA.mat; %����������ϢǶ�벿�ֵı���

%===============================��Ƕ��=====================================
%��ȡ��A��ԭʼ���ص������Чλ
if ~T1Ind  %����Ƿ���Ҫ���ж���Ƕ��
    m = mod(A,2);
    m = m(:);
    m = m(1:dataLength); %mΪ��ȡ�����Ŀ�A��ԭʼ���ص������Чλ
else 
    m1 = mod(A,2);
    m1 = m1(:);
    m2 = mod(floor(A/2),2);
    m2 = m2(:);
    m = [m1;m2];
    m = m(1:dataLength);
end 
embeddingRound = 1; %embeddingRoundΪ��¼��Ƕ��Ļغ�����ÿһ����Ƕ�����һ��embedB�Ӻ���
fprintf('  Embedding round %d:\n ',embeddingRound); %��ʾ��ǰ����Ƕ��غ���
[wB,payload,boundaryMap,multiInd]= embedB(B,m,T2); 
%����embedB�Ӻ������������Ϊ�����Ƕ���B��wB����Ч��Ƕ�����λ��payload;δǶ�������߽�boundaryMap

while multiInd  % �����Ҫ���ж���Ƕ��
    embeddingRound = embeddingRound + 1; %��Ƕ��غ�����һ
    fprintf(' Embedding round %d:\n ',embeddingRound); %��ʾ��ǰ����Ƕ��غ���
    d = m(payload + 1:end);  %��ʱ��dλδǶ���A�������ص�ԭʼ�����Чλ
    [wB,payload_m,boundaryMap_m,multiInd]= embedB(wB,d,T2); %��һ�ε���embedB�Ӻ���
    payload = payload + payload_m; %������һ��Ƕ��֮�����ЧǶ��λ��
    boundaryMap = [boundaryMap;boundaryMap_m];  %������һ����Ƕ��֮���δǶ������߽�boundaryMap
end
save wB.mat; %���������Ƕ��ı�����Ϣ

%==================����Ƕ����������Ϣ��A�����Ƕ���B��======================
wI = catenate(wA,wB,AInd,AHeight);
%����catenate�Ӻ������������Ϊ������A���B�������ͼ��
save wI.mat; %��������ͼ��ı�����Ϣ

%==========================�����ֵ�����PSNR===============================
PSNR = psnr(I,wI); %����PSNR�Ӻ�������������ͼ��ı����
actualEmbedRate = payload /(h*w) ; %����ʵ��Ƕ����actualEmbedRate 
    
    

    





