classdef SelectImagesController

    properties ( SetAccess = immutable, GetAccess = protected )
        Model Model
    end 
    
    methods
        
        function ctl = SelectImagesController(model)
            arguments
                model Model
            end
            
            ctl.Model = model;
            
        end
        
    end
    
    methods ( Access = private )

        function onSelectAllButtonPushed(con, ~, ~)
            disp("SelectAllButton")
        end

        function onRemoveButtonPushed(con, ~, ~)
            disp("RemoveButton")
        end

        function onConvertDownsampleButtonPushed(con, ~, ~)
            disp("ConvertDownsampleButton")
        end

        function onAddImagesButtonPushed(con, ~, ~)
            disp("AddImagesButton")
        end
        
    end

    methods (Access = public)
        
        function handle_event(con, event)
            switch event

                case (SelectImagesEvent.ButtonSelectAll)
                    con.onSelectAllButtonPushed()

                case (SelectImagesEvent.ButtonRemoveAll)
                    con.onRemoveButtonPushed()

                case (SelectImagesEvent.ButtonConvertDownsample)
                    con.onConvertDownsampleButtonPushed()

                case (SelectImagesEvent.ButtonAddImages)
                    con.onAddImagesButtonPushed()
            end
        end
        
    end
    
end