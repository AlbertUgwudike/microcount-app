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
            export_table.iba1_threshold = [regions.Iba1Threshold]';
            export_table.max_cd68_size = [regions.MaxCD68Size]';
            export_table.cd68_threshold = [regions.CD68Threshold]';

            results = [regions.Result];

            export_table.microglail_density = [results.MicrogliaDensity]';
            export_table.percentage_iba1 = [results.PercentageIba1Area]';
            export_table.percentage_cd68_area = [results.PercentageCD68Area]';
            export_table.percentage_activated_microglia = [results.PercentageActivatedMicroglia]';
            export_table.average_convexity = [results.AverageRotundity]';
            export_table.average_soma_size = [results.AverageSomaSizeUm]';
            export_table.average_branch_count = [results.AverageBranchCount]';
            
            export_table = struct2table(export_table);
        end

    end
end

