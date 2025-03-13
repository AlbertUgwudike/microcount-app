classdef RegisterController

    properties (SetAccess = immutable, GetAccess = protected)
        Model Model
    end 
    
    methods
        
        function ctl = RegisterController(model)
            arguments
                model Model
            end
            
            ctl.Model = model;
            
        end
        
    end
    
    methods ( Access = private )

        function onAligmentTableSelection(con, ~, ~)
            disp("RegisterController::onAligmentTableSelection")
        end

        function onAlignColorButtonPushed(con, ~, ~)
            disp("RegisterController::onAlignColorButtonPushed")
        end

        function onAlignControlButtonPushed(con, ~, ~)
            disp("RegisterController::onAlignControlButtonPushed")
        end

        function onToggleOverlayButtonPushed(con, ~, ~)
            disp("RegisterController::onToggleOverlayButtonPushed")
        end

        function onAtlasSliceSliderChanged(con, ~, ~)
            disp("RegisterController::onAtlasSliceSliderChanged")
        end
        
    end

    methods (Access = public)
        
        function handle_event(con, event)
            switch event

                case (RegisterEvent.SelectionAlignmentTable)
                    con.onAligmentTableSelection()

                case (RegisterEvent.ButtonAlignColor)
                    con.onAlignColorButtonPushed()

                case (RegisterEvent.ButtonAlignControl)
                    con.onAlignControlButtonPushed()

                case (RegisterEvent.ButtonToggleOverlay)
                    con.onToggleOverlayButtonPushed()

                case (RegisterEvent.SliderAtlasSlice)
                    con.onAtlasSliceSliderChanged()
            end
        end
        
    end
    
end