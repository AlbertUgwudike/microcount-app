classdef ThreadPool

    properties (Access = private)
        Pool parallel.Pool = parpool(8)
        Futures (:, 1) parallel.FevalFuture = []
    end
    
    methods
        function obj = ThreadPool()
            
        end
        
        function dispatch(tp, fcn, on_finish)
            tp.Pool.
        end

        function cancel_all(tp)
           cancel(tp.Futures)
        end
    end
end

