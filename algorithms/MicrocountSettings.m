classdef MicrocountSettings

    properties
        PixelDimensions (1, 2) double
        Iba1Threshold (1, 1) double
        CD68Threshold (1, 1) double
        MaxCD68Size (1, 1) uint32
        MinOverlap (1, 1) double
        ChannelIba1 (1, 1) uint8
        ChannelCD68 (1, 1) uint8
        SomaThreshold (1, 1) double
    end
    
    methods
        function obj = MicrocountSettings(pixel_dims, cell_ch, com_ch, iba1_t, cd68_t, cd68_sz, min_p, soma_t)
            obj.PixelDimensions = pixel_dims;
            obj.Iba1Threshold = iba1_t;
            obj.CD68Threshold = cd68_t;
            obj.MaxCD68Size = cd68_sz;
            obj.MinOverlap = min_p;
            obj.ChannelCD68 = com_ch;
            obj.ChannelIba1 = cell_ch;
            obj.SomaThreshold = soma_t;
        end
    end
end

