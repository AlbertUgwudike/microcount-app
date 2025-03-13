classdef Model < handle 

    properties ( SetAccess = private ) 
        WS Workspace = Workspace.empty 
        ErrorCache Error 
    end

    events ( NotifyAccess = private ) 
        DataChanged
        Error
    end

    methods

        function io_create_workspace(mdl)
            disp("creating workspace...")

            dir_name = uigetdir('', 'Select Microcount Workspace');

            if dir_name == 0
                mdl.panic(Error.NO_WS_SELECTED)
                return
            end

            if height(dir(dir_name)) > 2
                mdl.panic(Error.WS_NOT_EMPTY)
                return
            end

            ws = Workspace(dir_name);
            save([dir_name '/' Constants.FILE_WS_MAT], 'ws');
            
            mkdir([dir_name '/' Constants.DIR_SLUG_CONVERT]);
            mkdir([dir_name '/' Constants.DIR_SLUG_DOWN]);
            mkdir([dir_name '/' Constants.DIR_SLUG_TRANSFORM]);
            mkdir([dir_name '/' Constants.DIR_SLUG_MASK]);
            mkdir([dir_name '/' Constants.DIR_SLUG_PROC]);

            notify(mdl, 'DataChanged')
            
        end

        function io_load_workspace(mdl)
            disp("loading workspace...")

            dir_name = uigetdir('', 'Select Microcount Workspace');
            ws_name = [dir_name '/' Constants.FILE_WS_MAT];

            if ~isfile(ws_name) 
                mdl.panic(Error.NO_WS_FILE)
                return
            end

            try
                obj = load(ws_name);
            catch err
                mdl.panic(Error.NOT_MAT)
                return
            end

            try 
                ws = obj.ws;
            catch err
                mdl.panic(Error.NO_WS_FIELD)
                return
            end

            if class(ws) ~= "Workspace"
                panic(Error.NOT_WS)
            end

            mdl.WS = ws;
            
            notify(mdl, 'DataChanged')
        end

        function io_add_image(mdl)
            [file, path, ~] = uigetfile( ...
                {'*.tif;*.tiff;*.czi', 'Image files' }, ...
                "Select your images", ...
                MultiSelect="on" ...
            );

            names = convertCharsToStrings(fullfile(path, file))';
            new_set = unique(cat(1, comp.CurrentWorkspaceData.ImageFileNames, names));
            
            mdl.WS.Images
            %% ----------------------  BOOKMARK -------------------------- %%
            % trigger UI updates
            comp.CurrentWorkspaceData.ImageFileNames = new_set;
        end

        function panic(mdl, err_enum)
            mdl.ErrorCache = err_enum;
            notify(mdl, 'Error')
        end

    end

end
