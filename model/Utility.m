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

    end
end

