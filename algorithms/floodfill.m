function [out, labelled_img] = floodfill(soma_mask, binary_img)
    dirs = [ [0, 1]; [0, -1]; [-1, 0]; [1, 0]; ];
    [H, W] = size(binary_img);

    centroids = regionprops(soma_mask,'centroid');
    visited = ~binary_img;
    labelled_img = 0 * binary_img;

    % initialise lookup cell array
    frontier = cell(height(centroids), 1);
    out = cell(height(centroids), 1);

    for i = 1:height(frontier) 
        frontier{i} = [flip(round(centroids(i).Centroid))]; 
        out{i} = [flip(round(centroids(i).Centroid))]; 
    end

    while ~all_empty(frontier)
        for i = 1:height(frontier) 
            pts = frontier{i};
            new_pts = [];
            for j = 1:height(pts)
                pt = pts(j, :);
                labelled_img(pt(1), pt(2)) = i;
                for k = 1:4
                    neighbour = pt + dirs(k, :);
                    if ~in_bounds(neighbour, H, W); continue; end
                    if visited(neighbour(1), neighbour(2)); continue; end
                    new_pts = cat(1, new_pts, neighbour);
                    visited(neighbour(1), neighbour(2)) = 1;
                end
            end
            frontier{i} = new_pts;
            out{i} = cat(1, out{i}, new_pts);
        end
    end
end

function flag = all_empty(frontier)

    for i = 1:height(frontier)
        if height(frontier{i}) > 0
            flag = 0;
            return
        end
    end

    flag = 1;
end

function flag = in_bounds(pt, H, W)
    flag = pt(1) > 0 && pt(1) <= H && pt(2) > 0 && pt(2) <= W;
end

