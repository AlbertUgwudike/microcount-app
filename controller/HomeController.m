classdef HomeController < ControllerBase
    properties
        homeView HomeView
    end
    methods
        
        function ctl = HomeController(model, view)
            arguments
                model Model
                view HomeView
            end
            
            ctl@ControllerBase(model, view);
            ctl.homeView = view;
            
        end
        
    end
    
    methods ( Access = private )
        
        function onCreateButtonPushed(con, ~, ~)
            con.Model.io_create_workspace()
        end

        function onLoadButtonPushed(con, ~, ~)
            con.Model.io_load_workspace()
        end

        function onWorkSpaceUpdated(con)
            disp("HomeController::on_workspace_updated")
            if isempty(con.Model.WS)
                return
            end
            con.View.CurrentWorkspaceName.Text = con.Model.WS.DirName;
        end
        
    end

    methods (Access = protected)
        
        function handle_event(con, event, ~)
            switch event

                case (HomeEvent.ButtonLoadWorkspace)
                    con.onLoadButtonPushed()

                case (HomeEvent.ButtonCreateWorkspace)
                    con.onCreateButtonPushed()

                case (ModelEvents.WorkspaceUpdated)
                    con.onWorkSpaceUpdated()
            end
        end
        
    end
    
end