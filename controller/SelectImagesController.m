classdef SelectImagesController < ControllerBase
    
    properties (Access = private)
        SelectedImage ImageMetadata
        ImageSubviewRect images.roi.Rectangle
        CurrentChannel uint16 = 0
    end
    
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
            data = uint16(str2double(con.View.ImageTable.Data(idx, 2:4)));
            img_md = con.Model.WS.Images(idx);

            % TODO: Move this to model --------
            if ~ImageMetadata.valid_channel_indices(data(1), data(2), data(3), img_md.ChannelCount)
                original_indices = [img_md.RegistrationChannel, img_md.CellMarkerChannel, img_md.CoMarkerChannel];
                con.View.ImageTable.Data(idx, 2:4) = original_indices;
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

        function on_image_selected(con)
            disp("SelectImagesController::on_image_selected")
            if numel(con.View.ImageTable.Selection) == 0
                return
            end
            idx = con.View.ImageTable.Selection(1);
            con.SelectedImage = con.Model.WS.Images(idx);
            if (~isfile(con.SelectedImage.ConvFn) || ~isfile(con.SelectedImage.DownFn))
                con.View.ProcessedImage.ImageSource = zeros(3, 3, 3);
                imshow(zeros(1, 1), 'Parent', con.View.Thumbnail);
            else
                con.CurrentChannel = mod(con.CurrentChannel, con.SelectedImage.ChannelCount);
                con.View.ChannelButton.Text = sprintf("Channel %d/%d", con.CurrentChannel + 1, con.SelectedImage.ChannelCount);
                con.draw_image_subview();
                con.on_image_subview_moved(con.ImageSubviewRect.Position)
            end
        end

        function on_cycle_channel_button_pushed(con) 
            disp("SelectImagesController::on_cycle_channel_button_pushed")
            con.CurrentChannel = mod(con.CurrentChannel + 1, con.SelectedImage.ChannelCount);
            con.on_image_selected();
        end

        function onWorkspaceUpdated(con)
            disp("SelectImagesController::on_workspace_updated")
            img_mds = con.Model.WS.Images;
            source_fns  = Utility.path2name([img_mds.SourceFn]');
            reg_chs     = [img_mds.RegistrationChannel];
            cell_chs    = [img_mds.CellMarkerChannel];
            co_chs      = [img_mds.CoMarkerChannel];
            downsampled = string([img_mds.ConvertStatus]);
            progress    = string([img_mds.ConversionProgress]) + "%";
            new_data    = [source_fns reg_chs' cell_chs' co_chs' downsampled' progress'];
            con.View.ImageTable.Data = new_data;
        end


        function on_image_subview_moved(con, pos)
            disp("SelectImagesController::on_image_subview_moved")
            bbox = round(20 * pos);
            conv_img_fn = con.SelectedImage.ConvFn;
            conv_img = Utility.read_tiff(conv_img_fn, con.CurrentChannel + 1, bbox);
            con.View.ProcessedImage.ImageSource = repmat(imadjust(conv_img(:, :, 1)), 1, 1, 3);
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

                case (SelectImagesEvent.SelectionImageTable)
                    con.on_image_selected()

                case(SelectImagesEvent.ButtonCycleChannel)
                    con.on_cycle_channel_button_pushed()

                case (ModelEvents.WorkspaceUpdated)
                    con.onWorkspaceUpdated()

                case (ModelEvents.ConversionProgress)
                    con.onWorkspaceUpdated()
            end
        end
        
    end

    methods (Access=private)

        function draw_image_subview(con)
            down_fn = con.SelectedImage.DownFn;
            dn_mask = imread(down_fn);
            dn_mask = dn_mask(:, :, con.CurrentChannel + 1);
            imshow(dn_mask, 'Parent', con.View.Thumbnail, 'InitialMagnification', 20);
            if ~isempty(con.ImageSubviewRect)
                delete(con.ImageSubviewRect);
            end
            rect_r = min(size(dn_mask, 1:2)) / 10;
            con.ImageSubviewRect = drawrectangle("Position", [10, 10, rect_r, rect_r], "Parent", con.View.Thumbnail);
            con.ImageSubviewRect.addlistener('ROIMoved', @(~, e) con.on_image_subview_moved(e.CurrentPosition));
        end
    end
    
end