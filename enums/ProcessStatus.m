classdef ProcessStatus 
    enumeration
        UNPROCESSED
        PROCESSING
        PROCESSED
    end

    methods (Static)
        function markers = to_marker(vec)
            arguments
                vec (:, 1) ProcessStatus
            end
            markers = vec;
        end
    end
end

