function [av_length, labelled_img, c_img] = branch_length(seg_skelly, soma_mask)
    dirs = [ [0, 1]; [0, -1]; [-1, 0]; [1, 0]; [1, 1]; [-1, -1]; [-1, 1]; [1, -1]; ];
    [H, W] = size(seg_skelly);

    centroids = regionprops(soma_mask > 0, 'centroid');
    N = height(centroids);
    labelled_img = 0 * seg_skelly;
    visited = seg_skelly == 0;

    % initialise lookup cell array
    frontier = cell(N, 1);
    out = cell(N, 1);

    for i = 1:N
        c_pt = [flip(round(centroids(i).Centroid))];
        [I, J] = ind2sub([H, W], find(seg_skelly == i));
        pts = cat(2, I, J);
        [~, min_idx] = min(sum((pts - c_pt).^2, 2), [], 1);
        pt = pts(min_idx(1), :);

        frontier{i} = pt; 
        labelled_img(pt(1), pt(2)) = 1;
        visited(pt(1), pt(2)) = true;
    end

    c_img = labelled_img > 0;

    while ~isempty(frontier)
        for i = 1:numel(frontier)
            pts = frontier{i};
            new_pts = [];
            for j = 1:height(pts)
                pt = pts(j, :);
                curr_dist = labelled_img(pt(1), pt(2));

                neighbours = [];

                for k = 1:8
                    neighbour = pt + dirs(k, :);
                    if ~in_bounds(neighbour, H, W); continue; end
                    if visited(neighbour(1), neighbour(2)) || seg_skelly(neighbour(1), neighbour(2)) ~= seg_skelly(pt(1), pt(2)); continue; end
                    neighbours = cat(1, neighbours, neighbour);
                end

                N_neighbours = height(neighbours);
                if N_neighbours == 0
                    out{i} = cat(1, out{i}, curr_dist);
                end

                for k = 1:N_neighbours
                    neighbour = neighbours(k, :);
                    new_pts = cat(1, new_pts, neighbour);
                    labelled_img(neighbour(1), neighbour(2)) = curr_dist + 1;
                    visited(neighbour(1), neighbour(2)) = true;
                end

            end
            frontier{i} = new_pts;
        end
        frontier = remove_empty(frontier);
    end

    N_branches = sum(cellfun("length", out));
    total_length = sum(cellfun(@(r) sum(r), out));
    av_length = total_length / N_branches;


end

function f_arr = remove_empty(c_arr)
    idx = cellfun("isempty", c_arr);
    f_arr = c_arr(~idx);
end

function flag = in_bounds(pt, H, W)
    flag = pt(1) > 0 && pt(1) <= H && pt(2) > 0 && pt(2) <= W;
end

