function vertices = convex_hull(binary_img)
    cc = bwconncomp(binary_img);
    points = cc.PixelIdxList{1};
    [I, J] = ind2sub(cc.ImageSize, points);
    if (height(points) < 2) 
        vertices = [];
        return; 
    end 
    K = convhull(I, J);
    vertices = cat(2, J(K), I(K));
end

