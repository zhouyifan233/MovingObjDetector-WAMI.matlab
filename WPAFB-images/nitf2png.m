clear

count = 1;
D = dir('WPAFB-images\ntf\WPAFB-21Oct2009-TRAIN_NITF_001\WPAFB-21Oct2009\Data\TRAIN\NITF\*.r1');
for i = 1:size(D, 1)
    filename = D(i).name;
    im = nitfread(['WPAFB-images\ntf\WPAFB-21Oct2009-TRAIN_NITF_001\WPAFB-21Oct2009\Data\TRAIN\NITF\', filename]);
    imwrite(im, ['WPAFB-images\png\WAPAFB_images_train\', sprintf('frame%06d.png', count)]);
    count = count + 1;
    disp(count)
end

D = dir('WPAFB-images\ntf\WPAFB-21Oct2009-TRAIN_NITF_002\WPAFB-21Oct2009\Data\TRAIN\NITF\*.r1');
for i = 1:size(D, 1)
    filename = D(i).name;
    im = nitfread(['WPAFB-images\ntf\WPAFB-21Oct2009-TRAIN_NITF_002\WPAFB-21Oct2009\Data\TRAIN\NITF\', filename]);
    imwrite(im, ['WPAFB-images\png\WAPAFB_images_train\', sprintf('frame%06d.png', count)]);
    count = count + 1;
    disp(count)
end

D = dir('WPAFB-images\ntf\WPAFB-21Oct2009-TRAIN_NITF_003\WPAFB-21Oct2009\Data\TRAIN\NITF\*.r1');
for i = 1:size(D, 1)
    filename = D(i).name;
    im = nitfread(['WPAFB-images\ntf\WPAFB-21Oct2009-TRAIN_NITF_003\WPAFB-21Oct2009\Data\TRAIN\NITF\', filename]);
    imwrite(im, ['WPAFB-images\png\WAPAFB_images_train\', sprintf('frame%06d.png', count)]);
    count = count + 1;
    disp(count)
end

