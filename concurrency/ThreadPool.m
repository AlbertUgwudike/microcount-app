classdef ThreadPool < handle

    properties (Access = private)
        Futures = parallel.FevalFuture.empty
    end
    
    methods

        function obj = ThreadPool()
        end
        
        function fut = dispatch(tp, fcn, arg, on_finish)
            arguments
                tp ThreadPool
                fcn 
                arg
                on_finish 
            end

            tp.remove_completed();
            fut = ThreadPool.run(fcn, arg);
            afterEach(fut, on_finish, 0, "PassFuture", true);
            new_idx = tp.new_process_idx();
            tp.Futures(new_idx) = fut;
        end

        function cancel_all(tp)
            cancel(tp.Futures);
        end

        function n_workers = get_n_workers(~)
            n_workers = 4;
        end
    end

    methods (Access = protected)

        function remove_completed(tp)
            if isempty(tp.Futures)
                idx = [];
            else
                idx = [tp.Futures.State] == "finished";
            end
            tp.Futures = tp.Futures(~idx);
        end

        function idx = new_process_idx(tp)
            idx = numel(tp.Futures) + 1;
        end
    end

    methods (Static)
        function fut = run(fcn, arg)
            fut = parfeval(fcn, 1, arg);
        end
    end
end

