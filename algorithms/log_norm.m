function norm_img = log_norm(X)
    img_vec = reshape(log(double(X) + 1e-10), [], 1);
    norm_img_vec = normalize(img_vec);
    norm_img = reshape(norm_img_vec, size(X));
    norm_img(isnan(norm_img)) = 0;
end

