classdef ImageMetadata
    
    properties
        SourceFn (1, 1) string
        Converted (1, 1) logical
        DownSampled (1, 1) logical
        RegionCodes (:, 1) string
    end
    
    methods
        function img_md = ImageMetadata(source_fn)
            arguments
                source_fn (1, 1) string
            end
            img_md.SourceFn = source_fn;
        end
        
        function mask_fn = get_mask_fn(img_md, laterality, region_code)

            arguments
                img_md ImageMetadata
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
                "%s/%s_%s_%s.tiff", ...
                Constants.DIR_SLUG_MASK, ...
                img_md.SourceFn, ...
                region_code, ...
                lat_str ...
            );
        end


    end
end

