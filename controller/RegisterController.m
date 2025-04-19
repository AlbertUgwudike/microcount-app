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

            if numel(con.View.AlignmentTable.Selection) == 0
                return
            end
            
            idx = con.View.AlignmentTable.Selection;
            con.SelectedImage = con.ImageSet(idx);

            p_size = con.SelectedImage.DownSize;

            if (isempty(con.SelectedImage.TransformationData))
                con.set_default_tform_data(p_size, Direction.North)
            end
            
            con.AtlasOrientation = con.SelectedImage.TransformationData.Orientation;
            slice_idx = con.SelectedImage.TransformationData.SliceIdx;
            n_slices = con.Model.Atlas.n_slices(con.AtlasOrientation);
            con.View.AtlasSliceSlider.Limits = [1, n_slices];
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
            fprintf("Img Direciton: %s\n", tform_d.Direction);
            fprintf("Con sz: [%d, %d]\n", tform_d.get_img_sz())
            fprintf("p-img size: [%d, %d]\n", size(p_img));
            fprintf("borders size: [%d, %d]\n", size(borders));
            imshow(imadjust(p_img) + uint16(borders), 'Parent', con.View.HistSliceAxes)
            con.ShowOverlay = true;
            con.draw_hexs()
        end

        function toggleOverlayOff(con) 
            disp("RegisterController::onToggleOverlayOff")
            d_img = con.Model.io_get_down_img(con.SelectedImage);
            img = padarray(d_img, double([Constants.PAD, Constants.PAD]), 0);
            imshow(imadjust(img), 'Parent', con.View.HistSliceAxes, 'Border','tight')
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
            con.set_default_tform_data(tform.get_img_sz(), tform.Direction);
            n_slices = con.Model.Atlas.n_slices(con.AtlasOrientation);
            con.View.AtlasSliceSlider.Limits = [1, n_slices];
            con.onAtlasSliceSliderChanged(tform.SliceIdx);
            con.draw_hexs();
            con.toggleOverlayOff()
        end

        function onAtlasSliceSliderChanged(con, slider_pos)
            ori = con.AtlasOrientation;
            n_slices = con.Model.Atlas.n_slices(ori);
            idx = max(0, min(n_slices, round(slider_pos)));
            img = con.Model.Atlas.get_reference_img(ori, idx);
            imshow(imadjust(img), 'Parent', con.View.AtlasSliceAxes)
            con.View.LateralityLabel.Text = con.Model.Atlas.get_laterality_label(ori, idx);
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

        function [poly, labels] = draw_hex(con, pos, parent, sep)
            poly = drawpolygon('Position', pos, 'Parent', parent, 'FaceAlpha', 0);
            labels = [];
            for i = 1:6
                txt = sprintf("V%d", i);
                labels(i) = text(pos(i, 1) + sep, pos(i, 2), txt, 'Parent', parent, 'BackgroundColor', 'w', 'FontWeight','bold');
            end
            addlistener(poly, "ROIMoved", @(~, ~) con.draw_hexs(1));
        end

        function draw_hexs(con, use_view)
            arguments
                con
                use_view = false
            end

            tf_data = con.SelectedImage.TransformationData;

            if use_view 
                atlas_hex_pos = con.View.AtlasHex.Position;
                his_hex_pos = con.View.HistHex.Position;
            else
                atlas_hex_pos = tf_data.AtlasHex;
                his_hex_pos = tf_data.HistHex;
            end

            delete(con.View.AtlasHex)
            delete(con.View.HistHex)

            if isgraphics(con.View.AtlasHexLabels)
                delete(con.View.AtlasHexLabels)
            end
            if isgraphics(con.View.HistHexLabels)
                delete(con.View.HistHexLabels)
            end

            [atlas_hex, atlas_hex_labels] = con.draw_hex(atlas_hex_pos, con.View.AtlasSliceAxes, 7);
            [hist_hex, hist_hex_labels] = con.draw_hex(his_hex_pos, con.View.HistSliceAxes, 60);
            
            con.View.AtlasHex = atlas_hex;
            con.View.HistHex = hist_hex;

            con.View.AtlasHexLabels = atlas_hex_labels;
            con.View.HistHexLabels = hist_hex_labels;
        end

        function set_default_tform_data(con, rot_sz, dir)
            ori = con.AtlasOrientation;
            rot_sz = double(rot_sz);
            ori_sz = con.SelectedImage.DownSize + 2 * Constants.PAD;
            atlas_sz = con.Model.Atlas.get_size(ori);
            n_slices = con.Model.Atlas.n_slices(ori);
            tf_data = TransformationData.default(ori_sz, rot_sz, atlas_sz, n_slices, dir, ori);
            con.SelectedImage.TransformationData = tf_data;
        end

    end
    
end