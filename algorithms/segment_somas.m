function BW = segment_somas(X, soma_thresh, radius)
    arguments
        X
        soma_thresh = 0.5
        radius = 8
    end

    norm_X = log_norm(X);
    BW = norm_X > soma_thresh;

    decomposition = 0;
    se = strel('disk', radius, decomposition);
    BW = imopen(BW, se);

    % Fill holes
    BW = imfill(BW, 'holes');

end


