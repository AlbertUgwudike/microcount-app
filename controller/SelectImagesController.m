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
            data = uint16(str2double(con.View.ImageTable.Data(idx, 3:5)));
            img_md = con.Model.WS.Images(idx);

            % TODO: Move this to model --------
            if ~ImageMetadata.valid_channel_indices(data(1), data(2), data(3), img_md.ChannelCount)
                original_indices = [img_md.RegistrationChannel, img_md.CellMarkerChannel, img_md.CoMarkerChannel];
                con.View.ImageTable.Data(idx, 3:5) = original_indices;
            else
                con.Model.update_channel_indices(idx, data(1), data(2), data(3));
                con.Model.io_save()
            end
        end

        function on_apply_channel_order_button_pushed(con)
            disp("SelectImagesController::on_apply_channel_order_button_pushed")
            reg_ch  = uint16(con.View.RegistrationChannelField.Value);
            cell_ch = uint16(con.View.CellMarkerChannelField.Value);
            co_ch   = uint16(con.View.CoMarkerChannelField.Value);
            idx = con.View.ImageTable.Selection;
            for i = 1:numel(idx)
                con.Model.update_channel_indices(idx(i), reg_ch, cell_ch, co_ch);
            end
        end

        function on_cancel_all_button_pushed(con)
            disp("SelectImagesController::on_cancel_all_button_pushed")
            con.Model.io_cancel_microcount_processes()
        end

        function onWorkspaceUpdated(con)
            disp("SelectImagesController::on_workspace_updated")
            img_mds = con.Model.WS.Images;
            source_fns  = Utility.path2name([img_mds.SourceFn]');
            ch_counts   = [img_mds.ChannelCount];
            reg_chs     = [img_mds.RegistrationChannel];
            cell_chs    = [img_mds.CellMarkerChannel];
            co_chs      = [img_mds.CoMarkerChannel];
            downsampled = string([img_mds.ConvertStatus]);
            progress    = string([img_mds.ConversionProgress]) + "%";
            new_data    = [source_fns ch_counts' reg_chs' cell_chs' co_chs' downsampled' progress'];
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

                case (SelectImagesEvent.ButtonApplyChannelIndex)
                    con.on_apply_channel_order_button_pushed()

                case (SelectImagesEvent.ChannelOrderEdited)
                    con.on_channel_order_edited(d)

                case (SelectImagesEvent.ButtonCancel)
                    con.on_cancel_all_button_pushed()

                case (ModelEvents.WorkspaceUpdated)
                    con.onWorkspaceUpdated()

                case (ModelEvents.ConversionProgress)
                    con.onWorkspaceUpdated()
            end
        end
        
    end
    
end