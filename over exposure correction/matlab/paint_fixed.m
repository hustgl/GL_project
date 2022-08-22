% 10bit.8bit
namein = 'IMG_4328';
im4248 = imread(['\\192.168.7.200\data\HDR\10vs13bit\',namein,'.tif'])/4; % max elements = 1024
cfa = 'rggb';

[height,width,~] = size(im4248);  % 3024 * 4032
[awb, black_level] = get_dng_info(['\\192.168.7.200\data\HDR\10vs13bit\',namein,'.dng']); % [1.915. 1, 2.0969]  [0 0 0]
% ------------
awb = round(awb*256)/256; % verilog /256 is not needed
% ***********

imbayer = zeros(height,width); % 3024 * 4032
imbayer(1:2:end,1:2:end) = im4248(1:2:end,1:2:end,1); % R  
imbayer(1:2:end,2:2:end) = im4248(1:2:end,2:2:end,2); % G
imbayer(2:2:end,1:2:end) = im4248(2:2:end,1:2:end,2); % G
imbayer(2:2:end,2:2:end) = im4248(2:2:end,2:2:end,3); % B  bayer color pattern

imcin = imbayer;
imcin(imcin > 1023) = 1023; % max = 1023, double 

% kernel
kersizerow = 6;
kersizecol = 12;
knee = 600;
sigma = 1/120;
knnm = 0.4;

sigm1 = 300*300;
sigm2 = 50*50;
sigm3 = 240;

for iter = 1:2
    if iter == 1 
    imcinwb = wb(imcin, cfa, awb(1), awb(3), 1023); % max = 1023 after wb
    % --------
    imcinwb = round(imcinwb*256)/256;
    % ********
    imrgb = vcd_demosaic(imcinwb,cfa);
    figure,imshow((imrgb./1023*1023/960).^1,'border','tight');
    % RTL calc1
    imcing = (imcinwb(1:2:end,2:2:end)+imcinwb(2:2:end,1:2:end))/2; % Green value 1512 * 2016
    imcinr = imcinwb(1:2:end,1:2:end);
    imcinb = imcinwb(2:2:end,2:2:end);
    
    imcor = imcinr./(imcing+2^(-8));   % max = 120540 [1062,1038]
    imcob = imcinb./(imcing+2^(-8));   % max = 9666  [1062,1038]
    imcor(imcor>1023) = 1023;
    imcob(imcob>1023) = 1023;
    % --------
    imcor = round(imcor*256)/256;
    imcob = round(imcob*256)/256;
    % ********
    
    imcorw = -((imcor-1)*4).^2+1; % 1512*2016 max 1.0000
    imcobw = -((imcob-1)*4).^2+1; % max 1
    % --------
    imcorw = round(imcorw*256)/256;
    imcobw = round(imcobw*256)/256;
    % ********
    imcorw(imcorw>imcobw)=imcobw(imcorw>imcobw); % select the smaller value
    imcorw(imcorw<0)=0;
    imcorw = imfilter(imcorw,fspecial('average',[3,3])); % mean filter 1512 * 2016
    % --------
    imcorw = round(imcorw*256)/256;
    % ********
    
    imcorww = imcinwb*0;
    for i=1:2
        for j=1:2
            imcorww(i:2:end,j:2:end)=imcorw; % interpolation 3024 * 4032 duplicate 4 times
        end
    end   
    imcinww = imcorww;
    %RTL cal2
    imy1 = (imcin(1:2:end,2:2:end) + imcin(2:2:end,1:2:end) + imcin(1:2:end,1:2:end) + imcin(2:2:end,2:2:end))/4;
    imy  = imcin;  
    for i=1:2
        for j=1:2
            imy(i:2:end,j:2:end) = imy1; %duplicate 4 times max=860.25  min=1.75
        end
    end    
    m = 0.5*(tanh(sigma*((imy-knee)))+1);%1/120 * (imy - 600)
    mcor = 0.5*(tanh(sigma*((imcin-knee)))+1);
    % -----------
    m = round(m*256)/256;
    mcor = round(mcor*256)/256;
    % ***********
    imo = imcin;
    imosum = imcin *0;
    imowsum = imcin *0;
    imoy = imy;
    maxdiffall= imcin*0;
    blurweightall = imcin*0;    
    for i = 1+kersizerow:2:height-kersizerow  % 1+6:2:3024-6
        i
        for j = 1+kersizecol:2:width-kersizecol %1+12:2:4032-12
            if(m(i,j) > knnm)
                for ii=i-kersizerow:2:i+kersizerow %i-6:2:i+6,inside the kernel
                    for jj=j-kersizecol:2:j+kersizecol %j-12:2:j+12
                        tmp = imoy(ii,jj)-imoy(i,j);
                        if tmp<0
                            mtmp = (tmp /800)^4;
                        else
                            mtmp = 0;
                        end
                        mtmp(mtmp<0)=0;
                        mtmp(mtmp>1)=1;
                        % -------
                        mtmp = round(mtmp*256)/256;
                        % *******
                        if ii==i && jj==j
                            continue;
                        end
                        wcor = expcurve(imo(ii,jj)-imcin(i,j),sigm1,sigm2) * expcurve(imo(ii+1,jj) - imcin(i+1,j),sigm1,sigm2)...
                        * expcurve(imo(ii,jj+1) - imcin(i,j+1),sigm1,sigm2) * expcurve(imo(ii+1,jj+1) - imcin(i+1,j+1),sigm1,sigm2);
                        % -------
                        wcor = round(wcor*256)/256;
                        % *******
                        wdis = exp(-((ii - i)^2+(jj-j)^2)/sigm3);
                        % -------
                        wdis = round(wdis*256)/256;
                        % *******
                        wtmp = wcor * wdis * mtmp;
                        imosum(i:i+1,j:j+1) = imosum(i:i+1,j:j+1) + imo(ii:ii+1,jj:jj+1) * wtmp; % the center of the kernel is calculated
                        imowsum(i:i+1,j:j+1) = imowsum(i:i+1,j:j+1) + wtmp;
                    end
                end
                if imowsum(i,j)>0
                    imotmp = imosum(i:i+1,j:j+1) ./ imowsum(i:i+1,j:j+1);
                    mcortmp = 0.5*(tanh(sigma*((imotmp-knee)))+1);
                    % ---------
                    mcortmp = round(mcortmp*256)/256;
                    % *********
                    maxdiff = max(max(abs(mcortmp-mcor(i:i+1,j:j+1))));
                    maxdiffall(i:i+1,j:j+1)=maxdiff;
                    blurweight = (maxdiff-0.2)/(0.6-0.2);
                    % -------
                    blurweight = round(blurweight*256)/256;
                    % *******
                    blurweight(blurweight<0)=0;
                    blurweight(blurweight>1)=1;
                    imo(i:i+1,j:j+1)  = imotmp*(1-blurweight)+imo(i:i+1,j:j+1)*blurweight;
                end
                if strcmp(cfa, 'rggb') || strcmp(cfa,'bggr')
                    imo(i+1, j) = (imo(i+1,j)+imo(i,j+1))/2;
                    imo(i,j+1) = imo(i+1,j);
                else
                    imo(i,j) = (imo(i,j)+imo(i+1,j+1))/2;
                    imo(i+1,j+1) = imo(i,j);
                end
                imoy(i:i+1,j:j+1) = mean(mean(imo(i:i+1,j:j+1))); % mean filter
            end
        end
    end
    imo = imcin.*imcinww + imo.*(1-imcinww);
    imowb = wb(imo,cfa,awb(1),awb(3),1023);
    imorgb = vcd_demosaic(imowb,cfa);
    figure,imshow((imorgb./1023).^1,'border','tight');
    end
end
