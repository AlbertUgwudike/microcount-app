function dist_img = trace_branches(origins, skelly)
    arguments
        origins (:, 2) int32 
        skelly (:, :) logical
    end

    dirs = int32([ ...
        [0, 1]; [0, -1]; [-1, 0]; [1, 0]; ...
        [1, 1]; [-1, -1]; [-1, 1]; [1, -1]; ...
    ]);

    [H, W] = size(skelly);
    dist_img = 0 * uint16(skelly);
    to_visit = skelly;

    stack = {};
    s_stack = {};
    
    for origin_idx = 1:height(origins)
        elem = {origins(origin_idx, :)};
        stack = push_stack(stack, elem);
    end

    while numel(stack) > 0 
        [stack, elem] = pop_stack(stack);
        elem{2} = {};

        for i = 1:8
            dir = dirs(i, :);
            next_pos = elem{1} + dir;

            if in_bounds(next_pos, H, W) && to_visit(next_pos(1), next_pos(2))
                to_visit(next_pos(1), next_pos(2)) = false;
                new_elem = {next_pos};
                elem{2} = [elem{2}, next_pos];
                stack = push_back_stack(stack, new_elem);
            end
        end

        s_stack = push_stack(s_stack, elem);
    end

    while numel(s_stack) > 0 
        [s_stack, elem] = pop_stack(s_stack);
        total_dist = 1;
        pt = elem{1};
        nbs = elem{2};
        for i = 1:numel(nbs)
            nb = nbs{i};
            total_dist = total_dist + dist_img(nb(1), nb(2));
        end
        dist_img(pt(1), pt(2)) = total_dist;
    end

end

function stack = push_stack(stack, elem)
    stack = [{elem}, stack];
end

function stack = push_back_stack(stack, elem)
    stack = [stack, {elem}];
end

function [stack, elem] = pop_stack(stack)
    elem = stack{1};
    stack = stack(2:numel(stack));
end

function flag = in_bounds(pt, H, W)
    flag = pt(1) > 0 && pt(1) <= H && pt(2) > 0 && pt(2) <= W;
end

