function out_mask = filter_size_cd68(in_mask, thresh)
    out_mask = in_mask;

    conncompsCd68 = bwconncomp(out_mask);
    
    for k=1:length(conncompsCd68.PixelIdxList)

        compIdxs = conncompsCd68.PixelIdxList{k};

        if (length(compIdxs) > thresh) 
            out_mask(compIdxs) = 0;
            continue;
        end

    end
end

