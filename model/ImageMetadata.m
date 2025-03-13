classdef ImageMetadata < handle
    
    properties
        SourceFn (1, 1) string
        ID (1, 1) string
        Converted (1, 1) logical = false
        Aligned (1, 1) logical = false
        DownSampled (1, 1) logical = false
        RegionCodes (:, 1) string
        TransformationData (1, 1) TransformationData = TransformationData.default()
    end
    
    methods
        function img_md = ImageMetadata(source_fn)
            arguments
                source_fn (1, 1) string
            end
            img_md.SourceFn = source_fn;
            [~, fn, ~] = fileparts(source_fn);
            img_md.ID = fn;
            disp(img_md.ID)
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
        
    end
end

