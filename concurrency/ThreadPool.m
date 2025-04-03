classdef ThreadPool < ThreadPoolBase
    
    methods

        function obj = ThreadPool()
            obj@ThreadPoolBase()
        end
    end

    methods (Access = protected)

        function fut = run(~, fcn, arg)
            fut = parfeval(fcn, 1, arg);
        end

    end
end

