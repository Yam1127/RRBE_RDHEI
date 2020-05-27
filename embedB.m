%embedB�Ӻ������ڽ���A������ԭʼ�������ЧλǶ�뵽B��İ�ɫ���ػ��ɫ������

function [W,payload,boundaryMap,multiInd] = embedB(B,m,T2)
%����������Ϊԭʼ��ƽ����B����ȡ����A�����ص�ԭʼ�����Чλm���ж��Ƿ���Ҫ������Ƕ���Ƕ����T2
%���������ΪǶ���˿�A�����ص�ԭʼ�����Чλ��B��W����Ч��Ƕ����payload��δǶ�������߽�boundaryMap������Ƿ���Ҫ������Ƕ���multiInd

%============================�����嵥======================================
%m:��ȡ����A�����ص�ԭʼ�����Чλ
%length_m:m��λ��
%multiInd:����Ƿ���Ҫ������Ƕ��
%pixelFlag:���ѡ�е��ǰ�ɫ���ػ��Ǻ�ɫ����
%diffHist:��B��Ԥ�����ֱ��ͼ
%LN,LM��Ԥ�����ֱ��ͼ������ֵ������ֵ��
%RN,RM��Ԥ�����ֱ��ͼ������ֵ����ҷ�ֵ��
%payload:��ЧǶ��λ��
%wB��Ƕ���˿�A�����ص�ԭʼ�����Чλ��B��
%boundaryMap��δǶ�������߽�


%==========================����Ԥ�����ֱ��ͼ===============================
length_m = length(m); %��ȡm�ĳ���
multiInd = false; %���ڼ���Ƿ���Ҫ������Ƕ��
% �����B�����ص�Ԥ��������Ԥ�����ֱ��ͼ
pixelFlag = 0; % ���ڱ�ǰ�ɫ���ػ��ߺ�ɫ���أ�pixelFlag = 0ʱѡ�а�ɫ����
[diffHist, LN, LM, RN, RM,e] = histGen(B,pixelFlag);    
%����histGen�Ӻ������������ΪB���Ԥ�����ֱ��ͼdiffHist��ֱ��ͼ�����ֵ��LM������ֵ��LN���ҷ�ֵ��RM������ֵ��RN
save diffHist.mat; %�����������ֱ��ͼ���ֵı�����Ϣ


%===================ƽ��Ԥ�����ֱ��ͼǶ�������Чλm========================
diffStart = 256;                  
para = zeros(4,1);
payload = 0; %��ʼ����ЧǶ��λ��payload

%�жϰ�ɫ�����Ƿ��ܹ���ȫǶ���A��ԭʼ���ص������Чλm
if diffHist(LM + diffStart) + diffHist(RM+ diffStart) > length_m - payload
    if diffHist(LM + diffStart) + diffHist(RM+ diffStart) < T2*sum(diffHist)
        LM = LN; RM = RN;
        while diffHist(LM + diffStart) + diffHist(RM + diffStart) <  length_m && LM < RM %���¼���LM��RM
            LM=LM+1;
            RM=RM-1;
        end
        if LM == RM
            LM = RM-1;
        end
        para(1) = LN; para(2) = LM; para(3) = RM; para(4) = RN; %ȷ�����ʵ�LN,LM,RM,RN
        
        %����A��ԭʼ���������ЧλmǶ��B���еİ�ɫ������
       [wB,payload,boundaryMap] = embedWhite(B,m,para);
       %����embedWhite�Ӻ������������Ϊ������Ƕ����ɵ�B�飻��ЧǶ��λ��payload��δǶ������ı߽�boundaryMap
        W = wB;
        payload = payload - length(boundaryMap);
        fprintf(' %d bits are embedded into white pixels. Embedding process done...\n ',payload);
        %��ʾ����Ƕ�����ЧǶ��λ����Ƕ�뵽��ɫ������ϣ���Ƕ����̽���
    else
        para(1) = LN; para(2) = LM; para(3) = RM; para(4) = RN;
        [wB,payload,boundaryMap] = embedWhite(B,m,para);
        W = wB;
        payload = payload - length(boundaryMap);
        fprintf(' %d bits are embedded into white pixels. Embedding process done...\n ',payload);
    end
