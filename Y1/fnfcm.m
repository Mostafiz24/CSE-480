
%     read jpeg image
    im=imread('Y1.jpg');
    I=im;
    im=rgb2gray(im);
    im=imresize(im,[512 512]);


inpput_image=im;
org_img=im;

I1=im;
im=im2double(im);
 subplot(2,2,1);
% % % %the second parameter controls the display range of a grayscale image
imshow(im,[]), title('input image');
j=im;
%%
%mask size 5 x 5
N = 5;
%to retain original size of image even after filtering
im_pad = padarray(j,[floor(N/2) floor(N/2)]);
%sort elements in ascending or descending order to get median
%convert each sliding NxN block of A into a column of B, with no zero padding
%NOTE im_col is not a column matrix it is a rearranged matrix with 2D as in im_pad
im_col = im2col(im_pad,[N N],'sliding');
%sorts each column of im_pad in ascending order still retains 2D
sorted_cols = sort(im_col,1);
%finds median and returns a row martix containing medians for all columns of the input
%B(x,y) returns the element in B at location (x,y); if y is not specified
%it returns the element at position x in column 1; : implies all columns
med_vector = sorted_cols(floor(N*N/2)+1,:);
%convert result to matrix form to get the MEDIAN FILTERED image
out1 = col2im(med_vector,[N N],size(im_pad),'sliding');
figure(1)
 subplot(2,2,2);
 imshow(out1,[]), title('median filtered image');
 %%
% Generate Gaussian mask/kernel
sigma = 2; % Define sigma here; small detects fine features
% one method to create a matrix; ind is a row matrix [-2 -1 0 1 2]
ind = -floor(N/2) : floor(N/2);
% ind=exp(ind);
% create X by repeating ind rowwise and Y by repeating ind columnwise
[X Y] = meshgrid(ind, ind);
% implement Gaussian HP filter formula; h is 5x5
h = exp(-(X.^2 + Y.^2) / (2*sigma*sigma));
% GHPF=1-GLPF
h=1-h;

% Convert filter into a column vector
h = h(:);

% Filter our image
I=out1;
% this conversion is needed because inbuilt command requires compatibility with its arguement; 
% bsxfun requires both C and h to be of the same datatype double
% (convert to higher datatype to prevent data loss) 
I = im2double(I);
I_pad = padarray(I, [floor(N/2) floor(N/2)]);
C = im2col(I_pad, [N N], 'sliding');
% Binary Singleton Expansion Function C = bsxfun(FUNC,A,B) applies the 
% element-by-element binary operation specified by the function to A and B
C_filter = sum(bsxfun(@times, C, h), 1);
% rearranges the row vector B into a matrix of size (MM-M+1)-by-(NN-N+1).
% B must be a vector of size 1-by-(MM-M+1)*(NN-N+1).
out2 = col2im(C_filter, [N N], size(I_pad), 'sliding');
%figure(1)
 %subplot(2,2,3);
% imshow(out2,[]), title('Gaussian filtered image');

workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 24;
%========================================================================

%im = dicomread('i9.dcm');
 % normalize the dicom image to 0-255 range for fast processing
    max_val = max(max(im));
    z = max_val/255;
    im = im./z;
% Get the dimensions of the image.
% numberOfColorBands should be = 1.
[rows, columns, numberOfColorBands] = size(im);

% Display the original gray scale image.
figure(5)
subplot(2, 3, 1);
imshow(im,[]);

title('Original Grayscale Image');
% Crop image to get rid of light box surrounding the image
im = im(3:end-3, 4:end-4);
% Threshold to create a binary image
binaryImage = im > 20;
% Get rid of small specks of noise
binaryImage = bwareaopen(binaryImage, 10);
% Display the original gray scale image.
subplot(2, 3, 3);
imshow(binaryImage,[]);

title('Binary Image');
% Seal off the bottom of the head - make the last row white.
binaryImage(end,:) = true;
% Fill the image
binaryImage = imfill(binaryImage, 'holes');
subplot(2, 3, 4);
imshow(binaryImage,[]);

title('Cleaned Binary Image');
% Erode away 15 layers of pixels.
se = strel('disk', 15, 0);
binaryImage = imerode(binaryImage, se);
subplot(2, 3, 5);
imshow(binaryImage, []);

title('Eroded Binary Image');
% Mask the gray image
finalImage = im; % Initialize.
finalImage(~binaryImage) = 0;
figure(1)
 subplot(2,2,3);
 
imshow(finalImage, []);

title('Skull stripped Image');
 %%
%//Fuzzy c MEANS ALGORITHM
%out2 is double with max value 0.03... out3 is double with max value 255
%so to calculate histogram more accurately in a time efficient manner we
%convert to uint8 with gray level range 0-255
  out2=finalImage;

max_val=max(max(out2));
out3=out2.*(205/max_val);
im=uint8(out3);


im=double(im);
figure(4)
imshow(uint8(im))
[maxX,maxY]=size(im);
IMM=cat(3,im,im);
cc1=8;
cc2=256;

