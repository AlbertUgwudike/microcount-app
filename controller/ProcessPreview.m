classdef ProcessPreview
    
    properties
        Images
        RegionId string
        BoundingBox (1, 4) uint16
    end
    
    methods
        function pp = ProcessPreview(imgs, region_id, rect)
            arguments
                imgs
                region_id string
                rect (1, 4) uint16
            end
            pp.Images = imgs;
            pp.RegionId = region_id;
            pp.BoundingBox = rect;
        end
        
        function flag = matches(pp, pos, region_id)
            arguments
                pp ProcessPreview
                pos (1, 4) uint16
                region_id string
            end
            flag = pp.RegionId == region_id & pp.BoundingBox == pos;
        end
    end
end

