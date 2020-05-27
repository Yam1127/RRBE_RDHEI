%embedB子函数用于将块A中像素原始的最低有效位嵌入到B块的白色像素或黑色像素中

function [W,payload,boundaryMap,multiInd] = embedB(B,m,T2)
%函数的输入为原始的平滑块B；提取出块A中像素的原始最低有效位m；判断是否需要多轮自嵌入的嵌入率T2
%函数的输出为嵌入了块A中像素的原始最低有效位的B块W；有效的嵌入率payload；未嵌入的溢出边界boundaryMap；标记是否需要多轮自嵌入的multiInd

%============================变量清单======================================
%m:提取出块A中像素的原始最低有效位
%length_m:m的位数
%multiInd:标记是否需要多轮自嵌入
%pixelFlag:标记选中的是白色像素还是黑色像素
%diffHist:块B的预测误差直方图
%LN,LM：预测误差直方图的左零值点和左峰值点
%RN,RM：预测误差直方图的有零值点和右峰值点
%payload:有效嵌入位数
%wB：嵌入了块A中像素的原始最低有效位的B块
%boundaryMap：未嵌入的溢出边界


%==========================生成预测误差直方图===============================
length_m = length(m); %读取m的长度
multiInd = false; %用于检测是否需要多轮自嵌入
% 计算块B中像素的预测误差，生成预测误差直方图
pixelFlag = 0; % 用于标记白色像素或者黑色像素，pixelFlag = 0时选中白色像素
[diffHist, LN, LM, RN, RM,e] = histGen(B,pixelFlag);    
%调用histGen子函数，返回输出为B块的预测误差直方图diffHist；直方图的左峰值点LM；左零值点LN；右峰值点RM；右零值点RN
save diffHist.mat; %保存生成误差直方图部分的变量信息


%===================平移预测误差直方图嵌入最低有效位m========================
diffStart = 256;                  
para = zeros(4,1);
payload = 0; %初始化有效嵌入位数payload

%判断白色像素是否能够完全嵌入块A中原始像素的最低有效位m
if diffHist(LM + diffStart) + diffHist(RM+ diffStart) > length_m - payload
    if diffHist(LM + diffStart) + diffHist(RM+ diffStart) < T2*sum(diffHist)
        LM = LN; RM = RN;
        while diffHist(LM + diffStart) + diffHist(RM + diffStart) <  length_m && LM < RM %重新计算LM和RM
            LM=LM+1;
            RM=RM-1;
        end
        if LM == RM
            LM = RM-1;
        end
        para(1) = LN; para(2) = LM; para(3) = RM; para(4) = RN; %确定合适的LN,LM,RM,RN
        
        %将块A的原始像素最低有效位m嵌入B块中的白色像素中
       [wB,payload,boundaryMap] = embedWhite(B,m,para);
       %调用embedWhite子函数，返回输出为此轮自嵌入完成的B块；有效嵌入位数payload；未嵌入溢出的边界boundaryMap
        W = wB;
        payload = payload - length(boundaryMap);
        fprintf(' %d bits are embedded into white pixels. Embedding process done...\n ',payload);
        %显示此轮嵌入的有效嵌入位数，嵌入到白色像素完毕，自嵌入过程结束
    else
        para(1) = LN; para(2) = LM; para(3) = RM; para(4) = RN;
        [wB,payload,boundaryMap] = embedWhite(B,m,para);
        W = wB;
        payload = payload - length(boundaryMap);
        fprintf(' %d bits are embedded into white pixels. Embedding process done...\n ',payload);
    end
else %如果待嵌入的最低有效位数超过白色像素能嵌入的最大位数，在白色像素嵌入之后还可以嵌入到黑色像素中
    para(1) = LN; para(2) = LM; para(3) = RM; para(4) = RN;  
    [wB1,payload1,boundaryMap1] = embedWhite(B,m,para);
    payload = payload1 - length(boundaryMap1);
    boundaryMap = boundaryMap1;
    fprintf(' %d bits are embedded into white pixels. Black pixels needed...\n ',payload);
    %显示此轮的有效嵌入位数payload，嵌入到白色像素之中后还需嵌入到黑色像素
    
    pixelFlag = 1; %选中黑色像素
    [diffHist, LN, LM, RN, RM] = histGen(wB1,pixelFlag);
    %再一次调用histGen子函数，生成已经嵌入白色像素完成的块B的预测误差直方图
    
    %判断黑色像素是否足够嵌入剩下未嵌入的块A中原始像素的最低有效位m
    if diffHist(LM + diffStart) + diffHist(RM+ diffStart) > length_m - payload 
        if diffHist(LM + diffStart) + diffHist(RM+ diffStart) < T2*sum(diffHist)
            LM = LN; RM = RN;
            while diffHist(LM + diffStart) + diffHist(RM + diffStart) <  length_m - payload && LM < RM %重新计算LM和RM
            LM=LM+1;
            RM=RM-1;
            end
            if LM == RM
                LM = RM-1;
            end
            para(1) = LN; para(2) = LM; para(3) = RM; para(4) = RN; %确定此时的LN,LM,RM,RN
            
            m = m(payload+1:end); %提取未嵌入的块A中原始像素的最低有效位m
            [wB2,payload2,boundaryMap2] = embedBlack(wB1,m,para);
            %调用embedBlack子函数，将最低有效位嵌入到块B中的黑色像素中
            
            payload = payload + payload2 - length(boundaryMap2);
            boundaryMap = [boundaryMap;boundaryMap2];
            W =wB2;
            fprintf(' %d bits are embedded into black pixels. Embedding process done...\n ',payload2);
            %显示此次自嵌入过程中的有效嵌入位数，嵌入到黑色像素中，自嵌入完成
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
        multiInd = true; % 嵌入还未完成，需要进行多轮嵌入
        para(1) = LN; para(2) = LM; para(3) = RM; para(4) = RN;
        m = m(payload+1:end);
        [wB2,payload2,boundaryMap2] = embedBlack(wB1,m,para);
        payload = payload + payload2 - length(boundaryMap2);
        boundaryMap = [boundaryMap;boundaryMap2];
        W = wB2;
    fprintf(' %d bits are embedded into black pixels. Multilayer embedding scheme needed...\n ',payload2);
    %显示此次嵌入的实际嵌入位数，嵌入黑色像素，需要多轮嵌入，直至所有最低有效位都完成自嵌入
    end
end
        
        
        
    
    

    
    
    




    






