classdef Constants < handle
    properties (Constant)
        DIR_SLUG_CONVERT char = 'ws_converted';
        DIR_SLUG_DOWN char = 'ws_downsampled';
        DIR_SLUG_PROC char = 'ws_processed';
        DIR_SLUG_MASK char = 'ws_masks'
        FILE_WS_MAT char = 'ws.mat';

        PAD (1, 1) uint16 = 100
    end
end