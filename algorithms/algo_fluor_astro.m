function [data, c_mat] = algo_fluor_astro(bfr, mask, settings)

    arguments
        bfr BioformatsImage
        mask logical
        settings MicrocountSettings
    end
    MM2_PER_PIXEL       = prod(bfr.pxSize) / 1e6;
    UM_PER_PIXEL        = mean(bfr.pxSize);
    MAX_CD68_SIZE       = settings.MaxCD68Size;
    CD68_SENSITIVITY    = settings.CD68Threshold;
    CD68_MIN_OVERLAP    = settings.MinOverlap;
    DENDRITE_THRESHOLD  = settings.Iba1Threshold;
    % SOMA_THRESHOLD      = settings.SomaThreshold;
    CoMarkerChannel     = settings.ChannelCD68;
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

    scale_f = 65535;
    im_fn = bfr.filename;
    img = imread(im_fn, Index=CellMarkerChannel, PixelRegion=pixel_region);
    disp(class(img))
    filt_img = img;
    scl_img = double(filt_img) / scale_f;
    nan_img = nan_background(scl_img, r_mask);
    norm_img = log_norm(nan_img);
    iba1 = mat2gray(norm_img, [-2, 2]);

%     imshow(erode_mask)
%     figure()

    p_out = log_norm(pacefilt(iba1, 21, 5) / 4);

    branches = p_out > DENDRITE_THRESHOLD;

    cd68 = imread(im_fn, Index=CoMarkerChannel, PixelRegion=pixel_region);
    cd68(~r_mask) = 0;
    tmp = nan_background(double(cd68), r_mask);
    cd68_mask = uint16(segment_activation(tmp, CD68_SENSITIVITY));
    cd68_mask = filter_size_cd68(cd68_mask, MAX_CD68_SIZE);

    % ------------ Segment Somas --------------------

    mask = img > 150;
    mask = imfill(mask, "holes");
    soma_mask = imopen(mask, strel('disk', 5, 0));

    % -----------------------------------------------

    iba1_mask = uint16(soma_mask + branches);
    [regions, segmented] = floodfill(soma_mask, iba1_mask);

    % Segment and count -----------------------------------------

    [av_rotundity, poly_mask]   = rotundity(regions, soma_mask);
    [detected, l_skelly]        = count_branches(segmented);
    [av_length, dists_img, ~]   = branch_length(l_skelly, soma_mask);

    l_soma          = uint16(soma_mask) .* segmented;
    [av_si, c_mat]  = scholl(l_skelly, l_soma, bfr.pxSize);

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
        cd68Mask        = cd68_mask, ...
        avRotundity     = av_rotundity, ...
        detected        = detected, ...
        nActivated      = nActivated, ...
        nMicroglia      = nMicroglia, ...
        nPixels         = n_pixels, ...
        overlap_pcs     = overlap_pcs, ...
        poly_mask       = poly_mask, ...
        skelly          = l_skelly, ...
        soma_mask       = soma_mask, ...
        mm2_per_pixel   = MM2_PER_PIXEL, ...
        um_per_pixel    = UM_PER_PIXEL, ...
        av_length       = av_length, ...
        dists_img       = dists_img, ...
        av_scholl_idx   = av_si, ...
        cross_matrix    = c_mat, ...
        region_mask     = r_mask ...
    );

end

