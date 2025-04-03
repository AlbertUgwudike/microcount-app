classdef AnalyseController < ControllerBase
    
    properties (Access = private)
        RegionSet (:, 1) Region
        SelectedRegion Region
        ImageSubviewRect images.roi.Rectangle
    end

    methods
        
        function ctl = AnalyseController(model, view)
            arguments
                model Model
                view AnalyseView
            end
            
            ctl@ControllerBase(model, view);
            
        end
        
    end
    
    methods ( Access = private )

        function on_region_selected(con)
            disp("AnalyseController::on_region_selected")
            idx = con.View.RegionTable.Selection(1);
            con.SelectedRegion = con.RegionSet(idx);
            result = con.SelectedRegion.Result;
            con.draw_image_subview();
            if (isempty(result))
                con.View.ProcessedImage.ImageSource = "";
                con.set_text_areas_empty()
            else
                con.on_image_subview_moved(con.ImageSubviewRect.Position)
                con.set_text_areas(result)
            end
        end

        function on_cell_edited(con, event)
            disp("AnalyseController::on_cell_edited")
            idx = event.Indices(1, 1);
            data = con.View.RegionTable.Data(idx, 2:4);
            region = con.RegionSet(idx);

            if ~Region.valid_setting_str_list(data)
                original_settings = region.get_setting_str_list();
                con.View.RegionTable.Data(idx, 2:4) = original_settings;
            else
                con.RegionSet(idx).apply_setting_str_list(data);
                con.Model.io_save()
            end
        end

        function on_apply_setting_button_pushed(con) 
            disp("AnalyseController::on_apply_setting_button_pushed")
        end

        function on_process_selected_button_pushed(con) 
            disp("AnalyseController::on_process_selected_button_pushed")
            selection = con.View.RegionTable.Selection;
            con.Model.io_process_region(con.RegionSet(selection))
        end

        function on_process_all_button_pushed(con) 
            disp("AnalyseController::on_process_all_button_pushed")
        end

        function on_cancel_button_pushed(con) 
            disp("AnalyseController::on_cancel_button_pushed")
            con.Model.io_cancel_microcount_processes()
        end

        function on_export_button_pushed(con) 
            disp("AnalyseController::on_export_button_pushed")
            for i = 1:numel(con.Model.MicrocountFutures)
                fut = con.Model.MicrocountFutures(i);
                disp(fut)
            end
        end

        function on_workspace_update(con) 
            disp("AnalyseController::on_workspace_updated")
            regions = con.Model.get_all_regions();
            if isempty(regions)
                con.View.RegionTable.Data = repmat(string.empty, 1, 3);
                return
            end
            con.RegionSet = regions;
            region_ids = [con.RegionSet.ID]';
            iba1_col = [con.RegionSet.Iba1Threshold]';
            cd68_col = [con.RegionSet.CD68Threshold]';
            max_col = [con.RegionSet.MaxCD68Size]';
            pro_col = string([con.RegionSet.ProcessStatus]');
            con.View.RegionTable.Data = [region_ids iba1_col cd68_col max_col pro_col];

            if height(con.RegionSet) > 0 && isempty(con.View.RegionTable.Selection)
                con.View.RegionTable.Selection = 1;
                con.on_region_selected()
            end
        end

        function on_image_subview_moved(con, pos)
            disp("AnalyseController::on_image_subview_moved")
            bbox = round(20 * pos);
            ws_dir = con.Model.WS.DirName;
            proc_img_fn = con.SelectedRegion.ProcFn;
            pixel_region = { [bbox(2), bbox(2) + bbox(4)], [bbox(1), bbox(1) + bbox(3)] };
            con.View.ProcessedImage.ImageSource = imread(proc_img_fn, PixelRegion = pixel_region);
        end
        
    end

    methods (Access = protected)
        
        function handle_event(con, event, data)
            switch event

                case (AnalyseEvent.SelectionRegionTable)
                    con.on_region_selected()

                case (AnalyseEvent.CellEdited)
                    con.on_cell_edited(data)

                case (AnalyseEvent.ButtonApplySetting)
                    con.on_apply_setting_button_pushed()

                case (AnalyseEvent.ButtonProcessSelected)
                    con.on_process_selected_button_pushed()

                case (AnalyseEvent.ButtonProcessAll)
                    con.on_process_all_button_pushed()

                case (AnalyseEvent.ButtonCancel)
                    con.on_cancel_button_pushed()

                case (AnalyseEvent.ButtonExport)
                    con.on_export_button_pushed()

                case (ModelEvents.WorkspaceUpdated)
                    con.on_workspace_update()
            end
        end
        
    end

    methods (Access=private)

        function draw_image_subview(con)
            arguments
                con AnalyseController
            end

            mask_fn = con.SelectedRegion.MaskFn;
            dn_mask = imread(mask_fn);
            imshow(imadjust(uint8(dn_mask)), 'Parent', con.View.Thumbnail, 'InitialMagnification', 20);
            if ~isempty(con.ImageSubviewRect)
                delete(con.ImageSubviewRect);
            end
            con.ImageSubviewRect = drawrectangle("Position", [10, 10, 100, 100], "Parent", con.View.Thumbnail);
            con.ImageSubviewRect.addlistener('ROIMoved', @(~, e) con.on_image_subview_moved(e.CurrentPosition));
        end

        function set_text_areas(con, result)
            arguments
                con AnalyseController
                result MicrocountResult
            end

            con.View.PercentageIba1AreaTextArea.Value = string(result.PercentageIba1Area);
            con.View.CellCountTextArea.Value = string(result.MicrogliaDensity);
            con.View.PercentageCD68AreaTextArea.Value = string(result.PercentageCD68Area);
            con.View.PercentageCD68NumTextArea.Value = string(result.PercentageActivatedMicroglia);
            con.View.BranchCountTextArea.Value = string(result.AverageBranchCount);
            con.View.ConvexityTextArea.Value = string(result.AverageRotundity);

        end

        function set_text_areas_empty(con)
            arguments
                con AnalyseController
            end
            disp("yaas")
            con.View.PercentageIba1AreaTextArea.Value = "--";
            con.View.CellCountTextArea.Value = "--";
            con.View.PercentageCD68AreaTextArea.Value = "--";
            con.View.PercentageCD68NumTextArea.Value = "--";
            con.View.BranchCountTextArea.Value = "--";
            con.View.ConvexityTextArea.Value = "--";
        end
    end
    
end