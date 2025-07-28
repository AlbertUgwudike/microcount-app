function [av_scholl_idx, cross_mat] = scholl(l_skelly, l_soma, px_dims, plot_please)
    arguments
        l_skelly, 
        l_soma,
        px_dims (1, 2) double = [1, 1]
        plot_please (1, 1) logical = false
    end

    sz = size(l_skelly);
    idxs = label2idx(l_skelly);

    N = max(l_skelly, [], "all");
    coeffs = zeros(N, 1);
    cross_mat = cell(N, 1);

    for i = 1:N

        [I, J] = ind2sub(sz, idxs{i});
        pts = cat(2, J, I) .* repmat(px_dims, [height(I), 1]);
        com = center_of_mass(l_soma == i) .* px_dims;
        dists = ceil(sqrt(sum((pts - com).^2, 2)));
        max_dist = max(dists);
        radius_bins = 1:max_dist;

        try
            counts = histcounts(dists, BinEdges=1:max_dist+1);
        catch err
%             throw( ...
%                 MException( ...
%                     "scholl:histcounts", ...
%                     sprintf("MaxDist = [%d, %d], N = %d, i = %d, pts = [%d, %d]", px_dims(1), px_dims(2), sum(l_soma, "all"), i, I(1), J(1)) ...
%                 ) ...
%             )
            continue;
        end

        areas = pi * radius_bins.^2;
        y = log10(counts ./ areas);
        ex_idx = y ~= -Inf;
        radii = radius_bins(ex_idx);
        crossings = y(ex_idx);

        mdl = fitlm(radii, crossings);

        coeffs(i) = -mdl.Coefficients.Estimate(2);
        cross_mat{i} = y;
        if plot_please
            subplot(1, 2, 1)
            bbox = bounding_box(l_skelly == i);
            one_skel = imcrop(l_skelly == i, bbox);
            one_soma = imcrop(l_soma == i, bbox);
            imshow(imadjust(one_soma + one_skel));

            subplot(1, 2, 2)
            plot(radii, movmean(counts(ex_idx), 9));
            pause(2);
        end
    end
    av_scholl_idx = mean(coeffs, 'omitnan');
%     disp(coeffs)
end

function pt = center_of_mass(b_img)
    [I, J] = ind2sub(size(b_img), find(b_img));
    pt = round(mean(cat(2, J, I), 1));
end

