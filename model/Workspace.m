classdef Workspace
    %WORKSPACE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        DirName char
        ImageFileNames (:, 1) string = []
    end
    
    methods
        function obj = Workspace(dir_name)
            arguments
                dir_name char
            end

            obj.DirName = dir_name;
        end
    end
end

