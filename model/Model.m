classdef Model < handle 

    properties ( SetAccess = private ) 
        WS Workspace = Workspace.empty 
        ErrorCache Error 
        ThreadPool ThreadPool = ThreadPool()
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

            [home_dir, ~, ~] = fileparts(mdl.WS.DirName);

            [file, path, ~] = uigetfile( ...
                {'*.tif;*.tiff;*.czi', 'Image files' }, ...
                "Select your images", ...
                home_dir, ...
                MultiSelect = "on" ...
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

        function io_process_region(mdl, regions)
            arguments
                mdl Model
                regions (:, 1) Region
            end
            
            mdl.io_cancel_microcount_processes();
            mdl.Futures = repmat(parallel.FevalFuture, size(regions));
            
            for i = 1:numel(regions)
                region = regions(i);
                mdl.io_mark_region_as_processing(region);
                fut = parfeval(@mdl.run_microcount, 1, regions(i));
                mdl.Futures(i) = fut;
            end

            disp(mdl.Futures)
            afterEach(mdl.Futures, @mdl.microcount_complete, 0, "PassFuture", true);
        end

        function io_cancel_microcount_processes(mdl)
            idx = [mdl.Futures.ID] ~= -1;
            active_processes = mdl.Futures(idx);
            for i = 1:numel(active_processes)
                process = mdl.Futures(i);
                region = process.InputArguments{1};
                region.ProcessStatus = ProcessStatus.UNPROCESSED;
            end
            cancel(mdl.Futures(idx));
            mdl.io_save()
            mdl.call_registrars(ModelEvents.WorkspaceUpdated);
        end

    end

    methods (Access = private)

        function io_mark_region_as_processing(mdl, region)
            region.ProcessStatus = ProcessStatus.PROCESSING;
            mdl.io_save()
            mdl.call_registrars(ModelEvents.WorkspaceUpdated)
        end

        function io_downsample_img(mdl, img_md)
            arguments
                mdl Model
                img_md ImageMetadata
            end
            down_fn = img_md.get_down_fn(mdl.WS.DirName);
            RESIZE = 20;
            CHN_BRT = 1;
            pixel_region = { [1 RESIZE img_md.Size(1)], [1 RESIZE img_md.Size(2)] };
            img = imread(img_md.SourceFn, "PixelRegion", pixel_region);
            dn_img = img(:, :, CHN_BRT);
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

        function result = run_microcount(mdl, region)

            arguments
                mdl Model
                region Region
            end

            mask = mdl.Atlas.create_full_size_mask(region);
            file_name_chrs = convertStringsToChars(region.Parent.SourceFn);
            bfr_img = BioformatsImage(file_name_chrs);
            settings = region.get_microcount_settings();
            data = microcount_algo(bfr_img, mask, settings);
            [result, output_img] = data2result(data);
            fn = region.get_processed_img_fn(mdl.WS.DirName);
            imwrite(output_img, fn);
        end

        function microcount_complete(mdl, fut)
            region = fut.InputArguments{1};
            if ~isempty(fut.Error)
                fprintf("Microcount: Region %s stopped after event: %s\n", region.ID, fut.Error.message);
                region.ProcessStatus = ProcessStatus.UNPROCESSED;
            else
                fprintf("Microcount: Region %s completed after: %s\n", region.ID, fut.RunningDuration);
                result = fetchOutputs(fut);
                region.Result = result;
                region.ProcessStatus = ProcessStatus.PROCESSED;
            end

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
