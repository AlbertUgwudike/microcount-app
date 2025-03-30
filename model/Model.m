classdef Model < handle 

    properties ( SetAccess = private ) 
        WS Workspace = Workspace.empty 
        ErrorCache Error 
    end

    properties ( SetAccess = public ) 
        Atlas Atlas = Atlas()
        RegistrarFcns
    end

    methods (Access = public)

        function io_create_workspace(mdl)
            disp("Creating workspace.")

            dir_name = uigetdir('', 'Select Microcount Workspace');

            if dir_name == 0
                mdl.panic(Error.NO_WS_SELECTED)
                return
            end

            if height(dir(dir_name)) > 2
                mdl.panic(Error.WS_NOT_EMPTY)
                return
            end

            dir_name = convertCharsToStrings(dir_name);
            full_path = @(slug) dir_name + "/" + slug;

            ws = Workspace(dir_name);
            save(full_path(Constants.FILE_WS_MAT), 'ws');
            
            mkdir(full_path(Constants.DIR_SLUG_CONVERT));
            mkdir(full_path(Constants.DIR_SLUG_DOWN));
            mkdir(full_path(Constants.DIR_SLUG_PROC));
            mkdir(full_path(Constants.DIR_SLUG_MASK));

            disp("Workspace updated.")
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
                mdl.panic(Error.NOT_WS)
                return
            end

            mdl.WS = ws;
            
            mdl.call_registrars(ModelEvents.WorkspaceUpdated)
        end

        function io_add_image(mdl)
            [file, path, ~] = uigetfile( ...
                {'*.tif;*.tiff;*.czi', 'Image files' }, ...
                "Select your images", ...
                MultiSelect="on" ...
            );

            if isequal(file, 0) || isequal(path, 0)
                mdl.panic(Error.NO_IMG_SELECTED)
                return
            end

            names = convertCharsToStrings(fullfile(path, file))';

            for i = 1:height(names)
                fn = convertCharsToStrings(names(i));
                if ~mdl.is_valid_img(fn)
                    continue
                end
                new_img = ImageMetadata(fn);
                current_img_set = mdl.WS.Images;
                updated_img_set = cat(1, current_img_set, new_img);
                [~, idx, ~] = unique([updated_img_set.ID]);
                mdl.WS.Images = updated_img_set(idx);
            end

            mdl.call_registrars(ModelEvents.WorkspaceUpdated)
        end

        function io_save(mdl)
            ws = mdl.WS;
            save(mdl.WS.DirName + "/" + Constants.FILE_WS_MAT, 'ws');
        end

        function io_convert_and_downsample(mdl)
            for i = 1:height(mdl.WS.Images)

                img = mdl.WS.Images(i);

                if (~img.Converted)
                    mdl.io_convert_img(img)
                end

                if (~img.DownSampled)
                    mdl.io_downsample_img(img)
                end
            end
        end

        function img = io_get_down_img(mdl, img_md)
            arguments
                mdl Model
                img_md ImageMetadata
            end
            img_fn = img_md.get_down_fn(mdl.WS.DirName);
            if ~isfile(img_fn)
                mdl.panic(Error.INVALID_FN)
                img = zeros(10, 10);
                return
            end
            img = imread(img_fn);
        end


        function io_align_image(mdl, img_md, atlas_vertices, hist_vertices, slice_idx)
            arguments
                mdl Model
                img_md ImageMetadata
                atlas_vertices (6, 2) double
                hist_vertices (6, 2) double
                slice_idx (1, 1) double
            end
            img_sz = img_md.TransformationData.ImageSize;
            dir = img_md.TransformationData.Direction;
            tform = fitgeotform2d(atlas_vertices, hist_vertices, 'affine');
            t_data = TransformationData(hist_vertices, atlas_vertices, tform, img_sz, slice_idx, dir);
            img_md.TransformationData = t_data;
            img_md.Aligned = true;
            mdl.io_save()
            mdl.call_registrars(ModelEvents.WorkspaceUpdated)
        end

        function io_rotate_image(mdl, img_md)
            arguments
                mdl Model
                img_md ImageMetadata
            end
            down_fn = img_md.get_down_fn(mdl.WS.DirName);
            img = imread(down_fn);
            r_img = imrotate(img, 90);
            imwrite(r_img, down_fn);
            direction = img_md.TransformationData.Direction;
            img_md.TransformationData.Direction = direction.rotate();
            img_md.TransformationData.ImageSize = flip(img_md.TransformationData.ImageSize);
            mdl.io_save()
            mdl.call_registrars(ModelEvents.WorkspaceUpdated)
        end

        function io_toggle_region(mdl, img_md, laterality, idx)

            arguments
                mdl Model
                img_md ImageMetadata
                laterality Laterality
                idx uint8
            end

            region_key = RegionKey(idx);
            img_md.toggle_region(region_key, laterality);

            if (img_md.region_selected(region_key, laterality))
                region = img_md.get_region(region_key, laterality);
                dn_mask = mdl.Atlas.create_dn_size_mask(region);
                bbox = bounding_box(dn_mask);
                c_mask = imcrop(dn_mask, bbox - [0, 0, 1, 1]);
                mask_fn = region.get_mask_fn(mdl.WS.DirName);
                imwrite(c_mask, mask_fn);
            end

            mdl.io_save()
            mdl.call_registrars(ModelEvents.WorkspaceUpdated);
        end

        function regions = get_all_regions(mdl)
            images = mdl.WS.Images;
            regions = Utility.flatten([images.Regions]);
            if isempty(regions)
                regions = [];
                return
            end
            f_idx = ~cellfun('isempty', regions);
            f_regions = regions(f_idx);
            regions = [f_regions{:}];
        end

        function io_process_region(mdl, region)
            arguments
                mdl Model
                region Region
            end
            fprintf("Processing region: %s\n", region.ID)
            tic
            mask = mdl.Atlas.create_full_size_mask(region);
            file_name_chrs = convertStringsToChars(region.Parent.SourceFn);
            bfr_img = BioformatsImage(file_name_chrs);
            settings = region.get_microcount_settings();
            data = microcount_algo(bfr_img, mask, settings);
            [result, output_img] = data2result(data);
            region.Result = result;
            fn = region.get_processed_img_fn(mdl.WS.DirName);
            imwrite(output_img, fn);
            region.Processed = true;
            toc
            mdl.io_save();
            mdl.call_registrars(ModelEvents.WorkspaceUpdated)
        end

    end

    methods (Access = private)

        function io_downsample_img(mdl, img_md)
            arguments
                mdl Model
                img_md ImageMetadata
            end
            down_fn = img_md.get_down_fn(mdl.WS.DirName);
            RESIZE = 20; % TODO - Allow user selection
            CHN_BRT = 1; % TODO - Allow user selection
            img = imread(img_md.SourceFn, 1);
            img = img(:, :, CHN_BRT);
            new_sz = idivide(uint16(size(img)), uint16(RESIZE));
            dn_img = imresize(img, new_sz);
            imwrite(imadjust(dn_img), down_fn);
            img_md.DownSampled = true;
            mdl.io_save()
            mdl.call_registrars(ModelEvents.WorkspaceUpdated)
        end


        function io_convert_img(mdl, img_md)
            arguments
                mdl Model
                img_md ImageMetadata
            end
            conv_fn = img_md.get_conv_fn(mdl.WS.DirName);
            img = imread(img_md.SourceFn);
            imwrite(img, conv_fn);
            img_md.Converted = true;
            mdl.io_save()
            mdl.call_registrars(ModelEvents.WorkspaceUpdated)
        end

        function is_valid = is_valid_img(mdl, fn)
            % TODO cheap image validation
            is_valid = true;
        end

        function panic(mdl, err_enum)
            mdl.ErrorCache = err_enum;
            mdl.call_registrars(ModelEvents.Error)
        end

        function call_registrars(mdl, event)
            for i = 1:numel(mdl.RegistrarFcns)
                mdl.RegistrarFcns{i}(event)
            end
        end

    end

end
