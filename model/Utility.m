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
    end
end

