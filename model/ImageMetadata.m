classdef ImageMetadata < handle
    
    properties
        SourceFn (1, 1) string
        Size (1, 2) uint16
        ID (1, 1) string
        Converted (1, 1) logical = false
        Aligned (1, 1) logical = false
        DownSampled (1, 1) logical = false
        TransformationData TransformationData
        Regions (12, 1) cell = arrayfun(@(~) Region.empty(), 1:12, 'UniformOutput', false)
    end
    
    methods
        function img_md = ImageMetadata(source_fn)
            arguments
                source_fn (1, 1) string
            end
            img_md.SourceFn = source_fn;
            [~, fn, ~] = fileparts(source_fn);
            img_md.ID = fn;
            info = imfinfo(source_fn);
            img_md.Size = [info.Height, info.Width];
        end
        
        function mask_fn = get_mask_fn(img_md, ws_dir, laterality, region_code)

            arguments
                img_md ImageMetadata
                ws_dir string
                laterality Laterality
                region_code string
            end

            switch laterality
                case Laterality.LEFT
                    lat_str = "LEFT";

                case Laterality.RIGHT
                    lat_str = "RIGHT";
            end

            mask_fn = sprintf( ...
                "%s/%s/%s_%s_%s.tiff", ...
                ws_dir, ...
                Constants.DIR_SLUG_MASK, ...
                img_md.ID, ...
                region_code, ...
                lat_str ...
            );
        end

        function down_fn = get_down_fn(img_md, ws_dir)

            arguments
                img_md ImageMetadata
                ws_dir string
            end

            down_fn = sprintf( ...
                "%s/%s/%s_%s.tiff", ...
                ws_dir, ...
                Constants.DIR_SLUG_DOWN, ...
                img_md.ID, ...
                "down" ...
            );
        end

        function down_fn = get_conv_fn(img_md, ws_dir)

            arguments
                img_md ImageMetadata
                ws_dir string
            end

            down_fn = sprintf( ...
                "%s/%s/%s_%s.tiff", ...
                ws_dir, ...
                Constants.DIR_SLUG_CONVERT, ...
                img_md.ID, ...
                "conv" ...
            );
        end

        function toggle_region(img_mg, region_key, laterality)

            arguments
                img_mg ImageMetadata
                region_key RegionKey
                laterality Laterality
            end

            idx = img_mg.calc_idx(region_key, laterality);
            region = img_mg.Regions{idx};

            if isempty(region)
                img_mg.Regions{idx} = Region.default_settings(img_mg, region_key, laterality);
            else
                img_mg.Regions{idx} = Region.empty;
            end

        end

        function selected = is_region_selected(img_mg, region_key, laterality)

            arguments
                img_mg ImageMetadata
                region_key RegionKey
                laterality Laterality
            end
                
            idx = img_mg.calc_idx(region_key, laterality);
            selected = ~isempty(img_mg.Regions{idx});
        end

        function idx = calc_idx(~, region_key, laterality)
            arguments
                ~ 
                region_key RegionKey
                laterality Laterality 
            end
            region_idx = uint8(region_key);
            lat_idx = uint8(laterality);
            idx = lat_idx * 6 + region_idx;
        end
        
    end
end

