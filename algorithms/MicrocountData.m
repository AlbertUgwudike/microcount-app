classdef MicrocountData
    
    properties
        iba1 uint16
        cd68 uint16
        segmented uint16
        iba1Mask uint16
        cd68Mask logical
        poly_mask uint16
        soma_mask logical
        skelly logical
        detected logical
        overlap_pcs double
        nActivated double
        avRotundity double
        nMicroglia double
        nPixels double
        mm2_per_pixel double
        um_per_pixel double
        region_acronym (1, :) char
        hemisphere uint16
        brt uint16
        region_mask logical
        av_length double
        av_scholl_idx double
        dists_img uint16
    end
    
    methods
        function data = MicrocountData(args)
            arguments
                args.iba1
                args.cd68
                args.segmented
                args.iba1Mask
                args.cd68Mask
                args.poly_mask
                args.soma_mask
                args.skelly
                args.detected
                args.overlap_pcs
                args.nActivated
                args.avRotundity   
                args.nMicroglia  
                args.nPixels        
                args.mm2_per_pixel = -1.0
                args.um_per_pixel = -1.0
                args.region_acronym = 'NONE'
                args.hemisphere = -1
                args.brt = uint16.empty
                args.region_mask = logical.empty
                args.av_length
                args.dists_img
                args.av_scholl_idx
            end

            data.iba1           = args.iba1;
            data.cd68           = args.cd68;
            data.segmented      = args.segmented;
            data.iba1Mask       = args.iba1Mask;
            data.cd68Mask       = args.cd68Mask;
            data.poly_mask      = args.poly_mask;
            data.soma_mask      = args.soma_mask;
            data.skelly         = args.skelly;
            data.detected       = args.detected;
            data.overlap_pcs    = args.overlap_pcs;
            data.nActivated     = args.nActivated;
            data.avRotundity    = args.avRotundity;
            data.nMicroglia     = args.nMicroglia;
            data.nPixels        = args.nPixels;
            data.mm2_per_pixel  = args.mm2_per_pixel;
            data.um_per_pixel   = args.um_per_pixel;
            data.region_acronym = args.region_acronym;
            data.hemisphere     = args.hemisphere;
            data.brt            = args.brt;
            data.region_mask    = args.region_mask;
            data.av_length      = args.av_length;
            data.dists_img      = args.dists_img;
            data.av_scholl_idx  = arg.av_scholl_idx;
        end
    end
end

