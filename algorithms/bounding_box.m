function bbox = bounding_box(BW)
    arguments
        BW logical
    end
    % BOUNDING_BOX compute bounding box of binary point cloud
    % bbox = [minx, miny, width, height]
    
    [I, J] = ind2sub(size(BW), find(BW));

    top     = min(I);
    bottom  = max(I);
    left    = min(J);
    right   = max(J);

    bbox = [left, top, right - left + 1, bottom - top + 1];
    
end

