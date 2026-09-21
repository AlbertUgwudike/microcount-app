function BW = segment_confocal_somas(X, soma_thresh, params, radius)
    arguments
        X
        soma_thresh = 0.5
        params = []
        radius = 7
    end
    blur = imclose(uint16(X), strel('disk', 2, 0));
    disp(max(X, [], "all"))

    norm_X = log_norm(blur, params);
    disp(max(norm_X, [], "all"))
    BW = bwareafilt(norm_X > soma_thresh, [50, 10000]);

%     norm_X = log_norm(X, params);
%     BW = norm_X > soma_thresh;
% 
%     decomposition = 0;
%     se = strel('disk', radius, decomposition);
%     BW = imopen(BW, se);

    % Fill holes
%     BW = imfill(BW, 'holes');

end


