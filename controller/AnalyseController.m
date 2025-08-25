classdef AnalyseController < ControllerBase
    
    properties (Access = private)
        RegionSet (:, 1) Region
        SelectedRegion Region
        ImageSubviewRect images.roi.Rectangle
        OverlayFlag (1, 4) logical = [false, false, false, false];
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
            if numel(con.View.RegionTable.Selection) == 0
                return
            end
            idx = con.View.RegionTable.Selection(1);
            con.SelectedRegion = con.RegionSet(idx);
            result = con.SelectedRegion.Result;
            con.draw_image_subview();
            if (isempty(result))
                con.View.ProcessedImage.ImageSource = zeros(3, 3, 3);
                con.set_text_areas_empty()
            else
                con.on_image_subview_moved(con.ImageSubviewRect.Position)
                con.set_text_areas(result)
            end
        end

        function on_cell_edited(con, event, save_model)
            arguments
                con 
                event 
                save_model = false
            end
            disp("AnalyseController::on_cell_edited")
            idx = event.Indices(1, 1);
            data = con.View.RegionTable.Data(idx, 2:6);
            region = con.RegionSet(idx);

            if ~Region.valid_setting_str_list(data)
                original_settings = region.get_setting_str_list();
                con.View.RegionTable.Data(idx, 2:6) = original_settings;
            else
                con.RegionSet(idx).apply_setting_str_list(data);
                if save_model
                    con.Model.io_save()
                end
            end
        end

        function on_apply_setting_button_pushed(con) 
            disp("AnalyseController::on_apply_setting_button_pushed")
            options = [ ...
                con.View.CellThresholdEditField.Value, ...
                con.View.CoMarkerThresholdEditField.Value, ...
                con.View.MaxSizeEditField.Value, ...
                con.View.OverlapEditField.Value, ...
                con.View.SomaThresholdEditField.Value ...
            ];

            selection = con.View.RegionTable.Selection;
            for i = 1:numel(selection)
                event.Indices = selection(i);
                con.View.RegionTable.Data(event.Indices, 2:6) = options;
                con.on_cell_edited(event, false)
            end
            con.Model.io_save()
        end

        function on_select_unprocessed_button_pushed(con) 
            disp("AnalyseController::on_select_unprocessed_button_pushed")
            regions = con.Model.get_all_regions();
            idx = [regions.ProcessStatus] ~= ProcessStatus.PROCESSED;
            all_idx = 1:numel(regions);
            con.View.RegionTable.Selection = all_idx(idx);
        end

        function on_process_selected_button_pushed(con) 
            disp("AnalyseController::on_process_selected_button_pushed")
            selection = con.View.RegionTable.Selection;
            con.Model.io_process_region(con.RegionSet(selection))
        end

        function on_select_all_button_pushed(con) 
            disp("AnalyseController::on_process_all_button_pushed")
            N = height(con.View.RegionTable.Data);
            con.View.RegionTable.Selection = 1:N;

        end

        function on_magic_button_pushed(con)
            beginnings = ["24_6_", "24_5_", "24_3_", ];
            regionIDs = con.View.RegionTable.Data(:, 1);
            idx = arrayfun(@(s) ismember(s.extractBetween(1, 5), beginnings), regionIDs);
            N = height(con.View.RegionTable.Data);
            all_idxs = 1:N;
            con.View.RegionTable.Selection = all_idxs(idx);
            con.View.RegionTable.Data(all_idxs(idx), 3) = 0.55;

            for i = 1:numel(con.View.RegionTable.Selection)
                event.Indices = con.View.RegionTable.Selection(i);
                con.on_cell_edited(event, false)
            end
        end

        function on_algo_selected(con)
            disp("AnalyseController::on_algo_selected")
            con.Model.WS.Algo = con.View.AlgoSelector.Value;
            con.Model.io_save();
            disp(con.Model.WS.Algo)
        end

        function on_cancel_button_pushed(con) 
            disp("AnalyseController::on_cancel_button_pushed")
            con.Model.io_cancel_microcount_processes()
        end

        function on_export_button_pushed(con) 
            disp("AnalyseController::on_export_button_pushed")
            idx = [con.RegionSet.ProcessStatus] == ProcessStatus.PROCESSED;
            con.Model.io_export_results(con.RegionSet(idx));
        end

        function on_workspace_update(con) 
            disp("AnalyseController::on_workspace_updated")
            regions = con.Model.get_all_regions();
            if isempty(regions)
                con.View.RegionTable.Data = repmat(string.empty, 1, 3);
                return
            end
            con.RegionSet   = regions;
            region_ids      = [con.RegionSet.ID]';
            iba1_col        = [con.RegionSet.Iba1Threshold]';
            cd68_col        = [con.RegionSet.CD68Threshold]';
            max_col         = [con.RegionSet.MaxCD68Size]';
            act_col         = [con.RegionSet.OverlapPercentage]';
            soma_col        = [con.RegionSet.SomaThreshold]';
            pro_col         = string([con.RegionSet.ProcessStatus]');
            con.View.RegionTable.Data = [region_ids iba1_col cd68_col max_col act_col soma_col, pro_col];
            con.View.AlgoSelector.Value = con.Model.WS.Algo;

            if height(con.RegionSet) == 0
                return
            end

            if isempty(con.View.RegionTable.Selection)
                con.View.RegionTable.Selection = 1;
            end
            
            con.on_region_selected()
        end

        function on_overlay_toggled(con, idx) 
            disp("AnalyseController::on_overlay_toggled")
            con.OverlayFlag(idx) = ~con.OverlayFlag(idx);
            con.on_image_subview_moved(con.ImageSubviewRect.Position);
        end

        function on_image_subview_moved(con, pos)
            disp("AnalyseController::on_image_subview_moved")
            bbox = round(20 * pos);
            proc_img_fn = con.SelectedRegion.ProcFn;
            pixel_region = { [bbox(2), bbox(2) + bbox(4)], [bbox(1), bbox(1) + bbox(3)] };

            img = uint16(zeros([bbox(4) + 1, bbox(3) + 1, 3]));

            if con.OverlayFlag(1)
                chn = imread(proc_img_fn, PixelRegion = pixel_region, Index = 1);
                img(:, :, 1) = img(:, :, 1) + chn(:, :, 1);
            end

            if con.OverlayFlag(2)
                chn = imread(proc_img_fn, PixelRegion = pixel_region, Index = 2);
                img(:, :, 2) = img(:, :, 2) + chn(:, :, 1);
            end

            if con.OverlayFlag(3)
                chn = imread(proc_img_fn, PixelRegion = pixel_region, Index = 3);
                img(chn > 0) = chn(chn > 0);
            end

            if con.OverlayFlag(4)
                chn = imread(proc_img_fn, PixelRegion = pixel_region, Index = 4);
                img(chn > 0) = 0;
                img(:, :, 3) = img(:, :, 3) + 60000 *chn(:, :, 1);
            end

            con.View.ProcessedImage.ImageSource = img;
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

                case (AnalyseEvent.ButtonSelectUnprocessed)
                    con.on_select_unprocessed_button_pushed()

                case (AnalyseEvent.ButtonProcessSelected)
                    con.on_process_selected_button_pushed()

                case (AnalyseEvent.ButtonSelectAll)
                    con.on_select_all_button_pushed()

                case (AnalyseEvent.ButtonCancel)
                    con.on_cancel_button_pushed()

                case (AnalyseEvent.ButtonExport)
                    con.on_export_button_pushed()

                case (ModelEvents.UpdateAnaylseTab)
                    con.on_workspace_update()

                case (ModelEvents.WorkspaceUpdated)
                    con.on_workspace_update()

                case (AnalyseEvent.ButtonMagic)
                    % con.on_magic_button_pushed()

                case (AnalyseEvent.AlgoSelected)
                    con.on_algo_selected()

                case (AnalyseEvent.Overlay)
                    con.on_overlay_toggled(data)
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
            imshow(dn_mask, 'Parent', con.View.Thumbnail, 'InitialMagnification', 20);
            if ~isempty(con.ImageSubviewRect)
                delete(con.ImageSubviewRect);
            end
            rect_r = min(size(dn_mask, 1:2)) / 5;
            con.ImageSubviewRect = drawrectangle("Position", [10, 10, rect_r, rect_r], "Parent", con.View.Thumbnail);
            con.ImageSubviewRect.addlistener('ROIMoved', @(~, e) con.on_image_subview_moved(e.CurrentPosition));
        end

        function set_text_areas(con, result)
            arguments
                con AnalyseController
                result MicrocountResult
            end
            con.View.PercentageCellAreaLabel.Text      = con.stick(Constants.LABEL_CELL_AREA   , string(result.PercentageIba1Area));
            con.View.CellCountLabel.Text               = con.stick(Constants.LABEL_CELL_DENSITY, string(result.MicrogliaDensity));
            con.View.PercentageCoMarkerAreaLabel.Text  = con.stick(Constants.LABEL_CO_AREA     , string(result.PercentageCD68Area));
            con.View.PercentageCoMarkerNumLabel.Text   = con.stick(Constants.LABEL_CO_NUM      , string(result.PercentageActivatedMicroglia));
            con.View.BranchLengthLabel.Text            = con.stick(Constants.LABEL_LENGTH      , string(result.AverageBranchLengthUm));
            con.View.BranchCountLabel.Text             = con.stick(Constants.LABEL_BRANCH      , string(result.AverageBranchCount));
            con.View.ConvexityLabel.Text               = con.stick(Constants.LABEL_CONVEXITY   , string(result.AverageRotundity));
            con.View.SchollLabel.Text                  = con.stick(Constants.LABEL_SCHOLL      , string(result.AverageSchollIndex));

        end

        function set_text_areas_empty(con)
            arguments
                con AnalyseController
            end
            con.View.PercentageCellAreaLabel.Text      = con.stick(Constants.LABEL_CELL_AREA   , "--");
            con.View.CellCountLabel.Text               = con.stick(Constants.LABEL_CELL_DENSITY, "--");
            con.View.PercentageCoMarkerAreaLabel.Text  = con.stick(Constants.LABEL_CO_AREA     , "--");
            con.View.PercentageCoMarkerNumLabel.Text   = con.stick(Constants.LABEL_CO_NUM      , "--");
            con.View.BranchCountLabel.Text             = con.stick(Constants.LABEL_BRANCH      , "--");
            con.View.BranchLengthLabel.Text            = con.stick(Constants.LABEL_LENGTH      , "--");
            con.View.ConvexityLabel.Text               = con.stick(Constants.LABEL_CONVEXITY   , "--");
            con.View.SchollLabel.Text                  = con.stick(Constants.LABEL_SCHOLL      , "--");
        end
    end

    methods (Static)
        function s = stick(s1, s2)
            format_str = join(repmat("%s\n", 1, numel(s1)), "") + "%s";
            s = sprintf(format_str, s1, s2);
        end
    end
    
end