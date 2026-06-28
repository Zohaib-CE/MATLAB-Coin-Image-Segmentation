Z = {'coin1.jpg','coin2.jpg','coin3.jpg','coin4.jpg','coin5.jpg','coin6.jpg','coin7.jpg','coin8.jpg','coin9.jpg','coin10.jpg'};

for k = 1:length(Z)

img = imread(Z{k});
img = imresize(img,[400 600]);

gray=rgb2gray(img);
kernel = ones(3,3)/9;

filtered = conv2(double(gray),kernel,'same');
filtered = uint8(filtered);

minVal = double(min(filtered(:)));
maxVal = double(max(filtered(:)));

enhanced = uint8(255 * ((double(filtered)-minVal) / (maxVal-minVal)));

histCounts = zeros(1,256);%Thresholding

for p = 0:255
    histCounts(p+1) = sum(sum(enhanced == p));
end

totalPixels = numel(enhanced);

prob = histCounts / totalPixels;

bestThreshold = 0;
bestVariance = 0;

for t = 1:254

    w0 = sum(prob(1:t));
    w1 = sum(prob(t+1:end));

    if w0 == 0 || w1 == 0
        continue;
    end

    mu0 = sum((0:t-1) .* prob(1:t)) / w0;
    mu1 = sum((t:255) .* prob(t+1:end)) / w1;

    betweenVar = w0 * w1 * (mu0 - mu1)^2;

    if betweenVar > bestVariance
        bestVariance = betweenVar;
        bestThreshold = t;
    end

end

binary1 = double(enhanced > bestThreshold);
binary2 = double(enhanced < bestThreshold);

count1 = sum(binary1(:));
count2 = sum(binary2(:));

if count1 < count2
    binaryImage = binary1;
else
    binaryImage = binary2;
end

                                            % Binary Image Cleaning
binaryImage = bwareaopen(binaryImage,500);

binaryImage = imfill(binaryImage,'holes');

binaryImage = imclearborder(binaryImage);

                                            % Sobel Edge Detection
smoothed = uint8(conv2(double(enhanced),ones(5,5)/25,'same'));

sobelX = [-1 0 1; -2 0 2; -1 0 1];
sobelY = [-1 -2 -1; 0 0 0; 1 2 1];

Gx = conv2(double(smoothed),sobelX,'same');
Gy = conv2(double(smoothed),sobelY,'same');

edgeMagnitude = sqrt(Gx.^2 + Gy.^2);

edges = edgeMagnitude > 180;

                                            % Watershed Segmentation
D = bwdist(~binaryImage);

D = -D;

D = imhmin(D,2);

L = watershed(D);

L(~binaryImage) = 0;

watershedRGB = label2rgb(L,@jet,'k','shuffle');

                                             % Coin Counting
cc = bwconncomp(binaryImage);

stats = regionprops(cc,'Area');

areas = [stats.Area];

numCoins = sum(areas >5000);

                                              % Display Results
figure('Name',['Image ' num2str(k)],'NumberTitle','off');

subplot(2,3,1);
imshow(img);
title('Original Image');

subplot(2,3,2);
imshow(gray);
title('Grayscale Image');

subplot(2,3,3);
imshow(enhanced);
title('Preprocessed Image');

subplot(2,3,4);
imshow(binaryImage);
title(['Threshold Result T = ' num2str(bestThreshold)]);

subplot(2,3,5);
imshow(edges);
title('Sobel Edge Detection');

subplot(2,3,6);
imshow(watershedRGB);
title(['Coins = ' num2str(numCoins)]);

sgtitle(['Processing : ' Z{k}]);

end