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

        function onRegionSelected(con, laterality)
            disp("RegionsController::onRegionSelected")
            region_idx = con.View.RightTable.Selection(2)
            if laterality == Laterality.LEFT
                region_idx = con.View.RightTable.Selection(2)
            else

            end
            idx = con.View.ImageTable.Selection(2);
            if (idx == 1)
                return
            end
            con.Model.io_toggle_region(con.SelectedImage, mod(idx - 1, 6));
        end

        function onWorkspaceUpdated(con) 
            disp("RegionsController::on_workspace_updated")
            reg_idx         = [con.Model.WS.Images.Aligned];
            con.ImageSet    = con.Model.WS.Images(reg_idx);
            disp([con.ImageSet.Regions]')
            region_codes    = ~cellfun('isempty', [con.ImageSet.Regions]');
            region_markers  = Utility.check_or_none(region_codes);
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

                case (RegionsEvent.LeftSelection)
                    con.onRegionSelected(Laterality.LEFT)

                case (RegionsEvent.RightSelection)
                    con.onRegionSelected(Laterality.RIGHT)

                case (ModelEvents.WorkspaceUpdated)
                    con.onWorkspaceUpdated()
            end
        end
        
    end

    methods (Access=private)
        function abrs = get_selected_abrs(con)
            all_abrs = { 'HIP', 'HY', 'TH', 'SS', 'AUD', 'CTXsp','HIP', 'HY', 'TH', 'SS', 'AUD', 'CTXsp' };
            idx = ~cellfun('isempty', [con.SelectedImage.Regions]);
            if any(idx)
                abrs = { all_abrs{idx} };
                disp({ all_abrs{idx} })
            else
                abrs = {};
            end
        end
    end
    
end