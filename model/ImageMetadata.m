classdef ImageMetadata < handle
    
    properties (SetAccess = private)
        SourceFn (1, 1) string
        DownFn (1, 1) string
        ConvFn (1, 1) string
        WS_Dir (1, 1) string
        Size (1, 2) uint16
        ID (1, 1) string
    end

    properties
        Converted (1, 1) logical = false
        Aligned (1, 1) logical = false
        DownSampled (1, 1) logical = false
        TransformationData TransformationData
        Regions (:, 1) Region = Region.empty()
    end
    
    methods
        function img_md = ImageMetadata(source_fn, ws_dir)
            arguments
                source_fn (1, 1) string
                ws_dir (1, 1) string
            end
            img_md.SourceFn = source_fn;
            [~, fn, ~] = fileparts(source_fn);
            img_md.ID = fn;
            img_md.DownFn = ImageMetadata.get_down_fn(fn, ws_dir);
            img_md.ConvFn = ImageMetadata.get_conv_fn(fn, ws_dir);
            img_md.WS_Dir = ws_dir;
            disp(img_md.WS_Dir)
            info = imfinfo(source_fn);
            H = [info.Height];
            W = [info.Width];
            img_md.Size = [H(1), W(1)];
        end

        function add_region_save_mask(img_md, region, atlas)
            arguments
                img_md ImageMetadata
                region Region
                atlas Atlas
            end

            dn_mask = atlas.create_dn_size_mask(region);
            bbox = bounding_box(dn_mask);

            if isempty(bbox)
                fprintf("Region::add_region_save_mask - bbox empty - %s\n", region.ID)
                return;
            end

            img_md.Regions = cat(1, img_md.Regions, region);
            c_mask = imcrop(dn_mask, bbox - [0, 0, 1, 1]);
            imwrite(c_mask, region.MaskFn);
        end

        function locs = all_locations(img_md)
            arguments
                img_md ImageMetadata
            end

            locs = [img_md.Regions.Location];
            
            if (isempty(locs))
                locs = Location.empty;
            end
        end
        
    end

    methods (Static)

        function down_fn = get_down_fn(id, ws_dir)

            arguments
                id string
                ws_dir string
            end

            down_fn = sprintf( ...
                "%s/%s/%s_%s.tiff", ...
                ws_dir, ...
                Constants.DIR_SLUG_DOWN, ...
                id, ...
                "down" ...
            );
        end

        function conv_fn = get_conv_fn(id, ws_dir)

            arguments
                id string
                ws_dir string
            end

            conv_fn = sprintf( ...
                "%s/%s/%s_%s.tiff", ...
                ws_dir, ...
                Constants.DIR_SLUG_CONVERT, ...
                id, ...
                "conv" ...
            );
        end

    end
end

