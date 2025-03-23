classdef RegionsController < ControllerBase
    
    properties (Access = private)
        ImageSet (:, 1) ImageMetadata
        SelectedImage ImageMetadata
    end

    methods
        
        function ctl = RegionsController(model, view)
            arguments
                model Model
                view RegionsView
            end
            
            ctl@ControllerBase(model, view);
            
        end
        
    end
    
    methods ( Access = private )

        function onImageSelected(con)
            idx = con.View.ImageTable.Selection(1);
            con.SelectedImage = con.ImageSet(idx);
            d_img = con.Model.io_get_down_img(con.SelectedImage);
            p_img = padarray(d_img, double([Constants.PAD, Constants.PAD]), 0);
            tform_d = con.SelectedImage.TransformationData;
            abrs = con.get_selected_abrs();
            img = p_img + con.Model.Atlas.calc_borders(size(d_img), tform_d, abrs);
            con.View.HistologyImage.ImageSource = cat(3, img, img, img);
        end

        function onRegionSelected(con)
            disp("RegionsController::onRegionSelected")
            idx = con.View.ImageTable.Selection(2);
            if (idx == 1)
                return
            end
            con.Model.io_toggle_region(con.SelectedImage, idx - 1);
        end

        function onWorkspaceUpdated(con) 
            disp("RegionsController::on_workspace_updated")
            reg_idx         = [con.Model.WS.Images.Aligned];
            con.ImageSet    = con.Model.WS.Images(reg_idx);
            region_codes    = ~isempty([con.ImageSet.Regions]');
            region_markers  = Utility.apply_check(region_codes);
            fns             = Utility.path2name([con.ImageSet.SourceFn]');
            new_data        = [fns region_markers];
            con.View.ImageTable.Data = new_data;
            if ~isempty(con.SelectedImage)
                con.onImageSelected()
            end
        end
        
    end

    methods (Access = protected)
        
        function handle_event(con, event, ~)
            switch event

                case (RegionsEvent.SelectionImageTable)
                    con.onImageSelected()

                case (RegionsEvent.RegionSelection)
                    con.onRegionSelected()

                case (ModelEvents.WorkspaceUpdated)
                    con.onWorkspaceUpdated()
            end
        end
        
    end

    methods (Access=private)
        function abrs = get_selected_abrs(con)
            all_abrs = { 'HIP', 'HY', 'TH', 'SS', 'AUD', 'CTXsp' };
            idx = [con.SelectedImage.RegionCodes];
            if any(idx)
                abrs = { all_abrs{idx} };
                disp({ all_abrs{idx} })
            else
                abrs = {};
            end
        end
    end
    
end