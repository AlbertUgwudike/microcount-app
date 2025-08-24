function [result, img, cross_matrix] = data2result(data, type_str)
    arguments
        data MicrocountData
        type_str string = "micro"
    end

    MASK_INTENSITY = 65535;

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
    switch type_str
        case "micro"
            cd68_adj = imadjust(data.cd68, [0.001; 0.005], []);
            iba1_adj = imadjust(data.iba1); %, [0.0714; 0.3392], []);

            poly_mask = data.poly_mask;
            poly_mask = poly_mask * MASK_INTENSITY;

            cd68_perim = bwperim(comboMask);
            cd68_poly = MASK_INTENSITY * uint16(cd68_perim);

            red = iba1_adj + poly_mask;
            red(cd68_perim) = cd68_poly(cd68_perim) / 50;

            green = cd68_adj + poly_mask;
            green(cd68_perim) = cd68_poly(cd68_perim) / 25;

            blue = poly_mask;
            blue(cd68_perim) = cd68_poly(cd68_perim) / 1.4;

            tmp = cat(3, red, green, blue);


        case "dab_micro"
            poly_mask = imdilate(data.poly_mask, strel('disk', 1, 0));
            poly_mask = uint16(label2rgb(poly_mask, 'jet', 'k', 'shuffle')) * 256;
            tmp = uint16(data.cd68) * 64;
            tmp(poly_mask > 0) = poly_mask(poly_mask > 0);

        case "dab_astro"
            poly_mask = imdilate(data.poly_mask, strel('disk', 1, 0));
            poly_mask = uint16(label2rgb(poly_mask, 'jet', 'k', 'shuffle')) * 256;
            tmp = uint16(data.cd68) * 256;
            tmp(poly_mask > 0) = poly_mask(poly_mask > 0);

        case "fluor_astro"
            % --------------------------------------------------
            poly_mask = imdilate(data.poly_mask, strel('disk', 1, 0));
            poly_mask = uint16(label2rgb(poly_mask, 'jet', 'k', 'shuffle')) * 256;
            tmp = uint16(repmat(data.iba1, 1, 1, 3)) * 256;
            tmp(poly_mask > 0) = poly_mask(poly_mask > 0);
            % ------------------------------------------------------------

%             cd68_adj = imadjust(data.cd68, [0.001; 0.005], []);
%             iba1_adj = imadjust(data.iba1); %, [0.0714; 0.3392], []);
%             
%             poly_mask = data.poly_mask;
%             poly_mask = poly_mask * MASK_INTENSITY;
% 
%             cd68_perim = bwperim(comboMask);
%             cd68_poly = MASK_INTENSITY * uint16(cd68_perim);
% 
%             red = iba1_adj + poly_mask;
%             red(cd68_perim) = cd68_poly(cd68_perim) / 50;
% 
%             green = cd68_adj + poly_mask;
%             green(cd68_perim) = cd68_poly(cd68_perim) / 25;
% 
%             blue = poly_mask;
%             blue(cd68_perim) = cd68_poly(cd68_perim) / 1.4;
% 
%             tmp = cat(3, red, green, blue);

        case "fluor_neun"
            poly_mask = imdilate(data.poly_mask, strel('disk', 1, 0));
            poly_mask = uint16(label2rgb(poly_mask, 'jet', 'k', 'shuffle')) * 256;
            tmp = uint16(data.cd68) * 256;
            tmp(poly_mask > 0) = poly_mask(poly_mask > 0);
    end

    img = uint16(tmp);
    cross_matrix = data.cross_matrix;
end

