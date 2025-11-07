function BW = segment_somas(X, soma_thresh, params, radius)
    arguments
        X
        soma_thresh = 0.5
        params = []
        radius = 7
    end

    norm_X = log_norm(X, params);
    BW = norm_X > soma_thresh;

    decomposition = 0;
    se = strel('disk', radius, decomposition);
    BW = imopen(BW, se);

    % Fill holes
    BW = imfill(BW, 'holes');

end


