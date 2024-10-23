img = imread ('test_image.jpg'); 
I = rgb2gray (img); 

%making a gaussian kernel 
sigma = 1 ; %standard deviation of distribution 

kernel = zeros (5,5); %for a 5x5 kernel 
W = 0 ; 
for i = 1:5 
    for j = 1:5 
        sq_dist = (i-3)^2 + (j-3)^2 ; 
        kernel (i,j) = exp (-1*exp(sq_dist)/(2*sigma));
        W = W + kernel (i,j) ; 
    end 
end 
kernenl = kernel/W ;    
%Now we apply the filter to the image 
[m,n]  = size (I) ; 
output = zeros (m,n); 
Im = padarray (I , [2 2]); 
for i=1:m 
    for j=1:n 
    temp = Im (i:i+4 , j:j+4);
    temp = double(temp);
    conv = temp.*kernel; 
    output(i,j) = sum(conv(:)); 
    end 
end 

output = uint8(output);
%--------------Binary image-------------
level = graythresh(output); 
c= im2bw (output,level); 
%---------------------------------------
output2 = edge (c , 'canny',level);

figure (1); 

%Segment out the region of interest
ROI = output2; 
CannyROI = edge (ROI , 'canny',.45);
%----------------------------------

set (gcf, 'Position', get (0,'Screensize')); 
%subplot (141), imshow (I), title ('original image'); 
%subplot (142), imshow (c), title ('Binary image');
%subplot (143), imshow (output2), title ('Canny image');
%subplot (144), imshow (CannyROI), title ('ROI image');
[H ,T ,R] = hough(CannyROI); 
imshow (H,[],'XData',T,'YData',R,'initialMagnification','fit');
xlabel('\theta'), ylabel('\rho'); 
axis on , axis normal, hold on ; 
P = houghpeaks(H,5,'threshold',ceil (0.3*max(H(:))));
x = T(P(:,2));
y = R(P(:,1));
plot (x,y,'s','color','white');

%Find lines and plot them 
lines = houghlines (CannyROI,T,R,P,'FillGap',5,'MinLength',7);
figure, imshow (img), hold on 
max_len = 0 ; 
for k = 1:length(lines);
    xy = [lines(k).point1; lines(k).point2];
    plot (xy(:,1), xy(:,2), 'LineWidth', 5 , 'Color', 'blue');

%plot beginnings and ends of the lines 
plot (xy(1,1), xy(1,2),'x', 'LineWidth', 2, 'Color', 'yellow');
plot (xy(2,1), xy(2,2),'x', 'LineWidth', 2, 'Color', 'red');

%determine the endpoints of the longest line segment
len = norm(lines(k).point1 - lines(k).point2); 
if (len>max_len)
    max_len = len; 
    xy_long = xy; 
    end 
end 
