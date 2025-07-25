function data = algo_fluor_micro(bfr, mask, settings)

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
    SOMA_THRESHOLD      = settings.SomaThreshold;
    CHN_IBA1            = settings.ChannelIba1; 
    CHN_CD68            = settings.ChannelCD68;

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

    cd68 = getPlane(bfr, 1, CHN_CD68, 1, 'ROI', bbox);
    iba1 = getPlane(bfr, 1, CHN_IBA1, 1, 'ROI', bbox);
    
    r_mask = imcrop(mask, bbox - [0, 0, 1, 1]);

    cd68(~r_mask) = 0;
    iba1(~r_mask) = 0;
 
    tmp       = nan_background(double(cd68), r_mask);
    cd68_mask = uint16(segment_activation(tmp, CD68_SENSITIVITY));
    cd68_mask = filter_size_cd68(cd68_mask, MAX_CD68_SIZE);

    soma_mask = segment_somas(nan_background(double(iba1), r_mask), SOMA_THRESHOLD);
    branches  = segment_microglia(iba1, DENDRITE_THRESHOLD);
    iba1_mask = uint16(soma_mask + branches);

    [regions, segmented]        = floodfill(soma_mask, iba1_mask);
    [av_rotundity, poly_mask]   = rotundity(regions, soma_mask);
    [detected, skelly]          = count_branches(segmented);
    [av_length, dists_img, ~]   = branch_length(skelly, soma_mask);

    l_skelly        = uint16(skelly) .* segmented;
    l_soma          = uint16(soma_mask) .* segmented;
    av_scholl_idx   = scholl(l_skelly, l_soma, bfr.pxSize);

    nMicroglia = max(segmented, [], "all");

    overlap = reshape(segmented .* cd68_mask, 1, []);
    overlap_counts = histcounts(overlap, 1 : nMicroglia + 1);

    all_micro = reshape(segmented, 1, []);
    all_micro_counts = histcounts(all_micro, 1 : nMicroglia + 1);

    overlap_pcs = perc(overlap_counts, all_micro_counts);

    nActivated = sum(overlap_pcs >= CD68_MIN_OVERLAP, "all");

    data = MicrocountData( ...
        iba1            = iba1, ...
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
        skelly          = skelly, ...
        soma_mask       = soma_mask, ...
        mm2_per_pixel   = MM2_PER_PIXEL, ...
        um_per_pixel    = UM_PER_PIXEL, ...
        av_length       = av_length, ...
        dists_img       = dists_img, ...
        av_scholl_idx   = av_scholl_idx, ...
        region_mask     = r_mask ...
    );
end

