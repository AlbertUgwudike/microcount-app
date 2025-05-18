classdef MicrocountSettings

    properties
        Iba1Threshold (1, 1) double
        CD68Threshold (1, 1) double
        MaxCD68Size (1, 1) uint32
        MinOverlap (1, 1) uint32
        ChannelIba1 (1, 1) uint8
        ChannelCD68 (1, 1) uint8
        SomaThreshold (1, 1) double
    end
    
    methods
        function obj = MicrocountSettings(cell_ch, com_ch, iba1_t, cd68_t, cd68_sz, soma_t)
            obj.Iba1Threshold = iba1_t;
            obj.CD68Threshold = cd68_t;
            obj.MaxCD68Size = cd68_sz;
            obj.MinOverlap = 2;
            obj.ChannelCD68 = com_ch;
            obj.ChannelIba1 = cell_ch;
            obj.SomaThreshold = soma_t;
        end
    end
end

