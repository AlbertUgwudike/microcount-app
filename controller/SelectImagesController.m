classdef SelectImagesController < ControllerBase
    
    methods
        
        function ctl = SelectImagesController(model, view)
            arguments
                model Model
                view SelectImagesView
            end
            
            ctl@ControllerBase(model, view)
            
        end
        
    end
    
    methods ( Access = private )

        function onSelectAllButtonPushed(con)
            disp("SelectImagesController::onSelectAllButtonPushed")
        end

        function onRemoveButtonPushed(con)
            disp("SelectImagesController::onRemoveButtonPushed")
        end

        function onConvertDownsampleButtonPushed(con)
            con.Model.io_convert_and_downsample()
        end

        function onAddImagesButtonPushed(con)
            con.Model.io_add_image()
        end

        function onSaveButtonPushed(con)
            con.Model.io_save()
        end

        function onWorkspaceUpdated(con)
            disp("SelectImagesController::on_workspace_updated")
            img_mds = con.Model.WS.Images;
            source_fns  = Utility.path2name([img_mds.SourceFn]');
            converted   = Utility.apply_check([img_mds.Converted]);
            downsampled = Utility.apply_check([img_mds.DownSampled]);
            new_data    = [source_fns converted' downsampled'];
            con.View.ImageSetTable.Data = new_data;
        end
        
    end

    methods (Access = protected)
        
        function handle_event(con, event, ~)
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

                case (ModelEvents.WorkspaceUpdated)
                    con.onWorkspaceUpdated()
            end
        end
        
    end
    
end