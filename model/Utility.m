classdef Utility
    methods (Static)
        function output = apply_check(idxs)
            emojis = ['❌', '✅'];
            output = arrayfun(@(n) emojis(n + 1), idxs);
        end

        function calc_borders()

        end
    end
end

