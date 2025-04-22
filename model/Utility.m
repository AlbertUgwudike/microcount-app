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

        function batches = create_batches_modulo(lst, n)
            full_idx = 0:(numel(lst) - 1);
            for i = 1:n
                idx = mod(full_idx, n) == i - 1;
                batches{i} = lst(idx);
            end
        end

        function export_table = region2export(regions)
            export_table.file_name = [regions.ProcFn]';
            export_table.mask_file_name = [regions.MaskFn]';
            export_table.region_ID = [regions.ID]';
            export_table.cell_threshold = [regions.Iba1Threshold]';
            export_table.max_comarker_size = [regions.MaxCD68Size]';
            export_table.comarker_threshold = [regions.CD68Threshold]';

            results = [regions.Result];

            export_table.cel_density = [results.MicrogliaDensity]';
            export_table.percentage_cell_area = [results.PercentageIba1Area]';
            export_table.percentage_comarker_area = [results.PercentageCD68Area]';
            export_table.percentage_comarker_num = [results.PercentageActivatedMicroglia]';
            export_table.average_convexity = [results.AverageRotundity]';
            export_table.average_soma_size = [results.AverageSomaSizeUm]';
            export_table.average_branch_count = [results.AverageBranchCount]';
            
            export_table = struct2table(export_table);
        end

    end
end

