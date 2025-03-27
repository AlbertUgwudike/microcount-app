classdef AnalyseController < ControllerBase
    
    properties (Access = private)
        RegionSet (:, 1) Region
        SelectedRegion Region
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
            fn = con.SelectedRegion.get_processed_img_fn(con.Model.WS.DirName);
            if (isfile(fn))
                img = imread(fn);
                con.View.ProcessedImage.ImageSource = img;
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
            con.Model.io_process_region(con.SelectedRegion)
        end

        function on_process_all_button_pushed(con) 
            disp("AnalyseController::on_process_all_button_pushed")
        end

        function on_export_button_pushed(con) 
            disp("AnalyseController::on_export_button_pushed")
        end

        function on_workspace_update(con) 
            disp("AnalyseController::on_workspace_updated")
            regions = con.Model.get_all_regions();
            if isempty(regions)
                return
            end
            con.RegionSet = regions;
            region_ids = [con.RegionSet.ID]';
            iba1_col = [con.RegionSet.Iba1Threshold]';
            cd68_col = [con.RegionSet.CD68Threshold]';
            max_col = [con.RegionSet.MaxCD68Size]';
            pro_col = Utility.check_or_none([con.RegionSet.Processed]');
            con.View.RegionTable.Data = [region_ids iba1_col cd68_col max_col pro_col];

            if height(con.RegionSet) > 0
                con.View.RegionTable.Selection = 1;
                con.on_region_selected()
            end
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

                case (AnalyseEvent.ButtonExport)
                    con.on_export_button_pushed()

                case (ModelEvents.WorkspaceUpdated)
                    con.on_workspace_update()
            end
        end
        
    end

    methods (Access=private)

    end
    
end