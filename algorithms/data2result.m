function [result, img, cross_matrix] = data2result(data)
    arguments
        data MicrocountData
    end

    imageArea = data.nPixels * data.mm2_per_pixel;
    comboMask = (data.segmented > 0) & data.cd68Mask;
    totalActivatedArea = sum(comboMask, 'all') * data.mm2_per_pixel;
    iba1Area = sum(data.iba1Mask, 'all') * data.mm2_per_pixel;
    soma_area = sum(data.soma_mask, 'all') * data.mm2_per_pixel * 1e6;
    total_branches = double(sum(data.detected, 'all'));

    result = MicrocountResult( ...
        MicrogliaDensity = perc(data.nMicroglia, imageArea) / 100, ...
        PercentageIba1Area = perc(iba1Area, imageArea), ...
        PercentageCD68Area = perc(totalActivatedArea, iba1Area), ...
        PercentageActivatedMicroglia = perc(data.nActivated, data.nMicroglia), ...
        AverageRotundity = perc(data.avRotundity, 1), ...
        AverageSomaSizeUm = perc(soma_area, data.nMicroglia) / 100, ...
        AverageBranchCount = perc(total_branches, data.nMicroglia) / 100, ...
        AverageBranchLengthUm = data.av_length * data.um_per_pixel, ...
        AverageSchollIndex = data.av_scholl_idx ...
    );
    
    % generate output image -------------------------------------------
    iba1_adj = imadjust(uint16(data.iba1)); %, [0.0714; 0.3392], []);
    iba1_adj = repmat(iba1_adj, 1, 1, 3);

    cd68_adj = imadjust(uint16(data.cd68), [0.001; 0.005], []);
    cd68_adj = repmat(cd68_adj, 1, 1, 3);

    poly_mask = uint16(data.poly_mask);
    poly_mask = Utility.color_segmentation(poly_mask);

    cd68_poly = 65536 * repmat(uint16(bwperim(comboMask)), 1, 1, 3);

    img = { iba1_adj, cd68_adj, poly_mask, cd68_poly };

    cross_matrix = data.cross_matrix;
end

