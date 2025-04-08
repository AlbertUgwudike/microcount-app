function out = nan_background(img, mask)
    out = img;
    out(~mask) = nan;
end

