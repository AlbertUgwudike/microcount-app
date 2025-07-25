classdef Constants < handle
    properties (Constant)
        DIR_SLUG_CONVERT char = 'ws_converted';
        DIR_SLUG_DOWN char = 'ws_downsampled';
        DIR_SLUG_PROC char = 'ws_processed';
        DIR_SLUG_MASK char = 'ws_masks'
        FILE_WS_MAT char = 'ws.mat';

        PAD (1, 1) uint16 = 100

        REG_ERROR char = 'Registration failed because optimization diverged. Try reducing the InitialRadius property of the optimizer.';

        LABEL_CELL_AREA = "Cell Area (%)";
        LABEL_CELL_DENSITY = "Cell Density";
        LABEL_CO_AREA = ["CoMarker","(% Area)"];
        LABEL_CO_NUM = ["CoMarker", "(% Number)"];
        LABEL_BRANCH = "Branch Points";
        LABEL_LENGTH = "Branch Length";
        LABEL_CONVEXITY = "Convexity";
        LABEL_SCHOLL = "Scholl Index"

    end
end