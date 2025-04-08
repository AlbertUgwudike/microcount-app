function [BW] = segment_microglia(X, thresh)

    norm_X = mat2gray(X);

    BW = pacefilt(norm_X, 21, 5) / 4;
    
    radius = 2;
    decomposition = 0;
    se = strel('disk', radius, decomposition);
    BW = imclose(BW, se);

    BW = imadjust(BW) > thresh;

end


