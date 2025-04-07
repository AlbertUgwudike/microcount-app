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
            N = height(con.View.ImageTable.Data);
            con.View.ImageTable.Selection = 1:N;
        end

        function onRemoveButtonPushed(con)
            disp("SelectImagesController::onRemoveButtonPushed")
            idx = con.View.ImageTable.Selection;
            con.Model.io_remove_images(idx)
        end

        function onConvertDownsampleButtonPushed(con)
            disp("SelectImagesController::onConvertDownsampleButtonPushed")
            idx = con.View.ImageTable.Selection;
            con.Model.io_convert_and_downsample(idx)
        end

        function onAddImagesButtonPushed(con)
            disp("SelectImagesController::onAddImagesButtonPushed")
            con.Model.io_add_image()
        end

        function on_channel_order_edited(con, event)
            disp("SelectImagesController::on_channel_order_edited")
            idx = event.Indices(1);
            ch_str = con.View.ImageTable.Data(idx, 3);
            con.Model.update_channel_order(idx, ch_str);
        end

        function on_apply_channel_order_button_pushed(con)
            disp("SelectImagesController::on_apply_channel_order_button_pushed")
            ch_str = con.View.ChannelOrderField.Value;
            idx = con.View.ImageTable.Selection;
            for i = 1:numel(idx)
                con.Model.update_channel_order(idx(i), ch_str);
            end
        end

        function onWorkspaceUpdated(con)
            disp("SelectImagesController::on_workspace_updated")
            img_mds = con.Model.WS.Images;
            source_fns  = Utility.path2name([img_mds.SourceFn]');
            ch_counts   = [img_mds.ChannelCount];
            ch_orders   = cellfun(@(o) string(o).join(","), {img_mds.ChannelOrder});
            downsampled = string([img_mds.ConvertStatus]);
            new_data    = [source_fns ch_counts' ch_orders' downsampled'];
            con.View.ImageTable.Data = new_data;
        end
        
    end

    methods (Access = protected)
        
        function handle_event(con, event, d)
            switch event

                case (SelectImagesEvent.ButtonSelectAll)
                    con.onSelectAllButtonPushed()

                case (SelectImagesEvent.ButtonRemoveSelected)
                    con.onRemoveButtonPushed()

                case (SelectImagesEvent.ButtonConvert)
                    con.onConvertDownsampleButtonPushed()

                case (SelectImagesEvent.ButtonAddImages)
                    con.onAddImagesButtonPushed()

                case (SelectImagesEvent.ButtonApplyChannelOrder)
                    con.on_apply_channel_order_button_pushed()

                case (SelectImagesEvent.ChannelOrderEdited)
                    con.on_channel_order_edited(d)

                case (ModelEvents.WorkspaceUpdated)
                    con.onWorkspaceUpdated()
            end
        end
        
    end
    
end