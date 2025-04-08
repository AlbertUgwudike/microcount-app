classdef RegisterController < ControllerBase
    
    properties (Access = private)
        ImageSet (:, 1) ImageMetadata
        SelectedImage ImageMetadata
        ShowOverlay = false
        AtlasOrientation Orientation = Orientation.Axial
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
            p_img = padarray(img, double([Constants.PAD, Constants.PAD]), 0);
            imshow(p_img, 'Parent', con.View.HistSliceAxes);

            if (isempty(con.SelectedImage.TransformationData))
                con.set_default_tform_data(size(p_img))
            end
            
            con.AtlasOrientation = con.SelectedImage.TransformationData.Orientation;
            slice_idx = con.SelectedImage.TransformationData.SliceIdx;
            con.View.AtlasSliceSlider.Value = slice_idx;
            con.onAtlasSliceSliderChanged(slice_idx);
            con.toggleOverlayOn()
        end

        function onAlignColorButtonPushed(con)
            disp("RegisterController::onAlignColorButtonPushed")
            slice_idx = round(con.View.AtlasSliceSlider.Value);
            ori = con.AtlasOrientation;
            con.Model.io_align_image_col(con.SelectedImage, slice_idx, ori);
            con.toggleOverlayOn()
        end

        function onAlignControlButtonPushed(con)
            disp("RegisterController::onAlignControlButtonPushed")
            atlas_vertices = con.View.AtlasHex.Position;
            hist_vertices = con.View.HistHex.Position;
            slice_idx = round(con.View.AtlasSliceSlider.Value);
            ori = con.AtlasOrientation;
            con.Model.io_align_image_cp(con.SelectedImage, atlas_vertices, hist_vertices, slice_idx, ori);
            con.toggleOverlayOn()
        end

        function onToggleOverlayButtonPushed(con)
            if con.ShowOverlay
                con.toggleOverlayOff()
            else
                con.toggleOverlayOn()
            end
        end

        function toggleOverlayOn(con) 
            disp("RegisterController::onToggleOverlayOn")
            d_img = con.Model.io_get_down_img(con.SelectedImage);
            p_img = padarray(d_img, double([Constants.PAD, Constants.PAD]), 0);
            tform_d = con.SelectedImage.TransformationData;
            borders = con.Model.Atlas.calc_borders(tform_d);
            imshow(p_img + borders, 'Parent', con.View.HistSliceAxes)
            con.ShowOverlay = true;
            con.draw_hexs()
        end

        function toggleOverlayOff(con) 
            disp("RegisterController::onToggleOverlayOff")
            d_img = con.Model.io_get_down_img(con.SelectedImage);
            img = padarray(d_img, double([Constants.PAD, Constants.PAD]), 0);
            imshow(img, 'Parent', con.View.HistSliceAxes, 'Border','tight')
            con.ShowOverlay = false;
            con.draw_hexs()
        end

        function onRotateButtonPushed(con)
            disp("RegisterController::onRotateButtonPushed")
            if isempty(con.SelectedImage)
                return
            end
            con.Model.io_rotate_image(con.SelectedImage);
            con.toggleOverlayOff()
        end

        function onOrientationButtonPushed(con)
            disp("RegisterController::onOrientationButtonPushed")
            if isempty(con.SelectedImage)
                return
            end
            con.AtlasOrientation = con.AtlasOrientation.cycle();
            tform = con.SelectedImage.TransformationData;
            con.set_default_tform_data(tform.get_img_sz());
            con.onAtlasSliceSliderChanged(tform.SliceIdx);
            con.draw_hexs();
            con.toggleOverlayOff()
        end

        function onAtlasSliceSliderChanged(con, slider_pos)
            ori = con.AtlasOrientation;
            n_slices = con.Model.Atlas.n_slices(ori);
            con.View.AtlasSliceSlider.Limits = [1, n_slices];
            % con.View.AtlasSliceSlider.MajorTicks = [1, n_slices];
            idx = max(0, min(n_slices, round(slider_pos)));
            con.View.CurrentAtlasSliceIdx = idx;
            img = con.View.Atlas.get_reference_img(ori, idx);
            imshow(imadjust(img), 'Parent', con.View.AtlasSliceAxes)
        end

        function onSliderStop(con)
            con.draw_hexs()
        end

        function onWorkspaceUpdated(con) 
            disp("RegisterController::on_workspace_updated")
            down_idx  = [con.Model.WS.Images.ConvertStatus] == ConvertStatus.CONVERTED;
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

                case (RegisterEvent.ButtonRotateImage)
                    con.onRotateButtonPushed()

                case (RegisterEvent.ButtonCycleOrientation)
                    con.onOrientationButtonPushed()

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

        function set_default_tform_data(con, img_sz)
            ori = con.AtlasOrientation;
            im_sz = double(img_sz);
            atlas_sz = con.View.Atlas.get_size(ori);
            n_slices = con.View.Atlas.n_slices(ori);
            tf_data = TransformationData.default(im_sz, atlas_sz, n_slices);
            con.SelectedImage.TransformationData = tf_data;
        end

    end
    
end