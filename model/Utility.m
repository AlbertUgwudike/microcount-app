classdef Utility
    methods (Static)
        function output = apply_check(idxs)
            emojis = ["❌", "✅"];
            output = arrayfun(@(n) emojis(n + 1), idxs);
        end
        
        function output = check_or_none(idxs)
            emojis = ["", "✅"];
            output = arrayfun(@(n) emojis(n + 1), idxs);
        end
        
        function names = path2name(paths)
            arguments
                paths (:, 1) string
            end
            [~, a, b] = fileparts(paths);
            names = a + b;
        end
        
        function flat = flatten(arr)
            flat = reshape(arr, [], 1);
        end
        
        function vertices = gen_hex(sz)
            r = floor(0.75 * min(sz / 2));
            c = floor(sz / 2);
            
            pt_idx = [0, 1, 2, 3, 4, 5];
            fst = power(exp(1), 1i * pi / 6);
            theta = power(exp(1), 1i * pi / 3);
            
            pts = arrayfun(@(idx) r * fst * power(theta, idx), pt_idx);
            
            xs = real(pts);
            ys = imag(pts);
            
            vertices = [xs', ys'] + flip(c);
        end
        
        function out = cat_cells(arr)
            out = [];
            for i = 1:numel(arr)
                out = cat(1, out, arr{i});
            end
        end
        
        function out = ismember(a, b)
            if isempty(b)
                out = false(size(a));
            else
                out = ismember(a, b);
            end
        end
        
        function tform = run_auto_reg(atlas_img, hist_img)
            s = warning('error', 'images:regmex:registrationOutBoundsTermination');
            try
                tform = auto_reg(atlas_img, hist_img);
            catch e
                fprintf("Model::io_align_image_col - Registration Failed: %s\n", e.message);
                tform = affinetform2d.empty();
                warning(s)
                return
            end
            warning(s)
        end
        
        function export_table = region2export(regions)
            export_table.file_name = [regions.ProcFn]';
            export_table.mask_file_name = [regions.MaskFn]';
            export_table.region_ID = [regions.ID]';
            export_table.cell_threshold = [regions.Iba1Threshold]';
            export_table.comarker_threshold = [regions.CD68Threshold]';
            export_table.max_comarker_size = [regions.MaxCD68Size]';
            export_table.min_comarker_overlap = [regions.OverlapPercentage]';
            
            results = [regions.Result];
            
            export_table.cell_density = [results.MicrogliaDensity]';
            export_table.percentage_cell_area = [results.PercentageIba1Area]';
            export_table.percentage_comarker_area = [results.PercentageCD68Area]';
            export_table.percentage_comarker_num = [results.PercentageActivatedMicroglia]';
            export_table.average_convexity = [results.AverageRotundity]';
            export_table.average_soma_size = [results.AverageSomaSizeUm]';
            export_table.average_branch_count = [results.AverageBranchCount]';
            export_table.average_branch_length = [results.AverageBranchLengthUm]';
            export_table.average_scholl_index = [results.AverageSchollIndex]';
            
            export_table = struct2table(export_table);
        end
        
        function out = color_segmentation(seg)
            out = label2rgb(seg, "winter", [0, 0, 0], "shuffle");
            out = uint16(out) * 256;
        end
        
        function out = zip(arr1, arr2)
            idxs = 1:min(numel(arr1), numel(arr2));
            out = arrayfun(@(i) Pair(arr1(i), arr2(i)), idxs);
        end
        
        function write_tiff(img, fn)
            bt = Tiff(fn, 'w8');
            sz = size(img);
            setTag(bt, Utility.default_tags(sz(1), sz(2), sz(3)));
            bt.write(img)
            bt.close();
        end

        function write_tiff_multi(imgs, fn)
            bt = Tiff(fn, 'w8');

            for n = 1:numel(imgs)
                sz = size(imgs{n});
                tags = Utility.default_tags(sz(1), sz(2), sz(3));
                bt.setTag(tags);
                currentImage = squeeze(imgs{n});
                bt.write(currentImage);
                bt.writeDirectory();
            end

            bt.close();
        end

        function tags = default_tags(h, w, spp) 
            tags.ImageLength         = h;
            tags.ImageWidth          = w;
            tags.Photometric         = Tiff.Photometric.MinIsBlack;
            tags.BitsPerSample       = 16;
            tags.SamplesPerPixel     = spp;
            tags.TileWidth           = 128;
            tags.TileLength          = 128;
            tags.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
            tags.Software            = 'MATLAB';
            tags.Compression         = 1; 
        end

        function out = imcrop(img, bbox)
            N = size(img, 3);
            c_img = arrayfun(@(i) imcrop(img(:, :, i), bbox), 1:N, UniformOutput=false);
            out = cat(3, c_img{:});
        end

        function pad_vec = pad_to(vec, N, v)
            pad_vec = v * ones(1, N);
            pad_vec(1:min(numel(vec), N)) = vec(1:min(numel(vec), N));
        end
        
    end
end

