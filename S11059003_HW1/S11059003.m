% 清除command window, workspace, image window
close all;
clear all;
clc;

% 讀入圖案
RGB = imread('handwrite02.jpg');

% 轉換為灰階
Gray = rgb2gray(RGB);

% 調整對比度，使文字與背景的對比更明顯
Gray_adj = imadjust(Gray, [0.35 0.8], [0 1]);
BW = im2bw(Gray_adj, 0.52);

% 輸出圖案
figure;
subplot(1,1,1), imshow(BW), title('Result(S11059003)');

% R與A的空白無法顯現
