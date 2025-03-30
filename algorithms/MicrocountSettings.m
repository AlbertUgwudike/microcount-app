classdef MicrocountSettings

    properties
        Iba1Threshold (1, 1) double
        CD68Threshold (1, 1) double
        MaxCD68Size (1, 1) uint32
        MinOverlap (1, 1) uint32
        ChannelIba1 (1, 1) uint8
        ChannelCD68 (1, 1) uint8
    end
    
    methods
        function obj = MicrocountSettings(iba1_t, cd68_t, cd68_sz)
            obj.Iba1Threshold = iba1_t;
            obj.CD68Threshold = cd68_t;
            obj.MaxCD68Size = cd68_sz;
            obj.MinOverlap = 5000;
            obj.ChannelCD68 = 2;
            obj.ChannelIba1 = 3;
        end
    end
end

