

fn = "/Volumes/Undergrad/Vanessa Drevenakova/DAB/Vanessa Drevenakova/2024_06_07_14_20_50--Parameter testing DAB Iba1 - 24_5_16-1/Sequence 001/24_5-16-1.2.ome.tiff";

pixel_region = { [10000 11000], [10000 11000]};

img = imread(fn, 'PixelRegion', pixel_region);

imshow(img * 64)
