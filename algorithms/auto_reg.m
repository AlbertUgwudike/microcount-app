function tform = auto_reg(atlas_slice, histology_slice)

    % histology_slice = adapthisteq(histology_slice, "ClipLimit", 0.1);
    % histology_slice = padarray(histology_slice, [pad, pad], 0);

    [optimizer, metric] = imregconfig('multimodal');
    optimizer.MaximumIterations = 500; %500
    optimizer.GrowthFactor = 1.0001; %1+1e-3; %1.001
    optimizer.InitialRadius = 0.001; %1e-3; %0.001

    % Resize atlas outline to approximately match histology, affine-align
    resize_factor = min(size(histology_slice) ./ size(atlas_slice));
    atlas_slice_resize = imresize(atlas_slice, resize_factor, 'nearest');

    % Do alignment on downsampled sillhouettes (faster and more accurate)
    if min([size(atlas_slice_resize) size(histology_slice)]) < 100
        dnsmpl = 1;
    else
        dnsmpl = 5;
    end

    dnsmpl_atlas_slice = imresize(atlas_slice_resize, 1 / dnsmpl, 'nearest');
    dnsmpl_hist_slice = imresize(histology_slice, 1 / dnsmpl,'nearest');

    tform = imregtform( ...
        dnsmpl_atlas_slice, ...
        dnsmpl_hist_slice, ...
        'affine', ...
        optimizer, ...
        metric, ...
        PyramidLevels = 3 ...
    );

    % Set final transform (scale to histology, downscale, affine, upscale)
    scale_match      = eye(3) .* [repmat(resize_factor,2,1); 1];
    scale_align_down = eye(3) .* [repmat(1 / dnsmpl, 2, 1);  1];
    scale_align_up   = eye(3) .* [repmat(dnsmpl, 2, 1);      1];

    tform.T = scale_match * scale_align_down * tform.T * scale_align_up;

    disp(tform.T)
end

