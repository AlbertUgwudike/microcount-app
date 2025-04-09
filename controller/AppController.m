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
        
        function handle_event(con, event, ~)
            switch event
                case (AppEvent.TabSelected)
                    con.onTabSelected()
            end
        end
        
    end

    methods (Access = private)

        function flag = workspaceLoaded(con)
            flag = ~isempty(con.Model.WS);
        end

        function onTabSelected(con)
            disp("AppController::onTabSelected")

            if ~con.workspaceLoaded()
                con.View.TabGroup.SelectedTab = con.View.HomeTab;
                return
            end
        end

    end
    
end