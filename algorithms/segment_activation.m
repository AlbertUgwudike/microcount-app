function [BW] = segment_activation(cd68_img, threshold)
    norm_X = log_norm(cd68_img);
    BW = norm_X > threshold;
end

