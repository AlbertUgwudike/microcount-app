function [rotundities, cell_areas, soma_areas, poly_mask] = rotundity(region_pts, soma_mask)

    N = height(region_pts);
    rotundities = zeros(N, 1);
    cell_areas = zeros(N, 1);
    soma_areas = zeros(N, 1);
    poly_mask = zeros(size(soma_mask));

    for i = 1:N
        pts = region_pts{i};
        origin = min(pts, [], 1);
        shifted = pts - origin + [1, 1];
        dims = max(shifted, [], 1);
        H = dims(1); W = dims(2);
        I = shifted(:, 1); J = shifted(:, 2);
        mask = zeros(H, W);
        indices = sub2ind([H, W], I, J);
        mask(indices) = true;
        cell_areas(i) = height(pts);
       
        % compute rotundity ----------------
        try
            K = convhull(I, J);
            vertices = cat(2, J(K), I(K));
            solid_poly = poly2mask(vertices(:, 1), vertices(:, 2), H, W);
            rotundities(i) = height(pts) / sum(solid_poly, "all");
        catch e
            fprintf("Rotundity, convex hull failed: %s\n", e.message)
            rotundities(i) = nan;
        end
        % ----------------------------------

        % compute perimeters ----------------
        perim = bwperim(mask);

        soma_region = soma_mask(origin(1):origin(1) + H - 1, origin(2):origin(2) + W - 1);
        soma_region = soma_region & mask;
        soma_region_box = bwperim(ones(size(soma_region)));
        perim = perim | (bwperim(soma_region) & ~soma_region_box);

        [x, y] = ind2sub([H, W], find(perim));
        perim_pts = cat(2, x, y) + origin - [1, 1];
        idx = sub2ind(size(soma_mask), perim_pts(:, 1), perim_pts(:, 2));
        
        poly_mask(idx) = i;
        soma_areas(i) = sum(soma_region > 0, "all");
        % ----------------------------------

    end

end

