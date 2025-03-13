classdef HomeController

    properties ( SetAccess = immutable, GetAccess = protected )
        Model Model
    end 
    
    methods
        
        function ctl = HomeController(model)
            arguments
                model Model
            end
            
            ctl.Model = model;
            
        end
        
    end
    
    methods ( Access = private )
        
        function onCreateButtonPushed(con, ~, ~)
            con.Model.io_create_workspace()
        end

        function onLoadButtonPushed(con, ~, ~)
            con.Model.io_load_workspace()
        end
        
    end

    methods (Access = public)
        
        function handle_event(con, event)
            switch event

                case (HomeEvent.ButtonLoadWorkspace)
                    con.onLoadButtonPushed()

                case (HomeEvent.ButtonCreateWorkspace)
                    con.onCreateButtonPushed()
            end
        end
        
    end
    
end