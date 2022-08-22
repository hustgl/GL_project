% path = 'E:\Matlab_work\prj_OEC\';
% filename = 'IMG_4248.bmp';
% width = 2096;
% height = 1560;
% cfa = 'grbg';
% offset = 64;
% knee = 959;
% imcin = raw10Load(strcat(path,filename),height,width)-offset;
% 
% im = load('IMG_4248.mat');
% im10 = im.im_in10;
% im13 = im.im_in13;
% im10rgb = vcd_demosaic(im10,'rggb');
% im13rgb = vcd_demosaic(im13,'rggb');
% figure,imshow((im10rgb./1023).^1)
% figure,imshow((im13rgb./6616).^1*3)
%%
nameall = ['IMG_4240';'IMG_4328';'IMG_4332';'IMG_4244';'IMG_4248';'IMG_4258';'IMG_4336';'IMG_6020'];
writeen =0;

for imnum = 2%4:8
    namein = nameall(imnum,:);
    name = [namein,'wcorave5'];
    im4248 = imread(['\\192.168.7.200\data\HDR\10vs13bit\',namein,'.tif'])/4;   
    cfa = 'rggb';
     
%     awb = [1.6,1,1.4];
%     im4248 = t1;
%     cfa = 'grbg';
    
    [height,width,~] = size(im4248);

    [awb,black_level]=get_dng_info(['\\192.168.7.200\data\HDR\10vs13bit\',namein,'.dng']);
    %load('awb.mat')
    %figure,imshow(imbayer./4095)
    %figure,imshow(double(im4248)./4095)
    
    if imnum==8
        imbayer = double(im4248);
        awb = [1,1,1];
    else
        imbayer = zeros(height,width);
        imbayer(1:2:end,1:2:end) = im4248(1:2:end,1:2:end,1); % R
        imbayer(1:2:end,2:2:end) = im4248(1:2:end,2:2:end,2); % G
        imbayer(2:2:end,1:2:end) = im4248(2:2:end,1:2:end,2); % G
        imbayer(2:2:end,2:2:end) = im4248(2:2:end,2:2:end,3); % B  1 pixel 3 channel into  4 cells
    end

     imcin = imbayer;
     imcin(imcin>1023)=1023;    
    
    kersizerow = 6;
    kersizecol = 12;
    knee = 600;
    sigma =1/120;
    knnm = 0.4;

    sigm1 = 300*300;
    sigm2 = 50*50;
    sigm3 = 240;

    for iter = 1:2
        imcinwb = wb(imcin,cfa,awb(1),awb(3),1023);      
%         figure,imshow(imcinwb./1023)
        if iter ==1 
            imrgb = vcd_demosaic(imcinwb,cfa);
            figure,imshow((imrgb./1023*1023/960).^1,'border','tight'),
            text(80,80,['ker=[',num2str(kersizerow),',',num2str(kersizecol),'];','iter=0'],'horiz','left','color','r','fontsize',20)
            if writeen
                f = getframe(figure(1));
                imwrite(f.cdata,['E:\ISP\Panting\result\',name,'iter0.bmp'])
            end
        end
        
        imcing = (imcinwb(1:2:end,2:2:end)+imcinwb(2:2:end,1:2:end))/2;
        imcinr = imcinwb(1:2:end,1:2:end);
        imcinb = imcinwb(2:2:end,2:2:end);    
        imcor = imcinr./(imcing+0.001);
        imcob = imcinb./(imcing+0.001);
        imcorw = -((imcor-1)*4).^2+1;
        imcobw = -((imcob-1)*4).^2+1;
        imcorw(imcorw>imcobw)=imcobw(imcorw>imcobw);
        imcorw(imcorw<0)=0;
        imcorw = imfilter(imcorw,fspecial('average',[5,5]));
        %imcorw = ordfilt2(imcorw,13,ones(5,5));
        
%         imcinwbmin = HALF_SCALE_DOWN(imcinwb,2);
%         imcinww = (imcinwbmin-998)*0.2/(1020-998)+0.8;   %filter and color prior maybe better  parameter should adjust awb gain 
%         figure,imshow(imcinww)     
%         imcin1 = imfilter(imcinww(1:2:end,1:2:end),fspecial('average',[3,3]));
             
        imcorww=imcinwb*0;
        for i=1:2
            for j=1:2
%                 imcinww(i:2:end,j:2:end)=imcin1;
                imcorww(i:2:end,j:2:end)=imcorw;
            end
        end 
%         imcinww(imcinww<0)=0;
%         imcinww(imcinww>1)=1;
%         imcinww = imcinww.*imcorww;

        imcinww = imcorww;
        %imcinww = 0;

        imy1 = (imcin(1:2:end,2:2:end) + imcin(2:2:end,1:2:end) + imcin(1:2:end,1:2:end) + imcin(2:2:end,2:2:end))/4;
        imy = imcin;
        for i=1:2
            for j=1:2
                imy(i:2:end,j:2:end) = imy1;
            end
        end
        % figure,imshow(imy./1023)

        m = 0.5*(tanh(sigma*((imy-knee)))+1);
        mcor = 0.5*(tanh(sigma*((imcin-knee)))+1);
       % mcormin = HALF_SCALE_DOWN(mcor,2);
        % figure,imshow(mcormin)
        % figure,imshow(mcor)

        imo=imcin;
        imosum = imcin *0;
        imowsum = imcin *0;
        imoy = imy;
        maxdiffall= imcin*0;
        blurweightall = imcin*0;
        for i=1+kersizerow:2:height-kersizerow
            i
            for j=1+kersizecol:2:width-kersizecol
                if(m(i,j)>knnm)
                    for ii=i-kersizerow:2:i+kersizerow
                        for jj=j-kersizecol:2:j+kersizecol
                           % mtmp = 1- 0.5*(tanh(sigma*((imoy(ii,jj)-imoy(i,j))))+1);
                           % mtmp = 1- 1*(tanh(1/800*((imoy(ii,jj)-imoy(i,j))))+1);
                           tmp = imoy(ii,jj)-imoy(i,j);
                           if tmp<0
                               mtmp = (tmp*1/800)^4;
                               %mtmp = (tmp/imoy(i,j))^4;%
                           else
                               mtmp = 0;
                           end
                            mtmp(mtmp<0)=0;
                            mtmp(mtmp>1)=1;
                            if ii==i && jj==j
                                continue;
                            end

                            wcor = expcurve(imo(ii,jj)-imcin(i,j),sigm1,sigm2) * expcurve(imo(ii+1,jj) - imcin(i+1,j),sigm1,sigm2)...
                                 * expcurve(imo(ii,jj+1) - imcin(i,j+1),sigm1,sigm2) * expcurve(imo(ii+1,jj+1) - imcin(i+1,j+1),sigm1,sigm2);
                            
                            %maybe color weight is better
                            
                            wdis = exp(-((ii - i)^2+(jj-j)^2)/sigm3);
                            
                            wtmp = wcor * wdis * mtmp;

                            imosum(i:i+1,j:j+1) = imosum(i:i+1,j:j+1) + imo(ii:ii+1,jj:jj+1) * wtmp;
                            imowsum(i:i+1,j:j+1) = imowsum(i:i+1,j:j+1) + wtmp;
                        end
                    end
                    if imowsum(i,j)>0
                        imotmp =  imosum(i:i+1,j:j+1) ./ imowsum(i:i+1,j:j+1);
                        %prior 
                        mcortmp = 0.5*(tanh(sigma*((imotmp-knee)))+1);
                        maxdiff = max(max(abs(mcortmp-mcor(i:i+1,j:j+1))));
                        maxdiffall(i:i+1,j:j+1)=maxdiff;
                        blurweight = (maxdiff-0.2)/(0.6-0.2);
                        %blurweight = (maxdiff-0.1)/(0.3-0.1);
                        blurweight(blurweight<0)=0;
                        blurweight(blurweight>1)=1;
                        %blurweight = 0;
                        imo(i:i+1,j:j+1)  = imotmp*(1-blurweight)+imo(i:i+1,j:j+1)*blurweight;  
                    end  
                    if strcmp(cfa,'rggb') || strcmp(cfa,'bggr')
                        imo(i+1,j) = (imo(i+1,j)+imo(i,j+1))/2;
                        imo(i,j+1) = imo(i+1,j);%+randn*20;
                    else
                        imo(i,j) = (imo(i,j)+imo(i+1,j+1))/2;
                        imo(i+1,j+1) = imo(i,j);%+randn*80;
                    end
                    imoy(i:i+1,j:j+1) = mean(mean(imo(i:i+1,j:j+1)));
                    %post maybe      
                end
            end
        end
        % 
        %imcinww = 0;
        imo = imcin.*imcinww + imo.*(1-imcinww);

        if iter==1
            imowb = wb(imo,cfa,awb(1),awb(3),1023);
            imorgb = vcd_demosaic(imowb,cfa);
            figure,imshow((imorgb./1023).^1,'border','tight')
            text(80,80,['ker=[',num2str(kersizerow),',',num2str(kersizecol),'];','iter=1'],'horiz','left','color','r','fontsize',20)
            if writeen
                f = getframe(figure(2));
                imwrite(f.cdata,['E:\ISP\Panting\result\',name,'iter1.bmp'])
            end
        end
        
        % diff = abs(imrgb-imorgb);
        % max(diff(:))

        [imoupmir2,cfa]= mirupbayer(imo,cfa,3);
        imcin = imoupmir2;
        if iter==2
            imoupmir2wb = wb(imoupmir2,cfa,awb(1),awb(3),1023);
            imoupmir2rgb = vcd_demosaic(imoupmir2wb,cfa);
            figure,imshow(imoupmir2rgb./1023,'border','tight'),
            text(80,80,['ker=[',num2str(kersizerow),',',num2str(kersizecol),'];','iter=2'],'horiz','left','color','r','fontsize',20)
            if writeen
                f = getframe(figure(3));
                imwrite(f.cdata,['E:\ISP\Panting\result\',name,'iter2.bmp'])
            end
        end
    end
    if writeen
        close all
    end
end

% %%
% y= -800:100;
% x = y;
% for tmp=x
%     if tmp<0
%        mtmp = (tmp*1/800)^4;
%        %mtmp = (tmp/imoy(i,j))^4;%
%     else
%        mtmp = 0;
%     end
%     mtmp(mtmp<0)=0;
%     mtmp(mtmp>1)=1;
%     y(tmp+801)=mtmp;
% end                         
% figure,plot(x,y)                           
%                             
%                             
% x=-800:200;
% y = expcurve(x,sigm1,sigm2);
% figure,plot(x,y)
% 
% imcinww = (imcinwbmin-998)*0.2/(1020-998)+0.8; 
% 
% ii=-12:12;
% for jj=ii
%     wdis(jj+13) = exp(-((jj)^2*2)/sigm3);
% end
% figure,plot(ii,wdis)
% 
% 
% 
% sigma =1/120;
% knee =600;
% % sigma =1/120;
% mtmpt = 1:1024;
% y = mtmpt;
% y2=y;
% for t=1:1024
%     %mtmpt(t) = 1-1*(tanh(sigma*((t-900)))+1);
%     mtmpt(t) = 0.5*(tanh(sigma*((t-knee)))+1);
% %     y(t) = ((t-900)*sigma)^2;
% %     y2(t) = ((t-900)*sigma)^4;
% end
% figure,plot([1:1024],mtmpt)
% % figure,plot(y)
% % figure,plot(y2)
% 
% x=0:0.1:1;
% bw = (x-0.2)./(0.6-0.2);
% figure,plot(x,bw)
% 
% 
% 
% %%
% knee = 959;%959;
% width = 4032;
% height = 3024;
% cfa = 'rggb';
% %imcin = im10;
% imcin = imbayer/4;
% imcinwb = wb(imcin,cfa,awb(1),awb(3),1023);
% imrgb = vcd_demosaic(imcin,cfa);
% figure,imshow((imrgb./knee).^0.4)
% %figure,imshow(imcin./1023)
% 
% % over exp mask
% knee = 1000;
% immask = zeros(height,width);
% immask(imcin>=knee)=1;
% immask2 = ordfilt2(immask,25,ones(5,5));
% imm = HALF_SCALE_DOWN(immask,1);
% % figure,imshow(immask)
% figure,imshow(imm)
% % immin = HALF_SCALE_DOWN(immask,2);
% % figure,imshow(immin)
% % imm2 = HALF_SCALE_DOWN(immask2,1);
% img = (imcin(1:2:end,2:2:end) + imcin(2:2:end,1:2:end))/2;
% for i=1:2
%     for j=1:2
%         immask(i:2:end,j:2:end) = img;
%     end
% end
% immask(immask<=knee)=0;
% immask(immask>=knee)=1;
% figure,imshow(immask)
% 
% knee = 1022;
% imr = imcin(1:2:end,1:2:end);
% imrmask = immask*0;
% for i=1:2
%     for j=1:2
%         imrmask(i:2:end,j:2:end) = imr;
%     end
% end
% imrmask(imrmask<=knee)=0;
% imrmask(imrmask>=knee)=1;
% figure,imshow(imrmask)
% 
% imb = imcin(2:2:end,2:2:end);
% imbmask = immask*0;
% for i=1:2
%     for j=1:2
%         imbmask(i:2:end,j:2:end) = imb;
%     end
% end
% imbmask(imbmask<=knee)=0;
% imbmask(imbmask>=knee)=1;
% figure,imshow(imbmask)
% 
% 
% %imo2 = imcin;
% %imo2(imm==1)=0;
% %figure,imshow(imo2/959)
% imco =imcin;
% imco(imm==1)=0;
% figure,imshow(imco./knee)
% 
% imco2 =imcin;
% imco2(imm==1)=0;
% imco2(imm2==0)=0;
% figure,imshow(imco2./knee)
% 
% 
% kersize=3;
% imomask = imco2;
% imomask(imomask>0)=1;
% for i=1:2
%     for j=1:2
%         imomask(i:2:end,j:2:end) = conv2(imomask(i:2:end,j:2:end),ones(kersize,kersize),'same');
%     end
% end
% %figure,imshow(imomask)
% imline = imco2;
% for i=1:2
%     for j=1:2
%         imline(i:2:end,j:2:end) = imfilter(imco2(i:2:end,j:2:end),fspecial('average',[kersize,kersize]));
%     end
% end
% imave = imline ./ imomask * kersize*kersize;
% imave(imco2==0)=0;
% figure,imshow(imave./knee)
% 
%%





