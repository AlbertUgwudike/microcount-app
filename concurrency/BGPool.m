classdef BGPool < ThreadPoolBase
    
    methods

        function obj = BGPool()
            obj@ThreadPoolBase()
        end
    end

    methods (Access = protected)

        function fut = run(~, fcn, arg)
            fut = parfeval(backgroundPool, fcn, 1, arg);
        end

    end
end

