classdef Model < handle
    
    properties ( SetAccess = private )
        WS Workspace = Workspace.empty
        ErrorCache Error
        ThreadPool ThreadPool = ThreadPool()
        AppDir string
    end
    
    properties ( SetAccess = public )
        Atlas Atlas
        RegistrarFcns
    end
    
    methods (Access = public)
        
        function  mdl = Model(app_dir)
            mdl.AppDir = app_dir;
            mdl.Atlas = Atlas(app_dir);
        end
        
        function io_create_workspace(mdl)
            disp("Creating workspace.")
            
            [file, path] = uiputfile('*.*', 'Create Microcount Workspace', 'mc_ws');
            
            dir_name = fullfile(path, file);
            disp(dir_name)
            
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
            
            mkdir(dir_name);
            
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
                {'*.tif;*.tiff;*.czi;*.lof;*.png;*.jpg;*.jpeg', 'Image files' }, ...
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
                new_img = ImageMetadata(fn, mdl.WS.DirName);
                current_img_set = mdl.WS.Images;
                updated_img_set = cat(1, current_img_set, new_img);
                [~, idx, ~] = unique([updated_img_set.ID]);
                mdl.WS.Images = updated_img_set(idx);
            end
            
            mdl.save_and_update()
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
        
        function update_channel_indices(mdl, idx, reg_ch, cell_ch, co_ch)
            img_md = mdl.WS.Images(idx);
            valid_order = ImageMetadata.valid_channel_indices(reg_ch, cell_ch, co_ch, img_md.ChannelCount);
            if valid_order
                img_md.set_channel_indices(reg_ch, cell_ch, co_ch);
            end
            mdl.save_and_update();
        end
        
        function io_convert_and_downsample(mdl, idx)
            
            bool_idx = false(1, numel(mdl.WS.Images));
            bool_idx(idx) = true;
            
            not_converted = [mdl.WS.Images.ConvertStatus] ~= ConvertStatus.CONVERTED;
            not_file_exists = arrayfun(@(img) ~isfile(img.ConvFn), mdl.WS.Images)';
            
            convert_idx = bool_idx & not_converted & not_file_exists;
            imgs = mdl.WS.Images(convert_idx);
            
            app_dir_vec = repmat(mdl.AppDir, 1, numel(imgs));
            args = Utility.zip(imgs, app_dir_vec);
            
            mdl.ThreadPool.dispatch_batch_monitored( ...
                @mdl.io_mark_image_as_converting, ...
                @Model.bg_conv_down_img, args, ...
                @mdl.bg_conv_down_img_complete, ...
                @Model.bg_monitor_progress, ...
                @mdl.update_progress ...
            )
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
            reg_ch = img_md.RegistrationChannel;
            raw_img = tiffreadVolume(img_md.DownFn);
            img = uint16(raw_img(:, :, reg_ch));
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
            mdl.save_and_update()
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
            mdl.save_and_update()
        end
        
        function io_rotate_image(mdl, img_md)
            arguments
                mdl Model
                img_md ImageMetadata
            end
            direction = img_md.TransformationData.Direction;
            img_md.TransformationData.Direction = direction.rotate();
            mdl.save_and_update()
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
        
        function io_remove_regions(mdl, img_md, keys, laterality)
            
            arguments
                mdl Model
                img_md ImageMetadata
                keys (:, 1) RegionKey
                laterality Laterality
            end
            
            locs = [img_md.Regions.Location];
            region_idx = ismember([locs.RegionKey], keys);
            laterality_idx = [locs.Laterality] == laterality;
            idx = ~(region_idx & laterality_idx);
            img_md.Regions = img_md.Regions(idx);
            mdl.save_and_update()
        end
        
        function io_remove_all_regions(mdl, img_md)
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
            
            mdl.ThreadPool.dispatch_batch( ...
                @(batch) mdl.io_set_processing_status(batch, ProcessStatus.PROCESSING), ...
                @mdl.bg_run_microcount_batch, regions, ...
                @mdl.bg_run_microcount_complete ...
            );
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
        
        function io_set_processing_status(mdl, regions, status)
            for i = 1:numel(regions)
                regions(i).ProcessStatus = status;
            end
            mdl.save_and_update_analyse_tab()
        end
        
        function io_mark_image_as_converting(mdl, pairs)
            img_mds = arrayfun(@(p) p.Left, pairs);
            for i = 1:numel(img_mds)
                img_mds(i).ConvertStatus = ConvertStatus.CONVERTING;
            end
            mdl.save_and_update()
        end
        
        function bg_conv_down_img_complete(mdl, args)
            err     = ~args{1};
            img_id  = args{2};
            img_md  = mdl.WS.Images([mdl.WS.Images.ID] == img_id);
            
            if err
                fprintf("Convert and Downsample: Image %s stopped after event: %s\n", img_id, args{3}.message);
                disp([args{3}.stack.name]);
                img_md.ConversionProgress = 0;
                img_md.ConvertStatus = ConvertStatus.UNCONVERTED;
            else
                fprintf("Convert and Downsample: Image %s completed after: %s\n", img_id, args{3});
                img_md.set_metadata()
                img_md.ConvertStatus = ConvertStatus.CONVERTED;
            end
            
            mdl.save_and_update()
        end
        
        function msg = bg_run_microcount_batch(mdl, args)
            q       = args{1};
            regions = args{2};
            msg = "Placeholder";
            for i = 1:numel(regions)
                try
                    tic
                    result = mdl.bg_run_microcount(regions(i));
                    elapsed = string(toc);
                    send(q, {true, regions(i).ID, result, elapsed});
                catch e
                    send(q, {false, regions(i).ID, e});
                end
            end
        end
        
        function result = bg_run_microcount(mdl, region)
            
            arguments
                mdl Model
                region Region
            end
            
            mask = mdl.Atlas.create_full_size_mask(region);
            file_name_chrs = convertStringsToChars(region.Parent.ConvFn);
            bfr_img = BioformatsImage(file_name_chrs);
            settings = region.get_microcount_settings();
            
            data = algo_fluor_micro(bfr_img, mask, settings);
            [result, output_img] = data2result(data);
            
            % data = algo_dab_astro(bfr_img, mask, settings);
            % [result, output_img] = data2result(data, 'dab_astro');
            
            % data = algo_dab_micro(bfr_img, mask, settings);
            % [result, output_img] = data2result(data, 'dab_micro');
            
            % data = algo_fluor_neun(bfr_img, mask, settings);
            % [result, output_img] = data2result(data, 'fluor_neun');
            
            imwrite(output_img, region.ProcFn);
        end
        
        function bg_run_microcount_complete(mdl, args)
            err     = ~args{1};
            region_id  = args{2};
            
            regions = mdl.get_all_regions();
            region = regions([regions.ID] == region_id);
            
            if err
                fprintf("Microcount: Region %s stopped after event: %s\n", region.ID, args{3}.message);
                disp([args{3}.stack.name]);
                region.ProcessStatus = ProcessStatus.UNPROCESSED;
            else
                fprintf("Microcount: Region %s completed after: %s\n", region.ID, args{4});
                region.Result = args{3};
                region.ProcessStatus = ProcessStatus.PROCESSED;
            end
            
            mdl.save_and_update_analyse_tab()
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

        function save_and_update_analyse_tab(mdl)
            mdl.io_save()
            mdl.call_registrars(ModelEvents.UpdateAnaylseTab)
        end
        
        function update_progress(mdl, p)
            ids = p{1};
            pcs = p{2};
            
            images = [mdl.WS.Images];
            
            for i = 1:numel(ids)
                idx = [images.ID] == ids(i);
                images(idx).ConversionProgress = pcs(i);
            end
            
            mdl.call_registrars(ModelEvents.ConversionProgress);
        end
        
    end
    
    methods (Static)
        
        function msg = bg_conv_down_img(args)
            q     = args{1};
            pairs = args{2};
            msg = "Complete --";
            
            for i = 1:numel(pairs)
                img_md  = pairs(i).Left;
                app_dir = pairs(i).Right;
                msg = msg + " " + img_md.ID;

                try
                    tic
                    Model.bg_conv_img(img_md, app_dir);
                    Model.bg_down_img(img_md);
                    send(q, {true, img_md.ID, string(toc)});
                catch e
                    send(q, {false, img_md.ID, e});
                end
            end
        end
        
        function bg_conv_img(img_md, app_dir)
            [~, ~, ext] = fileparts(img_md.SourceFn);
            if ismember(ext, [".tif", ".tiff"])
                copyfile(img_md.SourceFn, img_md.ConvFn);
            else
                err = lof2tiff(app_dir, img_md.SourceFn, img_md.ConvFn);
                if err == 1
                    err_msg = sprintf("Conversion failed for image: %s\n", img_md.SourceFn);
                    throw(MException("ConvDown", err_msg))
                end
            end
        end
        
        function bg_down_img(img_md)
            arguments
                img_md ImageMetadata
            end
            RESIZE = 20;
            info = imfinfo(img_md.ConvFn);
            H = [info.Height]; W = [info.Width];
            pixel_region = { [1 RESIZE H(1)], [1 RESIZE W(1)] };
            
            if info(1).SamplesPerPixel == 1
                N = numel(info);
                reader_fcn = @(i) imadjust(uint16(imread(img_md.ConvFn, "PixelRegion", pixel_region, "Index", i)));
                channels = arrayfun(reader_fcn, 1:N, 'UniformOutput', false);
            else
                img = imread(img_md.ConvFn, "PixelRegion", pixel_region);
                N = size(img, 3);
                channels = arrayfun(@(i) imadjust(uint16(img(:, :, i))), 1:N, "UniformOutput", false);
            end
            
            down_img = cat(3, channels{:});
            Utility.write_tiff(down_img, img_md.DownFn);
        end
        
        function msg = bg_monitor_progress(args)
            img_mds = arrayfun(@(p) p.Left, args{1});
            q = args{2};
            
            ori_szs = arrayfun(@(img_md) dir(img_md.SourceFn).bytes, img_mds);
            pcs = zeros(size(img_mds));
            
            tic
            while true
                if toc > 60 * 60
                    break
                end
                
                for i = 1:numel(img_mds)
                    img_md = img_mds(i);
                    if isfile(img_md.ConvFn)
                        curr_size = dir(img_md.ConvFn).bytes;
                        pcs(i) = min(100, round(100 * curr_size / ori_szs(i), 2));
                    end
                end
                
                send(q, {[img_mds.ID], pcs})
                pause(0.5)
                
            end
            
            msg = "Done";
        end
        
    end
    
end
