function data = algo_single_astro(bfr, mask, settings, params)

    arguments
        bfr BioformatsImage
        mask logical
        settings MicrocountSettings
        params = Utility.empty_params()
    end

    MM2_PER_PIXEL       = prod(bfr.pxSize) / 1e6;
    UM_PER_PIXEL        = mean(bfr.pxSize);
    CD68_SENSITIVITY    = settings.CD68Threshold;
    DENDRITE_THRESHOLD  = settings.Iba1Threshold;
    SOMA_THRESHOLD      = settings.SomaThreshold;
    CHN_IBA1            = settings.ChannelIba1; 

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

    iba1 = Utility.read_tiff(bfr.filename, CHN_IBA1, bbox - [0, 0, 1, 1]);
    
    r_mask = imcrop(mask, bbox - [0, 0, 1, 1]);

    iba1(~r_mask) = 0;

    soma = imopen(iba1 > SOMA_THRESHOLD * 1000, strel('disk', 4, 0));
    soma_mask = bwareafilt(soma, [500, 10000]);

    cd68Mask = iba1 > CD68_SENSITIVITY * 100;
    
    branches = pacefilt(iba1, 21, 5) / 4;
    branches_mask = branches > DENDRITE_THRESHOLD;

    [regions, segmented] = floodfill(soma_mask, branches_mask);
    [rotundities, cell_areas, soma_areas, poly_mask] = rotundity(regions, soma_mask);
    [branch_counts, detected, l_skelly] = count_branches(uint16(segmented));
    [branch_lengths, ~, ~] = branch_length(l_skelly, soma_mask);

    l_soma           = uint16(soma_mask) .* uint16(segmented);
    [coeffs, c_mat]  = scholl(l_skelly, l_soma, bfr.pxSize);

    nMicroglia = max(segmented, [], "all");

    soma_peri = bwperim(soma_mask);
    [rows, cols, ~] = find(soma_peri & l_skelly > 0);
    origins = [rows, cols];
    dists_img = trace_branches(origins, (l_skelly > 0) & ~soma_mask);
    [~, l_branches, ~] = branchlets(dists_img, origins);

    data = MicrocountData( ...
        iba1            = iba1, ...
        cd68            = l_branches, ...
        segmented       = segmented, ...
        iba1Mask        = branches_mask, ...
        cell_areas      = cell_areas, ...
        cd68Mask        = cd68Mask, ...
        rotundities     = rotundities, ...
        detected        = detected, ...
        branch_counts   = branch_counts, ...
        nActivated      = 0, ...
        nMicroglia      = nMicroglia, ...
        nPixels         = n_pixels, ... 
        overlap_pcs     = [], ...
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

