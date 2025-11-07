function [BW] = segment_microglia(X, thresh, params)

    if isempty(params)
        disp("Auto gray!")
        norm_X = mat2gray(X);
    else
        disp("Manual gray!")
        norm_X = mat2gray(X, params(3:4));
    end

    BW = pacefilt(norm_X, 21, 5) / 4;
    
    radius = 2;
    decomposition = 0;
    se = strel('disk', radius, decomposition);
    BW = imclose(BW, se);

    BW = imadjust(BW, params(5:6)) > thresh;

end


