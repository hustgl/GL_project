function [ ZI ] = bilinear3( I,zmf )

%% ----------------------双线性插值法处理图像---------------------------
% Input：
%       I：图像文件名或矩阵（整数值（0~255））
%       zmf：缩放因子，即缩放的倍数
% Output：
%       对矩阵I进行zmf倍的缩放并显示

%% 命令行中输入以下命令运行即可：
%  interpolation('flower2.png', 4);

%% Step1 对数据进行预处理
if ~exist('I','var') || isempty(I)
    error('输入图像I未定义或为空！');
end
if ~exist('zmf','var') || isempty(zmf) || numel(zmf) ~= 1
     error('位移矢量zmf未定义或为空或zmf中的元素超过2！');
end
if ischar(I)
    [I,M] = imread(I);
end
if zmf <= 0
     error('缩放倍数zmf的值应该大于0！');
end

%% Step2 通过原始图像和缩放因子得到新图像的大小，并创建新图像。
[IH,IW,ID] = size(I);    
ZIH = round(IH*zmf);     % 计算缩放后的图像高度，最近取整
ZIW = round(IW*zmf);     % 计算缩放后的图像宽度，最近取整
ZI = zeros(ZIH,ZIW,ID);  % 创建新图像

%% Step3 扩展矩阵I边缘
%双线性插值是用待求值点周围四个点的值来计算的，当新图像上的像素点映射到原图像的边界时，边界扩展保证了计算能正确进行，而不会溢出。
IT = zeros(IH+1,IW+1,ID);
IT(1:IH,1:IW,:) = I;
IT(1:IH,IW+1,:) = I(1:IH, IW, :);
IT(IH+1,1:IW,:) = I(IH, 1:IW, :);
IT(IH+1,IW+1,:)=I(IH,IW,:);

%% Step4 由新图像的某个像素（zi，zj）映射到原始图像(ii，jj)处，并插值。
for zi = 1:ZIH         % 对图像进行按列逐元素扫描
    for zj = 1:ZIW
        ii = (zi-1)/zmf; jj = (zj-1)/zmf;
        i = floor(ii); j = floor(jj);    % 向下取整
        u = ii - i; v = jj - j;
        i = i + 1; j = j + 1;
        ZI(zi,zj,:) = (1-u)*(1-v)*IT(i,j,:) + (1-u)*v*IT(i,j+1,:) + u*(1-v)*IT(i+1,j,:) + u*v*IT(i+1,j+1,:);
    end
end

ZI = uint8(ZI);

%% 显示处理前后的图像
figure;
imshow(I,M);
axis on;
title(['original image（',num2str(IH),'*',num2str(IW),'*',num2str(ID),')']);
figure;
imshow(ZI,M);
axis on;
title(['interpolated resultant image（',num2str(ZIH),'*',num2str(ZIW),'*',num2str(ID)',')']);
end
