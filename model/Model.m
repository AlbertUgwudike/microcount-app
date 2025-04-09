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
                % if ~mdl.is_valid_img(fn)
                %     continue
                % end
                new_img = ImageMetadata(fn, mdl.WS.DirName);
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

        function io_remove_images(mdl, idx)
            all_idx = true(1, numel(mdl.WS.Images));
            all_idx(idx) = false;
            mdl.WS.Images = mdl.WS.Images(all_idx);
            mdl.save_and_update();
        end

        function update_channel_order(mdl, idx, ch_str)
            img_md = mdl.WS.Images(idx);
            if ImageMetadata.valid_channel_order_str(ch_str, img_md.ChannelCount)
                img_md.set_channel_order_str(ch_str)
            end
            mdl.save_and_update();
        end

        function update_channel_names(mdl, idx, ch_str)
            img_md = mdl.WS.Images(idx);
            if ImageMetadata.valid_channel_names_str(ch_str, img_md.ChannelCount)
                img_md.set_channel_names_str(ch_str)
            end
            mdl.save_and_update();
        end

        function io_convert_and_downsample(mdl, idx)
            for i = 1:numel(idx)
                img = mdl.WS.Images(idx(i));
                if (img.ConvertStatus == ConvertStatus.CONVERTED)
                    continue
                end
                mdl.io_mark_image_as_converting(img);
                mdl.ThreadPool.dispatch(@Model.bg_conv_down_img, img, @mdl.bg_conv_down_img_complete)
            end
        end

        function img = io_get_down_img(mdl, img_md)
            arguments
                mdl Model
                img_md ImageMetadata
            end
            if ~isfile(img_md.DownFn)
                mdl.panic(Error.INVALID_FN)
                img = zeros(10, 10);
                return
            end
            img = uint16(imread(img_md.DownFn));
            if ~isempty(img_md.TransformationData)
                img = imrotate(img, img_md.TransformationData.Direction.to_angle());
            end
        end

        function io_align_image_cp(mdl, img_md, atlas_vertices, hist_vertices, slice_idx, ori)
            arguments
                mdl Model
                img_md ImageMetadata
                atlas_vertices (6, 2) double
                hist_vertices (6, 2) double
                slice_idx (1, 1) double
                ori Orientation
            end
            img_sz = img_md.TransformationData.ori_img_sz();
            dir = img_md.TransformationData.Direction;
            tform = fitgeotform2d(atlas_vertices, hist_vertices, 'affine');
            t_data = TransformationData(hist_vertices, atlas_vertices, tform, img_sz, slice_idx, dir, ori);
            img_md.TransformationData = t_data;
            img_md.Aligned = true;
            mdl.io_save()
            mdl.call_registrars(ModelEvents.WorkspaceUpdated)
        end

        function io_align_image_col(mdl, img_md, slice_idx, ori)
            arguments
                mdl Model
                img_md ImageMetadata
                slice_idx (1, 1) double
                ori Orientation
            end
            img_sz = img_md.TransformationData.ori_img_sz();
            dir = img_md.TransformationData.Direction;
            hist_img = mdl.io_get_down_img(img_md);
            atlas_img = mdl.Atlas.get_reference_img(ori, slice_idx);

            tform = Utility.run_auto_reg(atlas_img, hist_img);

            if isempty(tform)
                return
            end
            
            hist_vertices = img_md.TransformationData.HistHex;
            atlas_vertices = img_md.TransformationData.AtlasHex;

            t_data = TransformationData(hist_vertices, atlas_vertices, tform, img_sz, slice_idx, dir, ori);
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
            direction = img_md.TransformationData.Direction;
            img_md.TransformationData.Direction = direction.rotate();
            mdl.io_save()
            mdl.call_registrars(ModelEvents.WorkspaceUpdated)
        end

        function io_cycle_atlas_orientation(mdl, img_md)
            arguments
                mdl Model
                img_md ImageMetadata
            end
            orient = img_md.TransformationData.Orientation;
            img_md.TransformationData.Orientation = orient.cycle();
            mdl.save_and_update()
        end

        function io_update_regions(mdl, img_md, keys, laterality)

            arguments
                mdl Model
                img_md ImageMetadata
                keys (:, 1) RegionKey
                laterality Laterality
            end
            
            create_region = @(k) Region.default_settings(img_md, Location(k, laterality));
            new_regions = arrayfun(create_region, keys);

            if isempty(keys)
                return
            end

            if (numel([img_md.Regions.ID]) ~= 0)
                add_idx = ~Utility.ismember([new_regions.ID], [img_md.Regions.ID]);
                regions_to_add = new_regions(add_idx);
            else
                regions_to_add = new_regions;
            end

            for i = 1:numel(regions_to_add)
                img_md.add_region_save_mask(regions_to_add(i), mdl.Atlas);
            end

            mdl.save_and_update()
        end

        function io_remove_regions(mdl, img_md)
            img_md.Regions = Region.empty;
            mdl.save_and_update()
        end

        function regions = get_all_regions(mdl)
            images = mdl.WS.Images;
            regions = cat(1, images.Regions);
        end

        function io_process_region(mdl, regions)
            arguments
                mdl Model
                regions (:, 1) Region
            end

            for i = 1:numel(regions)
                region = regions(i);
                mdl.io_mark_region_as_processing(region);
                mdl.ThreadPool.dispatch(@mdl.bg_run_microcount, region, @mdl.bg_run_microcount_complete);
            end
        end

        function io_cancel_microcount_processes(mdl)
            mdl.ThreadPool.cancel_all()
        end

        function io_export_results(mdl, regions)
            arguments
                mdl Model
                regions (:, 1) Region
            end

            [home_dir, ~, ~] = fileparts(mdl.WS.DirName);

            [file, path] = uiputfile( ...
                {'*.csv', 'Image Files' }, ...
                "Export Processed Image Data", ...
                home_dir + "/data.csv" ...
            );

            if isequal(file, 0) || isequal(path, 0)
                mdl.panic(Error.NO_IMG_SELECTED)
                return;
            end

            export_fn = fullfile(path, file);
            export_table = Utility.region2export(regions);
            writetable(export_table, export_fn);
        end

    end

    methods (Access = public)

        function io_mark_region_as_processing(mdl, region)
            region.ProcessStatus = ProcessStatus.PROCESSING;
            mdl.io_save()
            mdl.call_registrars(ModelEvents.WorkspaceUpdated)
        end

        function io_mark_image_as_converting(mdl, img_md)
            img_md.ConvertStatus = ConvertStatus.CONVERTING;
            mdl.io_save()
            mdl.call_registrars(ModelEvents.WorkspaceUpdated)
        end

        function bg_conv_down_img_complete(mdl, fut)
            img_md = fut.InputArguments{1};
            if ~isempty(fut.Error)
                fprintf("Convert and Downsample: Image %s stopped after event: %s\n", img_md.ID, fut.Error.message);
               disp([fut.Error.stack.name]);
            else
                fprintf("Convert and Downsample: Image %s completed after: %s\n", img_md.ID, fut.RunningDuration);
                img_md.ConvertStatus = ConvertStatus.CONVERTED;
            end
            mdl.io_save()
            mdl.call_registrars(ModelEvents.WorkspaceUpdated)
        end

        function result = bg_run_microcount(mdl, region)

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
            imwrite(output_img, region.ProcFn);
        end

        function bg_run_microcount_complete(mdl, fut)
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

        function panic(mdl, err_enum)
            mdl.ErrorCache = err_enum;
            mdl.call_registrars(ModelEvents.Error)
        end

        function call_registrars(mdl, event)
            for i = 1:numel(mdl.RegistrarFcns)
                mdl.RegistrarFcns{i}(event)
            end
        end

        function save_and_update(mdl)
            mdl.io_save()
            mdl.call_registrars(ModelEvents.WorkspaceUpdated)
        end

    end

    methods (Static)

        function msg = bg_conv_down_img(img_md)
            arguments
                img_md ImageMetadata
            end
            img = imread(img_md.SourceFn);
            imwrite(img, img_md.ConvFn);
            Model.bg_down_img(img_md);
            msg = "Complete";
        end

        function msg = bg_down_img(img_md)
            arguments
                img_md ImageMetadata
            end
            RESIZE = 20;
            CHN_BRT = 1;
            pixel_region = { [1 RESIZE img_md.Size(1)], [1 RESIZE img_md.Size(2)] };
            img = imread(img_md.SourceFn, "PixelRegion", pixel_region);
            dn_img = img(:, :, CHN_BRT);
            imwrite(imadjust(dn_img), img_md.DownFn);
            msg = "Completed";
        end
        
    end

end
