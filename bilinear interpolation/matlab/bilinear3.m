function [ ZI ] = bilinear3( I,zmf )

%% ----------------------˫���Բ�ֵ������ͼ��---------------------------
% Input��
%       I��ͼ���ļ������������ֵ��0~255����
%       zmf���������ӣ������ŵı���
% Output��
%       �Ծ���I����zmf�������Ų���ʾ

%% �����������������������м��ɣ�
%  interpolation('flower2.png', 4);

%% Step1 �����ݽ���Ԥ����
if ~exist('I','var') || isempty(I)
    error('����ͼ��Iδ�����Ϊ�գ�');
end
if ~exist('zmf','var') || isempty(zmf) || numel(zmf) ~= 1
     error('λ��ʸ��zmfδ�����Ϊ�ջ�zmf�е�Ԫ�س���2��');
end
if ischar(I)
    [I,M] = imread(I);
end
if zmf <= 0
     error('���ű���zmf��ֵӦ�ô���0��');
end

%% Step2 ͨ��ԭʼͼ����������ӵõ���ͼ��Ĵ�С����������ͼ��
[IH,IW,ID] = size(I);    
ZIH = round(IH*zmf);     % �������ź��ͼ��߶ȣ����ȡ��
ZIW = round(IW*zmf);     % �������ź��ͼ���ȣ����ȡ��
ZI = zeros(ZIH,ZIW,ID);  % ������ͼ��

%% Step3 ��չ����I��Ե
%˫���Բ�ֵ���ô���ֵ����Χ�ĸ����ֵ������ģ�����ͼ���ϵ����ص�ӳ�䵽ԭͼ��ı߽�ʱ���߽���չ��֤�˼�������ȷ���У������������
IT = zeros(IH+1,IW+1,ID);
IT(1:IH,1:IW,:) = I;
IT(1:IH,IW+1,:) = I(1:IH, IW, :);
IT(IH+1,1:IW,:) = I(IH, 1:IW, :);
IT(IH+1,IW+1,:)=I(IH,IW,:);

%% Step4 ����ͼ���ĳ�����أ�zi��zj��ӳ�䵽ԭʼͼ��(ii��jj)��������ֵ��
for zi = 1:ZIH         % ��ͼ����а�����Ԫ��ɨ��
    for zj = 1:ZIW
        ii = (zi-1)/zmf; jj = (zj-1)/zmf;
        i = floor(ii); j = floor(jj);    % ����ȡ��
        u = ii - i; v = jj - j;
        i = i + 1; j = j + 1;
        ZI(zi,zj,:) = (1-u)*(1-v)*IT(i,j,:) + (1-u)*v*IT(i,j+1,:) + u*(1-v)*IT(i+1,j,:) + u*v*IT(i+1,j+1,:);
    end
end

ZI = uint8(ZI);

%% ��ʾ����ǰ���ͼ��
figure;
imshow(I,M);
axis on;
title(['original image��',num2str(IH),'*',num2str(IW),'*',num2str(ID),')']);
figure;
imshow(ZI,M);
axis on;
title(['interpolated resultant image��',num2str(ZIH),'*',num2str(ZIW),'*',num2str(ID)',')']);
end
