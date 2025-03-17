classdef RegisterController < ControllerBase
    
    properties (Access = private)
        ImageSet (:, 1) ImageMetadata
        SelectedImage ImageMetadata
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
            imshow(img, 'Parent', con.View.HistSliceAxes);
        end

        function onAlignColorButtonPushed(con)
            disp("RegisterController::onAlignColorButtonPushed")
        end

        function onAlignControlButtonPushed(con)
            disp("RegisterController::onAlignControlButtonPushed")
        end

        function onToggleOverlayButtonPushed(con)
            disp("RegisterController::onToggleOverlayButtonPushed")
        end

        function onAtlasSliceSliderChanged(con, slider_pos)
            con.View.CurrentAtlasSliceIdx = round(slider_pos);
        end

        function onWorkspaceUpdated(con) 
            disp("RegisterController::on_workspace_updated")

            % Table 
            down_idx  = [con.Model.WS.Images.DownSampled];
            con.ImageSet = con.Model.WS.Images(down_idx);
            new_data  = [[con.ImageSet.SourceFn]' [con.ImageSet.Aligned]'];
            con.View.AlignmentTable.Data = new_data;

            % Slider Position

            % Alignment Hexs

            % Overlay
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

                case (ModelEvents.WorkspaceUpdated)
                    con.onWorkspaceUpdated()
            end
        end
        
    end
    
end