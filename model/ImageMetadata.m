classdef ImageMetadata < handle
    
    properties (SetAccess = private)
        SourceFn (1, 1) string
        DownFn (1, 1) string
        ConvFn (1, 1) string
        Size (1, 2) uint16
        ID (1, 1) string
    end

    properties
        Converted (1, 1) logical = false
        Aligned (1, 1) logical = false
        DownSampled (1, 1) logical = false
        TransformationData TransformationData
        Regions (12, 1) cell = arrayfun(@(~) Region.empty(), 1:12, 'UniformOutput', false)
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
            info = imfinfo(source_fn);
            H = [info.Height];
            W = [info.Width];
            img_md.Size = [H(1), W(1)];
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

        function region = get_region(img_md, region_key, laterality)

            arguments
                img_md ImageMetadata
                region_key RegionKey
                laterality Laterality
            end
                
            idx = img_md.calc_idx(region_key, laterality);
            region = img_md.Regions{idx};
        end

        function is_selected = region_selected(img_md, region_key, laterality)

            arguments
                img_md ImageMetadata
                region_key RegionKey
                laterality Laterality
            end
                
            idx = img_md.calc_idx(region_key, laterality);
            is_selected = ~isempty(img_md.Regions{idx});
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

