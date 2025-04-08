function out_img = imcrop(img, n)
    [H, W] = size(img);
    out_img = img(n + 1 : H - n, n + 1 : W - n);
end

