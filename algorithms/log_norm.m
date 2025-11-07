function [norm_img, C, S] = log_norm(X, params)
    arguments
        X
        params = []
    end
    img_vec = reshape(log(double(X) + 1e-10), [], 1);

    if isempty(params)
        [norm_img_vec, C, S] = normalize(img_vec);
    else
        C = params(1);
        S = params(2);
        norm_img_vec = (img_vec - C) ./ S;
    end
    norm_img = reshape(norm_img_vec, size(X));
    norm_img(isnan(norm_img)) = 0;
end

