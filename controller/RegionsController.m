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
            [l_abrs, r_abrs] = con.get_selected_abrs();
            img = p_img + con.Model.Atlas.calc_borders(tform_d, l_abrs, r_abrs);
            con.View.HistologyImage.ImageSource = cat(3, img, img, img);
        end

        function onRegionSelected(con)
            disp("RegionsController::onRegionSelected")

            idx = con.View.ImageTable.Selection(2);

            if ismember(idx, [1, 2, 9, 16])
                return
            end

            if idx > 9
                lat = Laterality.RIGHT;
                p_idx = idx - 9;
            else
                lat = Laterality.LEFT;
                p_idx = idx - 2;
            end

            con.Model.io_toggle_region(con.SelectedImage, lat, p_idx);
        end

        function onWorkspaceUpdated(con) 
            disp("RegionsController::on_workspace_updated")
            reg_idx         = [con.Model.WS.Images.Aligned];
            con.ImageSet    = con.Model.WS.Images(reg_idx);
            
            if (isempty(con.ImageSet))
                return;
            end

            region_codes    = ~cellfun('isempty', [con.ImageSet.Regions]');

            left_markers    = Utility.check_or_none(region_codes(:, 1:6));
            right_markers   = Utility.check_or_none(region_codes(:, 7:12));
            fns             = Utility.path2name([con.ImageSet.SourceFn]');
            spacer          = arrayfun(@(~) "", 1:numel(fns))';

            con.View.ImageTable.Data = [fns spacer left_markers spacer right_markers];

            if ~isempty(con.SelectedImage)
                disp(con.SelectedImage)
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
                    con.onImageSelected()
                    con.onRegionSelected()

                case (ModelEvents.WorkspaceUpdated)
                    con.onWorkspaceUpdated()
            end
        end
        
    end

    methods (Access=private)
        function [l_abrs, r_abrs] = get_selected_abrs(con)
            all_abrs = { 'HIP', 'HY', 'TH', 'SS', 'AUD', 'CTXsp' };
            idx = ~cellfun('isempty', [con.SelectedImage.Regions]);
            if any(idx)
                l_abrs = { all_abrs{idx(1:6)} };
                r_abrs = { all_abrs{idx(7:12)} };
            else
                l_abrs = {};
                r_abrs = {};
            end
        end
    end
    
end