classdef Workspace

    properties
        DirName string
        Images (:, 1) ImageMetadata = ImageMetadata.empty
        Algo Algorithm = Algorithm.MicroFluor
    end
    
    methods
        function ws = Workspace(dir_name)
            arguments
                dir_name string
            end

            ws.DirName = dir_name;
        end

    end
end