else %�����Ƕ��������Чλ��������ɫ������Ƕ������λ�����ڰ�ɫ����Ƕ��֮�󻹿���Ƕ�뵽��ɫ������
    para(1) = LN; para(2) = LM; para(3) = RM; para(4) = RN;  
    [wB1,payload1,boundaryMap1] = embedWhite(B,m,para);
    payload = payload1 - length(boundaryMap1);
    boundaryMap = boundaryMap1;
    fprintf(' %d bits are embedded into white pixels. Black pixels needed...\n ',payload);
    %��ʾ���ֵ���ЧǶ��λ��payload��Ƕ�뵽��ɫ����֮�к���Ƕ�뵽��ɫ����
    
    pixelFlag = 1; %ѡ�к�ɫ����
    [diffHist, LN, LM, RN, RM] = histGen(wB1,pixelFlag);
    %��һ�ε���histGen�Ӻ����������Ѿ�Ƕ���ɫ������ɵĿ�B��Ԥ�����ֱ��ͼ
    
    %�жϺ�ɫ�����Ƿ��㹻Ƕ��ʣ��δǶ��Ŀ�A��ԭʼ���ص������Чλm
    if diffHist(LM + diffStart) + diffHist(RM+ diffStart) > length_m - payload 
        if diffHist(LM + diffStart) + diffHist(RM+ diffStart) < T2*sum(diffHist)
            LM = LN; RM = RN;
            while diffHist(LM + diffStart) + diffHist(RM + diffStart) <  length_m - payload && LM < RM %���¼���LM��RM
            LM=LM+1;
            RM=RM-1;
            end
            if LM == RM
                LM = RM-1;
            end
            para(1) = LN; para(2) = LM; para(3) = RM; para(4) = RN; %ȷ����ʱ��LN,LM,RM,RN
            
            m = m(payload+1:end); %��ȡδǶ��Ŀ�A��ԭʼ���ص������Чλm
            [wB2,payload2,boundaryMap2] = embedBlack(wB1,m,para);
            %����embedBlack�Ӻ������������ЧλǶ�뵽��B�еĺ�ɫ������
            
            payload = payload + payload2 - length(boundaryMap2);
            boundaryMap = [boundaryMap;boundaryMap2];
            W =wB2;
            fprintf(' %d bits are embedded into black pixels. Embedding process done...\n ',payload2);
            %��ʾ�˴���Ƕ������е���ЧǶ��λ����Ƕ�뵽��ɫ�����У���Ƕ�����
        else
            para(1) = LN; para(2) = LM; para(3) = RM; para(4) = RN; 
            m = m(payload+1:end);
            [wB2,payload2,boundaryMap2] = embedBlack(wB1,m,para);
            payload = payload + payload2 - length(boundaryMap2);
            boundaryMap = [boundaryMap;boundaryMap2];
            W =wB2;
            fprintf(' %d bits are embedded into black pixels. Embedding process done...\n ',payload2);
        end
    else 
        multiInd = true; % Ƕ�뻹δ��ɣ���Ҫ���ж���Ƕ��
        para(1) = LN; para(2) = LM; para(3) = RM; para(4) = RN;
        m = m(payload+1:end);
        [wB2,payload2,boundaryMap2] = embedBlack(wB1,m,para);
        payload = payload + payload2 - length(boundaryMap2);
        boundaryMap = [boundaryMap;boundaryMap2];
        W = wB2;
    fprintf(' %d bits are embedded into black pixels. Multilayer embedding scheme needed...\n ',payload2);
    %��ʾ�˴�Ƕ���ʵ��Ƕ��λ����Ƕ���ɫ���أ���Ҫ����Ƕ�룬ֱ�����������Чλ�������Ƕ��
    end
end
        
        
        
    
    

    
    
    




    