ttFcm=0;
while(ttFcm<15)
    ttFcm=ttFcm+1
    
    c1=repmat(cc1,maxX,maxY);
    c2=repmat(cc2,maxX,maxY);
    if ttFcm==1 
        test1=c1; test2=c2;
    end
    c=cat(3,c1,c2);
    
    ree=repmat(0.000001,maxX,maxY);
    ree1=cat(3,ree,ree);
    
    distance=IMM-c;
    distance=distance.*distance+ree1;
    
    daoShu=1./distance;
    
    daoShu2=daoShu(:,:,1)+daoShu(:,:,2);
    distance1=distance(:,:,1).*daoShu2;
    u1=1./distance1;
    distance2=distance(:,:,2).*daoShu2;
    u2=1./distance2;
      
    ccc1=sum(sum(u1.*u1.*im))/sum(sum(u1.*u1));
    ccc2=sum(sum(u2.*u2.*im))/sum(sum(u2.*u2));
   
    tmpMatrix=[abs(cc1-ccc1)/cc1,abs(cc2-ccc2)/cc2];
    pp=cat(3,u1,u2);
    
    for i=1:maxX
        for j=1:maxY
            if max(pp(i,j,:))==u1(i,j)
                IX2(i,j)=1;
           
            else
                IX2(i,j)=2;
            end
        end
    end

   if max(tmpMatrix)<1
         break;
  else
         cc1=ccc1;
         cc2=ccc2;
        
  end

 for i=1:maxX
       for j=1:maxY
            if IX2(i,j)==2
            IMMM(i,j)=254;
                 else
            IMMM(i,j)=8;
       end
    end
end

%%%%%%%%%%%%%%%%%%
  figure(2);
 
imshow(uint8(IMMM));
tostore=uint8(IMMM);
imwrite(tostore,'fuzzysegmented.jpg');
imwrite(tostore,'Y1_FCM.jpg');

end

 

IMMM=uint8(IMMM);
figure(1)
subplot(2,2,4);
 imshow(IMMM,[]); 
 title('fcm output');
disp('The final cluster centers are');
ccc1
ccc2

%%
% obtaining ROI and NROI
im_bin=im2bw(IMMM);
[r,c]=find(im_bin==1);
rc=[r c];
simg=im;

im=im2uint8(im);
max_val = max(max(simg));
z = max_val/255;
simg = simg./z;
simg=uint8(simg);
orgimg=simg;


for j=1:(numel(rc)/2)
    simg(r(j),c(j))=0;
end
 figure, subplot(2,1,1); 
 imshow(simg,[]), title('NROI-Non region of interest');
nroi_image=simg; 
imwrite(nroi_image,'Y1_FCM_NROI.jpg');
logimg=imsubtract(orgimg,simg);
roi_image=logimg;

 subplot(2,1,2);
 imshow(logimg,[]), title('ROI-region of interest');
 imwrite(roi_image,'Y1_FCM_ROI.jpg');

%%
%area calculation
[h,v]=size(im_bin);
tumour_area=(1/h)*(1/v)*(sum(sum(im_bin)));
display('area of tumour is :');
display (tumour_area);
D.tumour_area=tumour_area;
%%
%pixel calculation
[h,v]=size(im_bin);
number_pixel=(sum(sum(im_bin)));
display('number of pixel in the tumor area :');
display (number_pixel);
D.number_pixel=number_pixel;

%%
%subjective analysis
var1 = edge(im_bin,'canny');
var2 = imfuse(org_img,var1);
fuse_image=var2;
%figure, imshow(var2), title('subjective analysis');


    
    % for jpg images use im2uint8
    ss=im2uint8(logimg);



ss=im2uint8(ss);
seq=reshape(ss,[numel(ss) 1]);
img_hist=zeros(256,1);
for j=1:256
    img_hist(j)=sum(sum(ss==(j-1)));
end
count=img_hist';
count=count+1;
seq1=uint16(seq);
seq1=seq1+1;
code=arithenco(seq1,count);
decode=arithdeco(code,count,length(seq1));
decode=decode-1;
[r c]= size(ss);
img_out=reshape(decode,[r c]);
dc_roi=img_out;
%subplot(2,2,2);
 %imshow(img_out,[]),title('ROI after compression');
y=isequal(img_out,ss);
% display(y);
str3=sprintf('roi_before:roi_after = %f',y);
disp(str3);
%roi compression ratio
r_cr= (r*c*8)/(numel(code));
display(r_cr);
D.r_cr=r_cr;

%%
%roi bits per pixel
r_bpp=8/r_cr;
display(r_bpp);
D.r_bpp=r_bpp;



    simg=uint8(simg);




%%
imwrite(simg,'nroi_after.jpg','Mode','lossy','Quality',80);
n_info=imfinfo('nroi_after.jpg');
o=imread('nroi_after.jpg');
dc_nroi=o;
% subplot(2,2,4);
%imshow(o,[]),title('NROI after compression');
n_cr=(n_info.Height*n_info.Width)/n_info.FileSize;
% str1=sprintf('n_cr is %f',n_cr);
% disp(str1);
display(n_cr);
D.n_cr=n_cr;
n_bpp=8/n_cr;
% str2=sprintf('n_bpp is %f',n_bpp);
% disp(str2);
display(n_bpp);
D.n_bpp=n_bpp;
time=(r*c*8)/(28.4*1024);
D.Time=time;
str3=sprintf('Time taken is %f',time);
disp(str3);
display(time);

figure, imshow(var2), title('subjective analysis');


%%
%feature extraction



    % for jpeg
    glcm1 = graycomatrix(logimg);
    h_entropy = entropy(logimg);

%%

feature = graycoprops(glcm1,{'energy','contrast','homogeneity','correlation'});
display(feature);
D.h_entropy=h_entropy;
D.feature=feature;