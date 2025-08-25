classdef SelectAlgoController < ControllerBase
    properties
        selectAlgoView SelectAlgoView
    end
    methods
        
        function ctl = SelectAlgoController(model, view)
            arguments
                model Model
                view SelectAlgoView
            end
            
            ctl@ControllerBase(model, view);
            ctl.selectAlgoView = view;
            
        end
        
    end
    
    methods ( Access = private )

        function on_algo_selected(con)
            disp("SelectAlgoController::on_algo_selected")
            con.Model.WS.Algo = con.View.ButtonGroup.SelectedObject.UserData;
            con.Model.save_and_update();
        end

        function on_workspace_updated(con)
            disp("SelectAlgoController::on_workspace_updated")
            switch con.Model.WS.Algo
                case Algorithm.MicroFluor
                    con.View.ButtonGroup.SelectedObject = con.View.MicroFluorButton;

                case Algorithm.MicroDab
                    con.View.ButtonGroup.SelectedObject = con.View.MicroDabButton;

                case Algorithm.AstroFluor
                    con.View.ButtonGroup.SelectedObject = con.View.AstroFluorButton;

                case Algorithm.AstroDab
                    con.View.ButtonGroup.SelectedObject = con.View.AstroDabButton;
            end
        end
        
    end

    methods (Access = protected)
        
        function handle_event(con, event, ~)
            switch event

                case (SelectAlgoEvent.AlgoSelected)
                    con.on_algo_selected()

                case (ModelEvents.WorkspaceUpdated)
                    con.on_workspace_updated()
            end
        end
        
    end
    
end