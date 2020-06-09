% RGB Detection Using MATLAB
%
% Mine KAYA




clear all;
info = imaqhwinfo
info.InstalledAdaptors
info = imaqhwinfo('winvideo');
vid = videoinput('winvideo',1,'YUY2_640x480');
preview(vid);
set(vid,'FramesPerTrigger',Inf);
set(vid,'ReturnedColorSpace','rgb');
vid.FrameGrabInterval = 5;
start(vid);

data = getsnapshot(vid);

while(vid.FramesAcquired<20)

 data = getsnapshot(vid);

 diff_im = imsubtract(data(:,:,1),rgb2gray(data));
 diff_im = medfilt2(diff_im ,[3,3]);
 diff_im  = im2bw(diff_im , 0.18);
 diff_im  = bwareaopen(diff_im ,300);
 bw = bwlabel(diff_im ,8);
 stats = regionprops(bw, 'BoundingBox','Centroid');

 diff_img = imsubtract(data(:,:,2),rgb2gray(data));
 diff_img = medfilt2(diff_img ,[3,3]);
 diff_img  = im2bw(diff_img , 0.18);
 diff_img  = bwareaopen(diff_img ,300);
 bw1 = bwlabel(diff_img ,8);
 stats1 = regionprops(bw1, 'BoundingBox','Centroid');

 diff_imb = imsubtract(data(:,:,3),rgb2gray(data));
 diff_imb = medfilt2(diff_imb ,[3,3]);
 diff_imb  = im2bw(diff_imb , 0.18);
 diff_imb  = bwareaopen(diff_imb ,300);
 bw2 = bwlabel(diff_imb ,8);
 stats2 = regionprops(bw2, 'BoundingBox','Centroid');
 
  % Circularities = Perimeter.^2./(4*pi*FilledArea);
 
 subplot(3,2,1)
 imshow(data);
 title('Orginal Image')

     hold on
     for object = 1:length(stats)
        bb1 = stats(object).BoundingBox;
        bc1 = stats(object).Centroid;
        rectangle('Position',bb1,'EdgeColor','r','LineWidth',2)
        plot(bc1(1),bc1(2), '-m+')
     end
     hold on
     for object = 1:length(stats1)
        bb1 = stats1(object).BoundingBox;
        bc1 = stats1(object).Centroid;
        rectangle('Position',bb1,'EdgeColor','g','LineWidth',2)
        plot(bc1(1),bc1(2), '-m+')
     end
     hold on
     for object = 1:length(stats2)
        bb1 = stats2(object).BoundingBox;
        bc1 = stats2(object).Centroid;
        rectangle('Position',bb1,'EdgeColor','b','LineWidth',2)
        plot(bc1(1),bc1(2), '-m+')
     end
     
     hold off

end
imagegray=rgb2gray(data); 
subplot(3,2,2), imshow(imagegray), title('GrayScale Image');
level=graythresh(imagegray) 
bw=im2bw(imagegray,0.4); 
subplot(3,2,3),imshow(bw), title('Initial (Noisy) Binary Image');

bw=bwareaopen(bw,30);
subplot(3,2,4),imshow(bw),title('Cleaned Binary Image');



[B,L] = bwboundaries(bw,'noholes'),disp(B)
subplot(3,2,5), imshow(label2rgb(L, @jet, [.5 .5 .5])),title('Colorful Background');

hold on
for k = 1:length(B)
  boundary = B{k}; 
  plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
end
fprintf('Objects are marked. Total number of objects=%d\n',k)

stats = regionprops(L,'Area','Centroid'); 
 
% Loop of Counting Objects 
for k = 1:length(B)
 
 
  boundary = B{k};
 
  
  delta_sq = diff(boundary).^2;
  perimeter = sum(sqrt(sum(delta_sq,2)));

  
  area = stats(k).Area;
 
  
  metric = 4*pi*area/perimeter^2;
 
  
  metric_string = sprintf('%2.2f',metric);
  centroid = stats(k).Centroid;
  
  
  if metric > 0.9344
    text(centroid(1),centroid(2),'Circle');
 
  elseif (metric <= 0.8087) && (metric >= 0.7623)
    text(centroid(1),centroid(2),'Rectangle');
  elseif (metric <= 0.7393) && (metric >= 0.7380)
    text(centroid(1),centroid(2),'Rectangle');
  else
     text(centroid(1),centroid(2),'Unknown');
  end
  
end



stop(vid);
flushdata(vid);
clear vid
