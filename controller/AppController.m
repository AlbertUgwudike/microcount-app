classdef AppController < ControllerBase
   
    methods
        
        function ctl = AppController(model, view)
            
            arguments
                model Model
                view AppView
            end

            ctl@ControllerBase(model, view);
            
        end
        
    end

    methods ( Access = protected )
        
        function handle_event(~, ~, ~)
        end
        
    end
    
end