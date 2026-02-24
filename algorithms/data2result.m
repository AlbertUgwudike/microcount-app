function [result, img, tables] = data2result(data, pixel_dims)
    arguments
        data MicrocountData
        pixel_dims (1, 2) double
    end

    MM2_PER_PIXEL       = prod(pixel_dims) / 1e6;
    UM_PER_PIXEL        = mean(pixel_dims);

    imageArea = data.nPixels * MM2_PER_PIXEL;
    comboMask = (data.segmented > 0) & data.cd68Mask;
    totalActivatedArea = sum(comboMask, 'all') * MM2_PER_PIXEL;
    iba1Area = sum(data.iba1Mask, 'all') * MM2_PER_PIXEL;
    soma_area = sum(data.soma_mask, 'all') * MM2_PER_PIXEL * 1e6;
    total_branches = double(sum(data.detected, 'all'));

    N_branches = sum(cellfun("length", data.branch_lengths));
    total_length = sum(cellfun(@(r) sum(r), data.branch_lengths));

    result = MicrocountResult( ...
        MicrogliaDensity             = perc(data.nMicroglia, imageArea) / 100, ...
        PercentageIba1Area           = perc(iba1Area, imageArea), ...
        PercentageCD68Area           = perc(totalActivatedArea, iba1Area), ...
        PercentageActivatedMicroglia = perc(data.nActivated, data.nMicroglia), ...
        AverageRotundity             = mean(data.rotundities, "omitnan"), ...
        AverageSomaSizeUm            = perc(soma_area, data.nMicroglia) / 100, ...
        AverageBranchCount           = perc(total_branches, data.nMicroglia) / 100, ...
        AverageBranchLengthUm        = (total_length / N_branches) * UM_PER_PIXEL, ...
        AverageSchollIndex           = mean(data.scholl_coeffs, "omitnan") ...
        );

    % -----------------------------------------------------------------
    tables = MicrocountTables( ...
        SchollCoefficients  = data.scholl_coeffs, ...
        CrossMatrix         = data.scholl_cross_matrix, ...
        BranchLengths       = data.branch_lengths, ...
        BranchCounts        = data.branch_counts, ...
        SomaSizes           = data.soma_areas, ...
        Rotundities         = data.rotundities, ...
        CellAreas           = data.cell_areas, ...
        Activations         = reshape(data.overlap_pcs, [], 1) ...
    );
    
    % generate output image -------------------------------------------
    if size(data.iba1, 3) == 3
        iba1_adj = Utility.imadjust_rgb(uint16(data.iba1));
    else
        iba1_adj = imadjust(uint16(data.iba1)); %, [0.0714; 0.3392], []);
        iba1_adj = cat(3, iba1_adj, zeros(size(iba1_adj)), zeros(size(iba1_adj)));
    end

    cd68_adj = imadjust(uint16(data.cd68));
    cd68_adj = repmat(cd68_adj, 1, 1, 3);

    poly_mask = uint16(data.poly_mask);
%     poly_mask = imdilate(poly_mask, strel('disk', 2, 0));
    poly_mask = Utility.color_segmentation(poly_mask);

    cd68_poly = 65535 * repmat(uint16(bwperim(comboMask)), 1, 1, 3);

    iba1_o = iba1_adj;
%     iba1_o(:, :, 1:2) = 0;
    iba1_o(poly_mask > 0) = poly_mask(poly_mask > 0);

    cd68_o = cd68_adj;
    cd68_o(cd68_poly > 0) = cd68_poly(cd68_poly > 0);

    img = { iba1_adj, cd68_adj, poly_mask, cd68_poly, iba1_o, cd68_o };
end

