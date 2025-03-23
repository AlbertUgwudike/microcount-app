classdef Region
    
    properties
        ID (1, 1) string
        Iba1Threshold (1, 1) double
        CD68Threshold (1, 1) double
        MaxCD68Size (1, 1) uint32
    end
    
    methods
        function region = Region(idenitifer, region_key, laterality, iba1, cd68, cd68_max)
            region.ID = Region.generate_id(idenitifer, region_key, laterality);
            region.Iba1Threshold = iba1;
            region.CD68Threshold = cd68;
            region.MaxCD68Size = cd68_max;
        end
    end

    methods (Static)
        function default_region = default(idenitifer, region_key, laterality)
            default_region = Region(idenitifer, region_key, laterality, 0.35, 0.5, 10000);
        end

        function id = generate_id(identifier, region_key, laterality)
            id = identifier + "__" + string(region_key) + "__" + string(laterality);
        end

        function [idenitifer, region_key, laterality] = decode_id(id)
            comps = split(id, "__");
            idenitifer = comps(1);
            region_key = comps(2);
            laterality = comps(3);
        end
    end
end

