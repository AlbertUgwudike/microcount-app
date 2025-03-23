classdef RegisterController < ControllerBase
    
    properties (Access = private)
        ImageSet (:, 1) ImageMetadata
        SelectedImage ImageMetadata
        ShowOverlay = false
    end

    methods
        
        function ctl = RegisterController(model, view)
            arguments
                model Model
                view RegisterView
            end
            
            ctl@ControllerBase(model, view);
            
        end
        
    end
    
    methods ( Access = private )

        function onAligmentTableSelection(con)
            disp("RegisterController::onAligmentTableSelection")

            if height(con.View.AlignmentTable.Data) == 0
                return
            end
            
            idx = con.View.AlignmentTable.Selection;
            con.SelectedImage = con.ImageSet(idx);
            img = con.Model.io_get_down_img(con.SelectedImage);
            img = padarray(img, double([Constants.PAD, Constants.PAD]), 0);
            imshow(img, 'Parent', con.View.HistSliceAxes);

            if (isempty(con.SelectedImage.TransformationData))
                img_sz = double(con.SelectedImage.Size) / 20;
                tf_data = TransformationData.default(img_sz, con.View.Atlas.Size);
                con.SelectedImage.TransformationData = tf_data;
            end

            slice_idx = con.SelectedImage.TransformationData.SliceIdx;
            con.View.AtlasSliceSlider.Value = slice_idx;
            con.onAtlasSliceSliderChanged(slice_idx);
            con.toggleOverlayOn()
        end

        function onAlignColorButtonPushed(con)
            disp("RegisterController::onAlignColorButtonPushed")

        end

        function onAlignControlButtonPushed(con)
            disp("RegisterController::onAlignControlButtonPushed")
            atlas_vertices = con.View.AtlasHex.Position;
            hist_vertices = con.View.HistHex.Position;
            slice_idx = round(con.View.AtlasSliceSlider.Value);
            con.Model.io_align_image(con.SelectedImage, atlas_vertices, hist_vertices, slice_idx);
            con.toggleOverlayOn()
        end

        function onToggleOverlayButtonPushed(con)
            disp("RegisterController::onToggleOverlayButtonPushed")
            if con.ShowOverlay
                con.toggleOverlayOff()
            else
                con.toggleOverlayOn()
            end
        end

        function toggleOverlayOn(con) 
            d_img = con.Model.io_get_down_img(con.SelectedImage);
            p_img = padarray(d_img, double([Constants.PAD, Constants.PAD]), 0);
            tform_d = con.SelectedImage.TransformationData;
            borders = con.Model.Atlas.calc_borders(size(d_img), tform_d);
            imshow(p_img + borders, 'Parent', con.View.HistSliceAxes)
            con.ShowOverlay = true;
            con.draw_hexs()
        end

        function toggleOverlayOff(con) 
            d_img = con.Model.io_get_down_img(con.SelectedImage);
            img = padarray(d_img, double([Constants.PAD, Constants.PAD]), 0);
            imshow(img, 'Parent', con.View.HistSliceAxes)
            con.ShowOverlay = false;
            con.draw_hexs()
        end

        function onAtlasSliceSliderChanged(con, slider_pos)
            n_slices = con.View.Atlas.Size(3);
            idx = max(0, min(n_slices, round(slider_pos)));
            con.View.CurrentAtlasSliceIdx = idx;
            img = con.View.Atlas.ReferenceAtlas(:, :, con.View.CurrentAtlasSliceIdx);
            imshow(imadjust(img), 'Parent', con.View.AtlasSliceAxes)
        end

        function onSliderStop(con)
            con.draw_hexs()
        end

        function onWorkspaceUpdated(con) 
            disp("RegisterController::on_workspace_updated")
            down_idx  = [con.Model.WS.Images.DownSampled];
            con.ImageSet = con.Model.WS.Images(down_idx);
            checks = Utility.apply_check([con.ImageSet.Aligned]');
            fns = Utility.path2name([con.ImageSet.SourceFn]');
            new_data  = [fns checks];
            con.View.AlignmentTable.Data = new_data;
        end
        
    end

    methods (Access = protected)
        
        function handle_event(con, event, data)
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
                    con.onAtlasSliceSliderChanged(data)

                case (RegisterEvent.SliderStop)
                    con.onSliderStop()

                case (ModelEvents.WorkspaceUpdated)
                    con.onWorkspaceUpdated()
            end
        end
        
    end

    methods (Access=private)

        function poly = draw_hex(~, pos, parent)
            poly = drawpolygon('Position', pos, 'Parent', parent);
        end

        function draw_hexs(con)
            tf_data = con.SelectedImage.TransformationData;

            delete(con.View.AtlasHex)
            delete(con.View.HistHex)

            con.View.CurrentAtlasSliceIdx = tf_data.SliceIdx;
            con.View.AtlasHex = con.draw_hex(tf_data.AtlasHex, con.View.AtlasSliceAxes);
            con.View.HistHex = con.draw_hex(tf_data.HistHex, con.View.HistSliceAxes);
        end

    end
    
end