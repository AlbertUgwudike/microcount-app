function plaque_mask = segment_plaques(plaque_signal, threshold, params)
    arguments
        plaque_signal
        threshold = 0.55
        params = []
    end

    norm_mask = log_norm(plaque_signal, params);

    raw_mask = norm_mask > 1;
    clean_mask = imopen(raw_mask, strel('disk', 5, 0));

    kernel = strel('disk', 100, 0).Neighborhood;
    linked_mask = conv2(double(clean_mask), kernel, 'same');

    plaque_mask = linked_mask > threshold * 1000;
end

