clc;clear; warning off
%% Change direction
prev_dir = pwd; file_dir = fileparts(mfilename('fullpath')); cd(file_dir);
addpath(genpath(pwd));
%% 测试主函数
I= double(imread('F:\毕业设计\RRBE\测试图像\test.jpg'));
embedRate = 0.2;
[wI,actualEmbedRate,PSNR,AInd,A,wB,AHeight,m] = RRBE(I,embedRate);
[encrypted,random] = encrypted(wI);
figure,imshow(I/255),title('orignal image I');
figure,imshow(wI/255),title('watermarked image wI'); 
fprintf('The PSNR of wI is: %.2f dB \n',PSNR);
fprintf('The actual embedding rate is %.2f bpp \n',actualEmbedRate);
[decrypted] = decrypted(encrypted,random,wI);
[DATA] = extract(decrypted,embedRate,AInd);
TEST = catenate(A,wB,AInd,AHeight);
[x]=psnr(I,TEST);
[restore]=home(decrypted,embedRate,AInd,A,m);

