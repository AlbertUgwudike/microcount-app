function [result, img] = data2result(data)
    arguments
        data MicrocountData
    end

    MASK_INTENSITY = 65535;

    imageArea = data.nPixels * data.mm2_per_pixel;
    comboMask = data.iba1Mask & data.cd68Mask;
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
        AverageBranchCount = perc(total_branches, data.nMicroglia) / 100 ...
    );
    
    % generate output image -------------------------------------------
    
    cd68_adj = imadjust(data.cd68, [0.001; 0.005], []);
    iba1_adj = imadjust(data.iba1); %, [0.0714; 0.3392], []);

    % left = zeros([size(data.cd68), 3]);
    % left(:, :, 1) = iba1_adj;
    % left(:, :, 2) = cd68_adj;

    right = zeros([size(data.cd68), 3]);
    right(:, :, 1) = iba1_adj;
    right(:, :, 2) = cd68_adj .* uint16(comboMask);
    right(:, :, 3) = data.poly_mask * MASK_INTENSITY;

    % img = uint16(cat(2, left, right));
    img = uint16(right);
end

