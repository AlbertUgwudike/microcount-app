classdef (Abstract) ControllerBase < handle

    properties ( SetAccess = immutable, GetAccess = protected )
        Model Model
    end

    properties ( SetAccess = public )
        View 
    end 
    
    methods
        
        function cb = ControllerBase(model, view)
            cb.Model = model;
            cb.Model.RegistrarFcns = [ cb.Model.RegistrarFcns { @cb.handle_event }];

            cb.View = view;
            cb.View.RegistrarFnc = { @cb.handle_event };
        end
        
    end

    methods ( Access = protected )
        handle_event(con, event, data)
    end
    
end