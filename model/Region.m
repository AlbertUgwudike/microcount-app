classdef Region < handle
    
    properties
        Parent ImageMetadata
        Key RegionKey
        Side Laterality
        ID (1, 1) string
        Iba1Threshold (1, 1) double
        CD68Threshold (1, 1) double
        MaxCD68Size (1, 1) uint32
        Processed (1, 1) logical
        Result MicrocountData = MicrocountData.empty
    end
    
    methods
        function region = Region(img_md, region_key, laterality, iba1, cd68, cd68_max)
            region.Parent = img_md;
            region.Key = region_key;
            region.Side = laterality;
            region.ID = Region.generate_id(img_md.ID, region_key, laterality);
            region.Iba1Threshold = iba1;
            region.CD68Threshold = cd68;
            region.MaxCD68Size = cd68_max;
        end

        function apply_setting_str_list(reg, setting_list)
            parsed_list = double(setting_list);
            reg.Iba1Threshold = parsed_list(1);
            reg.CD68Threshold = parsed_list(2);
            reg.MaxCD68Size = uint32(parsed_list(3));
        end

        function str_list = get_setting_str_list(reg)
            iba1 = sprintf("%0.2f", reg.Iba1Threshold);
            cd68 = sprintf("%0.2f", reg.CD68Threshold);
            max_cd68 = string(reg.MaxCD68Size);
            str_list = [iba1, cd68, max_cd68];
        end

        function settings = get_microcount_settings(region)
            arguments
                region Region
            end
            
            settings = MicrocountSettings( ...
                region.Iba1Threshold, ...
                region.CD68Threshold, ...
                region.MaxCD68Size ...
            );

        end
    end

    methods (Static)
        function region = default_settings(img_md, region_key, laterality)
            region = Region(img_md, region_key, laterality, 0.35, 0.5, 10000);
        end

        function id = generate_id(identifier, region_key, laterality)
            id = identifier + "__" + string(region_key) + "__" + string(laterality);
        end

        function [idenitifer, region_key, laterality] = decode_id(id)
            comps = split(id, "__");
            idenitifer = comps(1);
            region_key = RegionKey(comps(2));
            laterality = Laterality(comps(3));
        end

        function valid = valid_setting_str_list(str_list)
            arguments
                str_list (:, 1) string
            end
            valid = ~any(arrayfun(@(n) isnan(double(n)), str_list));
        end
    end
end

