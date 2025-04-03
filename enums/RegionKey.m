classdef RegionKey < uint8
    enumeration
        HIP   (1)
        HY    (2)
        TH    (3)
        SS    (4)
        AUD   (5)
        CTXsp (6)
        HEMI  (7)
    end
    methods
        function val = key2val(rk)
            val = uint8(rk);
        end
    end
end

