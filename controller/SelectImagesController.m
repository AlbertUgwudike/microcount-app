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
            disp("showman")
            con.Model.io_convert_and_downsample()
        end

        function onAddImagesButtonPushed(con, ~, ~)
            con.Model.io_add_image()
        end

        function onSaveButtonPushed(con, ~, ~)
            con.Model.io_save()
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

                case (AppEvent.ButtonSave)
                    con.onSaveButtonPushed()
            end
        end
        
    end
    
end