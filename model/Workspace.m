classdef Workspace

    properties
        DirName char
        Images (:, 1) ImageMetadata = []
    end
    
    methods
        function ws = Workspace(dir_name)
            arguments
                dir_name char
            end

            ws.DirName = dir_name;
        end
        
    end
end

