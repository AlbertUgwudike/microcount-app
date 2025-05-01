classdef ThreadPool < handle

    properties (Access = private)
        Futures = parallel.FevalFuture.empty
    end
    
    methods

        function obj = ThreadPool()
        end
        
        function dispatch_batch(tp, pre_batch_fcn, fcn, arg_vec, on_finish_fcn)
            arguments
                tp ThreadPool
                pre_batch_fcn
                fcn 
                arg_vec
                on_finish_fcn 
            end

            n_workers = tp.get_n_workers();
            batches = ThreadPool.create_batches_modulo(arg_vec, n_workers);

            q = parallel.pool.DataQueue;
            afterEach(q, on_finish_fcn);

            for i = 1:n_workers
                args = { q, batches{i} };
                pre_batch_fcn(batches{i});
                tp.dispatch(fcn, args, @ThreadPool.batch_complete);
            end
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

    methods (Access = private)

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

        function batch_complete(fut)
            if ~isempty(fut.Error)
                fprintf("Batch stopped after event: %s\n", fut.Error.message);
                disp([fut.Error.stack.name]);
            else
                fprintf("Batch completed after: %s\n", fut.RunningDuration);
            end
        end

        function batches = create_batches_modulo(lst, n)
            full_idx = 0:(numel(lst) - 1);
            for i = 1:n
                idx = mod(full_idx, n) == i - 1;
                batches{i} = lst(idx);
            end
        end
    end
end

