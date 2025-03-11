classdef Constants < handle
    properties (Constant)
        DIR_SLUG_CONVERT char = 'ws_converted';
        DIR_SLUG_DOWN char = 'ws_downsampled';
        DIR_SLUG_TRANSFORM char = 'ws_transform';
        DIR_SLUG_MASK char = 'ws_masks';
        DIR_SLUG_PROC char = 'ws_processed';
        
        FILE_WS_MAT char = 'ws.mat';
    end
end