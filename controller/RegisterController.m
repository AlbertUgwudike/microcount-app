classdef RegisterController < ControllerBase
    
    properties (Access = private)
        ImageSet (:, 1) ImageMetadata
        SelectedImage ImageMetadata
        HistPadding (1, 1) uint16 = 100
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
            img = padarray(img, double([con.HistPadding, con.HistPadding]), 0);
            imshow(img, 'Parent', con.View.HistSliceAxes);

            if (isempty(con.SelectedImage.TransformationData))
                img_sz = double(con.SelectedImage.Size) / 20;
                tf_data = TransformationData.default(img_sz, con.View.Atlas.Size);
                con.SelectedImage.TransformationData = tf_data;
            end

            slice_idx = con.SelectedImage.TransformationData.SliceIdx;
            con.View.AtlasSliceSlider.Value = slice_idx;
            con.onAtlasSliceSliderChanged(slice_idx);
            con.draw_hexs()
        end

        function onAlignColorButtonPushed(con)
            disp("RegisterController::onAlignColorButtonPushed")

        end

        function onAlignControlButtonPushed(con)
            disp("RegisterController::onAlignControlButtonPushed")
            atlas_vertices = con.View.AtlasHex.Position;
            hist_vertices = con.View.HistHex.Position;
            tform = fitgeotform2d( ...
                atlas_vertices, ...
                hist_vertices, ...
                'affine' ...
            );
            con.SelectedImage.TransformationData.Transform = tform;
            con.SelectedImage.TransformationData.SliceIdx = round(con.View.AtlasSliceSlider.Value);
            con.SelectedImage.TransformationData.AtlasHex = atlas_vertices;
            con.SelectedImage.TransformationData.HistHex = hist_vertices;
            con.SelectedImage.Aligned = true;
            con.ShowOverlay = true;

            con.Model.io_save()
            con.onWorkspaceUpdated()
        end

        function onToggleOverlayButtonPushed(con)
            disp("RegisterController::onToggleOverlayButtonPushed")
            if con.ShowOverlay
                borders = con.calc_borders();
                img = con.Model.io_get_down_img(con.SelectedImage);
                disp(size(img))
                img = padarray(img, double([con.HistPadding, con.HistPadding]), 0);
                disp(size(img))
                disp(size(borders))
                img = uint16(imadjust(img)) + borders;
                imshow(img, 'Parent', con.View.HistSliceAxes)
            else
            end
            con.ShowOverlay = ~con.ShowOverlay;
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
            new_data  = [[con.ImageSet.SourceFn]' checks];
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

        function borders = calc_borders(con)
            sz = uint16(con.SelectedImage.Size / 20);
            tform_data = con.SelectedImage.TransformationData;
            ann_image = con.View.Atlas.AnnotationAtlas(:, :, tform_data.SliceIdx);
            ref_img = imref2d(sz + [2 * con.HistPadding, 2 * con.HistPadding]);
            tform_mat = tform_data.Transform;
            ali_image = imwarp(ann_image, tform_mat, 'nearest', 'Outputview', ref_img);
            filtered = conv2(ali_image, ones(3) ./ 9, 'same');
            borders = 65536 * uint16(round(filtered) ~= ali_image);
            % borders = borders((con.HistPadding + 1) : sz(1) + con.HistPadding, (con.HistPadding + 1) : sz(2) + con.HistPadding);
        end

    end
    
end