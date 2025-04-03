classdef Orientation < uint8
    enumeration
        Axial    (0)
        Sagittal (1)
        Coronal  (2)
    end

    methods
        function new_ori = cycle(ori)
            new_ori = Orientation(mod(ori+ 1, 3));
        end
    end
end

