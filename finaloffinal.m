%Fresh Start
close all;
clear all;
imtool close all;
clc
cd('C:\Users\SHANKY\Desktop\Masters\565\project\CTcase');
%%
%Read
disp('Choose the image which you want to test')
disp('1.CTcase1 Nodule location 80 166')
disp('2.CTcase2 Nodule location 110 233')
disp('3.CTcase3 Nodule location 57 120')
disp('4.CTcase4 Nodule location 138 87')
disp('5.CTcase5 Nodule location 73 182')
disp('6.CTcase6 Nodule location 78 226')
sw = input('Choose 1 to 6:');
switch (sw)
    case 1 
        fname ='CTcase1.pgm';
    case 2
        fname ='CTcase2.pgm';
    case 3
        fname ='CTcase3.pgm';
    case 4
        fname = 'CTcase4.pgm';
    case 5
        fname = 'CTcase5.pgm';
    case 6
        fname = 'CTcase6.pgm';
    otherwise 
        disp('Invalid Selection')
end
img = imread(fname,'pgm');
img1= imread(fname,'pgm');
imshow(img1)
impixelinfo;
title(fname,'interpreter','none','color',[0 0.7 0])
whos img1
max_level = double(max(img1(:)));
imt =imtool(img1,[0, max_level]);

%%
%mask using otsu
I = im2uint8(img(:));
num_bins = 256;
counts = imhist(I,num_bins);
p = counts / sum(counts);
omega = cumsum(p);
omega1 = 1 - omega;
mu = cumsum(p .* (1:num_bins)');
mu_t = mu(end);
mu0 = mu / omega;
mu1 = (mu_t - mu) / (1 - omega);
sigma_b_squared = (mu_t * omega - mu).^2 ./ (omega .* (1 - omega));
maxval = max(sigma_b_squared); 
idx = mean(find(sigma_b_squared ==maxval));
thresh = (idx - 1) / (num_bins - 1);
mlung = im2bw(img,thresh);
mlung1 = imfill(~mlung,'holes');
mlung1 = bwareaopen(mlung1,100);


%% eliminating background
p=img;
p(~mlung1) = 0;
imshow(p);
title('New Grayscale image');


%%
%edge enhanced using laplacian of gaussian
p1=p;
emlung = fspecial('log',[4 4],0.8);
em = imfilter(p,emlung);
p2=imadd(p1,em);
figure()
imshow(p2);
title('New Edge enhanced image');

%%
%%multithresholding
p3=p2;
thresh =multithresh(p3,2);
p4 = imquantize(p3,thresh);
p4=imerode(p4,strel('ball',3,2)); %rolling ball 
lb=.70;
v=p4;
v(v <=lb) =0;
v=bwmorph(v,'thicken');
v=bwmorph(v,'bridge');
g= bwmorph(v,'open');
g= bwmorph(g,'remove');
figure()
imshow(g);
impixelinfo;
title('Total objects found');


%%
%labelling

tic
[label8, num] = bwlabel(g,8);%labelling using 8 connectivity
toc
tic
label4 =bwlabel(g,4);% labelling using 4 connectivity
toc
tic
advlabel = bwconncomp(g);
toc
conn8=max(max(label8));
conn4=max(max(label4));
disp(conn8)
disp(conn4)
disp('The no of components is reduced in terms of 8 connectivity');


%%
%distance calculation
%feature extraction
%centroid calculation
d=0;
a=0;
    if (fname == 'CTcase1.pgm')
        A=80;
        B=166;
        mar=50;
        miar=15;
        mp=30;
        mip=15;
    elseif (fname=='CTcase2.pgm')
        A=110;
        B=233;
        mar=50;
        miar=20;
        mp=50;
        mip=25;
    elseif (fname=='CTcase3.pgm')
        A=57;
        B=120;
        mar=55;
        miar=10;
        mp=35;
        mip=14;
    elseif (fname=='CTcase4.pgm')
        A=138;
        B=87;
        mar=35;
        miar=10;
        mp=160;
        mip=120;
     elseif (fname=='CTcase5.pgm')
        A=73;
        B=182;
        mar=75;
        miar=50;
        mp=75;
        mip=55;
     elseif (fname=='CTcase6.pgm')
        A=78;
        B=226;
        mar=150;
        miar=120;
        mp=165;
        mip=140;
    end
        
    
for j=1:num;
   
    [row, col] = find(label8==j);
     K = bwboundaries(label8==j);
    P = cell2mat(K(1));
    Perim = 0;
    for i = 1:size(P,1)-1;
        Perim = Perim + sqrt((P(i,1)-P(i+1,1)).^2+(P(i,2)-P(i+1,2)).^2);
    end
    perim(j) = Perim;
    area(j)=(numel(row));
    X=mean(col);
    Y=mean(row);
    Centroid = [X Y];
    dist=round(sqrt((X-A)^2+(Y-B)^2));
    
    if(dist<=10)
        d =j;
        a=area(j);
        per = perim(j);
    end
end
disp('object area is.....');
disp(a);
disp('object  is...');
disp (d);
disp('Object perimeter is...');
disp(per)
figure();
obj_seg = imshow(label8==d);
title('Segmented nodule')
impixelinfo;
 %% Rule based
radi = 100;
figure()
scatter(area,perim,radi,'r');
xlabel('Area');
ylabel('Perimeter');
title('Rule-based Scheme');
sd = 0;
sf =0;
for cv=1:num
    if (area(cv)<mar && area(cv)>miar)
        sd = sd + 1;
    end
    if (perim(cv)<mp && perim(cv)>mip)
        sf = sf+1;
    end
end
disp('number of factors inside the true detection with respect to area is....');
disp(sd);
disp('number of factors inside the true detection with respect to perimeter is....');
disp(sf);
