classdef Location
    properties
        RegionKey RegionKey
        Laterality Laterality
    end
    
    methods
        function loc = Location(region_key, laterality)
            arguments
                region_key RegionKey
                laterality Laterality
            end
            loc.Laterality = laterality;
            loc.RegionKey = region_key;
        end

        function str = to_string(loc)
            arguments
                loc Location
            end
            str = string(loc.Laterality) + "--" + string(loc.RegionKey);
        end
    end
end

