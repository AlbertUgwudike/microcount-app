function data = algo_dab_micro(bfr, mask, settings, params)

    arguments
        bfr BioformatsImage
        mask logical
        settings MicrocountSettings
        params = []
    end
    MM2_PER_PIXEL       = prod(settings.PixelDimensions) / 1e6;
    UM_PER_PIXEL        = mean(settings.PixelDimensions);
    MAX_CD68_SIZE       = settings.MaxCD68Size;
    CD68_SENSITIVITY    = settings.CD68Threshold;
    CD68_MIN_OVERLAP    = settings.MinOverlap;
    DENDRITE_THRESHOLD  = settings.Iba1Threshold;
    SOMA_THRESHOLD      = settings.SomaThreshold;
    CellMarkerChannel   = settings.ChannelIba1;
    

    % Crop region -----------------------------------------------
    
    bbox = bounding_box(mask);
    n_pixels = numel(find(mask));

    if n_pixels == 0
        ME = MException('microcount_v3:error', "Null Area");
        throw(ME)
    end

    if n_pixels < 4000000
        fprintf("WARNING: Small Image %i X %i\n", bbox(3), bbox(4));
    end

    pixel_region = { 
        [bbox(2), (bbox(2) + bbox(4) - 1)];
        [bbox(1), (bbox(1) + bbox(3) - 1)]
    };

    % -----------------------

    r_mask = imcrop(mask, bbox - [0, 0, 1, 1]);
    img = imread(bfr.filename, PixelRegion=pixel_region);
    min_img = min(img, [], 3);
    scl_img = double(min_img) / 65535;
    nan_img = nan_background(scl_img, r_mask);

    if isempty(params)
        norm_img = log_norm(nan_img);
    else
        norm_img = log_norm(nan_img, params.FirstParam);
    end


    adj_img = mat2gray(norm_img, [-2.5, 3.0]);
    iba1 = 1 - adj_img;
    iba1(~r_mask) = 0;

    if isempty(params)
        p_out = log_norm(pacefilt(iba1, 21, 5) / 4);
    else
        p_out = log_norm(pacefilt(iba1, 21, 5) / 4, params.SecondParam);
    end

    branches = p_out > DENDRITE_THRESHOLD; % 0.5

    % ------------ Segment Activation --------------------
    cd68 = uint16(zeros(size(iba1)));
    cd68(~r_mask) = 0;
    
    % ------------ Segment Somas --------------------
    soma_mask = iba1 >= SOMA_THRESHOLD; % 0.9
    soma_mask = bwareafilt(soma_mask, [1000, 100000]);
    % soma_mask = bwareafilt(soma_mask, [200, 1000]);
    soma_mask = imopen(soma_mask, strel('disk', 5, 0));
    % -----------------------------------------------

    iba1_mask = uint16(soma_mask + branches);
    [regions, segmented] = floodfill(soma_mask, iba1_mask);

    % Segment and count -----------------------------------------
 
    tmp = nan_background(double(cd68), r_mask);
    cd68_mask = uint16(segment_activation(tmp, CD68_SENSITIVITY));
    cd68_mask = filter_size_cd68(cd68_mask, MAX_CD68_SIZE);

    [rotundities, cell_areas, soma_areas, poly_mask] = rotundity(regions, soma_mask);
    [branch_counts, detected, l_skelly] = count_branches(segmented);
    [branch_lengths, dists_img, ~] = branch_length(l_skelly, soma_mask);

    l_soma           = uint16(soma_mask) .* segmented;
    [coeffs, c_mat]  = scholl(l_skelly, l_soma, settings.PixelDimensions);

    nMicroglia = max(segmented, [], "all");

    overlap = reshape(segmented .* cd68_mask, 1, []);
    overlap_counts = histcounts(overlap, 1 : nMicroglia + 1);

    all_micro = reshape(segmented, 1, []);
    all_micro_counts = histcounts(all_micro, 1 : nMicroglia + 1);

    overlap_pcs = perc(overlap_counts, all_micro_counts);

    nActivated = sum(overlap_pcs >= CD68_MIN_OVERLAP, "all");

    data = MicrocountData( ...
        iba1            = img, ...
        cd68            = cd68, ...
        segmented       = segmented, ...
        iba1Mask        = iba1_mask, ...
        cell_areas      = cell_areas, ...
        cd68Mask        = cd68_mask, ...
        rotundities     = rotundities, ...
        detected        = detected, ...
        branch_counts   = branch_counts, ...
        nActivated      = nActivated, ...
        nMicroglia      = nMicroglia, ...
        nPixels         = n_pixels, ... 
        overlap_pcs     = overlap_pcs, ...
        poly_mask       = poly_mask, ...
        skelly          = l_skelly, ...
        soma_mask       = soma_mask, ...
        soma_areas      = soma_areas, ...
        mm2_per_pixel   = MM2_PER_PIXEL, ...
        um_per_pixel    = UM_PER_PIXEL, ...
        branch_lengths  = branch_lengths, ...
        dists_img       = dists_img, ...
        scholl_cross_matrix  = c_mat, ...
        region_mask     = r_mask, ...
        scholl_coeffs   = coeffs ...
    );
end