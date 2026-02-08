function [branch_counts, detected, skelly] = count_branches(labelled_img)

    skelly = uint16(bwskel(labelled_img > 0));
    [four_way_filters, five_way_filters] = branch_filters();

    detected = zeros(size(labelled_img));

    for j = 1:16 
        bfilter = four_way_filters{j};
        detected = detected | conv2(skelly, bfilter, 'same') == 4;
    end

    for j = 1:2 
        bfilter = five_way_filters{j};
        detected = detected | conv2(skelly, bfilter, 'same') == 5;
    end

    skelly(skelly > 0) = labelled_img(skelly > 0);

    N = max(labelled_img, [], "all");
    l_points = uint16(detected) .* labelled_img;
    branch_counts = zeros(N, 1);
    
    for i = 1:N 
        branch_counts(i) = numel(find(l_points == i));
    end

end

