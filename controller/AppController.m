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
        function flag = registrationAvailable(con)
            flag = any([con.Model.WS.Images.DownSampled]);
        end

        function onTabSelected(con)
            disp("AppController::onTabSelected")
            if ~con.registrationAvailable() && con.View.TabGroup.SelectedTab.Title == "Register"
                con.View.TabGroup.SelectedTab = con.View.SelectTab;
            end
        end
    end
    
end