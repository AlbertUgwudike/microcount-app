classdef ConvertStatus
    enumeration
        UNCONVERTED
        CONVERTING
        CONVERTED
    end

    methods (Static)
        function markers = to_marker(vec)
            arguments
                vec (:, 1) ConvertStatus
            end
            markers = vec;
        end
    end
end

