function [BW] = segment_activation(cd68_img, threshold, params)
    arguments
        cd68_img
        threshold
        params = []
    end
    norm_X = log_norm(cd68_img, params);
    BW = norm_X > threshold;
end

