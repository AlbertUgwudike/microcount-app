classdef MicrocountData
    
    properties
        iba1 uint16
        cd68 uint16
        segmented uint16
        iba1Mask uint16
        cell_areas (:, 1) double
        cd68Mask logical
        poly_mask uint16
        soma_mask logical
        soma_areas (:, 1) double
        skelly logical
        detected logical
        branch_counts (:, 1) uint16
        overlap_pcs double
        nActivated double
        rotundities (:, 1) double
        nMicroglia double
        nPixels double
        mm2_per_pixel double
        um_per_pixel double
        region_acronym (1, :) char
        hemisphere uint16
        brt uint16
        region_mask logical
        branch_lengths cell
        scholl_coeffs double
        dists_img uint16
        scholl_cross_matrix cell
    end
    
    methods
        function data = MicrocountData(args)
            arguments
                args.iba1
                args.cd68
                args.segmented
                args.iba1Mask
                args.cell_areas
                args.cd68Mask
                args.poly_mask
                args.soma_mask
                args.soma_areas
                args.skelly
                args.detected
                args.branch_counts
                args.overlap_pcs
                args.nActivated
                args.rotundities   
                args.nMicroglia  
                args.nPixels        
                args.mm2_per_pixel = -1.0
                args.um_per_pixel = -1.0
                args.region_acronym = 'NONE'
                args.hemisphere = -1
                args.brt = uint16.empty
                args.region_mask = logical.empty
                args.branch_lengths
                args.dists_img
                args.scholl_coeffs
                args.scholl_cross_matrix
            end

            data.iba1           = args.iba1;
            data.cd68           = args.cd68;
            data.segmented      = args.segmented;
            data.iba1Mask       = args.iba1Mask;
            data.cell_areas     = args.cell_areas;
            data.cd68Mask       = args.cd68Mask;
            data.poly_mask      = args.poly_mask;
            data.soma_mask      = args.soma_mask;
            data.soma_areas     = args.soma_areas;
            data.skelly         = args.skelly;
            data.detected       = args.detected;
            data.branch_counts  = args.branch_counts;
            data.overlap_pcs    = args.overlap_pcs;
            data.nActivated     = args.nActivated;
            data.rotundities    = args.rotundities;
            data.nMicroglia     = args.nMicroglia;
            data.nPixels        = args.nPixels;
            data.mm2_per_pixel  = args.mm2_per_pixel;
            data.um_per_pixel   = args.um_per_pixel;
            data.region_acronym = args.region_acronym;
            data.hemisphere     = args.hemisphere;
            data.brt            = args.brt;
            data.region_mask    = args.region_mask;
            data.branch_lengths = args.branch_lengths;
            data.dists_img      = args.dists_img;
            data.scholl_coeffs  = args.scholl_coeffs;
            data.scholl_cross_matrix   = args.scholl_cross_matrix;
        end
    end
end

