function data = algo_fluor_neun(bfr, mask, settings)

    arguments
        bfr BioformatsImage
        mask logical
        settings MicrocountSettings
    end

    MM2_PER_PIXEL       = prod(bfr.pxSize) / 1e6;
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

    pixel_region = { 
        [bbox(2), (bbox(2) + bbox(4) - 1)];
        [bbox(1), (bbox(1) + bbox(3) - 1)]
    };
    
    r_mask = imcrop(mask, bbox - [0, 0, 1, 1]);

    img = imread(bfr.filename, PixelRegion=pixel_region);

    nucs = img(:, :, 2);
    cd68 = img(:, :, 3);

    cd68(~r_mask) = 0;
    nucs(~r_mask) = 0;

    nucs_segmented = skidaddle(nucs);
    cd68_segmented = skidaddle(cd68);

    cd68_mask = cd68_segmented > 0;

    poly_mask = bwperim(nucs_segmented);

    [detected, skelly] = count_branches(nucs_segmented);

    nMicroglia = max(nucs_segmented, [], "all");

    overlap = reshape(nucs_segmented .* cd68_mask, 1, []);
    overlap_counts = histcounts(overlap, 1 : nMicroglia + 1);

    all_micro = reshape(nucs_segmented, 1, []);
    all_micro_counts = histcounts(all_micro, 1 : nMicroglia + 1);

    overlap_pcs = perc(overlap_counts, all_micro_counts);

    nActivated = sum(overlap_pcs >= CD68_MIN_OVERLAP, "all");

    data = MicrocountData( ...
        iba1            = nucs, ...
        cd68            = nucs, ...
        segmented       = nucs_segmented, ...
        iba1Mask        = nucs_segmented > 0, ...
        cd68Mask        = cd68_mask, ...
        avRotundity     = 0.5, ...
        detected        = detected, ...
        nActivated      = nActivated, ...
        nMicroglia      = nMicroglia, ...
        nPixels         = n_pixels, ...
        overlap_pcs     = overlap_pcs, ...
        poly_mask       = poly_mask, ...
        skelly          = skelly, ...
        soma_mask       = nucs_segmented > 0, ...
        mm2_per_pixel   = MM2_PER_PIXEL, ...
        region_mask     = r_mask ...
    );
end

function segmented = skidaddle(img)

    img = log_norm(img);
    img = mat2gray(img, [0, 1.5]);
    img = uint16(65536 * img);

    [c_mask, centers] = segment_neun(img);

    rows = centers(:, 1);
    cols = centers(:, 2);
    idxs = round(sub2ind(size(img), rows, cols));

    center_mask = zeros(size(img));
    center_mask(idxs) = 1;

    segmented = watershed(2 - (c_mask + center_mask));
    segmented(~c_mask) = 0;
end

