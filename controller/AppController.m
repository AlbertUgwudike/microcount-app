classdef AppController

    properties (Constant)
        
    end

    properties ( SetAccess = immutable, GetAccess = protected )
        Model Model
    end 
    
    methods
        
        function ctl = AppController(model)
            
            arguments
                model Model
            end
            
            ctl.Model = model;
            
        end
        
    end
    
    methods ( Access = private )
        
    end

    methods ( Access = public )
        
        function handle_event(con, event)
            switch event
                
            end
        end
        
    end
    
end