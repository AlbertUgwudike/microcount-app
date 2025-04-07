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
            selection = con.View.ImageTable.Selection;
            if isempty(selection)
                return
            end
            idx = selection(1);
            con.SelectedImage = con.ImageSet(idx);
            d_img = con.Model.io_get_down_img(con.SelectedImage);
            p_img = padarray(d_img, double([Constants.PAD, Constants.PAD]), 0);
            tform_d = con.SelectedImage.TransformationData;
            locs = con.SelectedImage.all_locations();
            img = p_img + con.Model.Atlas.calc_borders(tform_d, locs);
            con.View.HistologyImage.ImageSource = cat(3, img, img, img);
        end

        function onRegionChecked(con)
            disp("RegionsController::onRegionChecked")
            locs = con.get_selected_locs();
            disp(locs)
        end

        function onAddToSelectedButtonPushed(con)
            disp("RegionsController::onAddToSelectedButtonPushed")
            if (isempty(con.View.ImageTable.Selection))
                return
            end
            idx = con.View.ImageTable.Selection;
            locs = con.get_selected_locs();
            for i = 1:numel(idx)
                img_md = con.ImageSet(idx(i));
                con.Model.io_update_regions(img_md, locs);
            end
        end

        function onDeselectAllButtonPushed(con)
            disp("RegionsController::onDeselectAllButtonPushed")
            con.View.RegionSelector.CheckedNodes = [];
        end

        function onEraseRegionsButtonPushed(con)
            disp("RegionsController::onEraseRegionsButtonPushed")
            if (isempty(con.View.ImageTable.Selection))
                return
            end
            idx = con.View.ImageTable.Selection;
            for i = 1:numel(idx)
                img_md = con.ImageSet(idx(i));
                con.Model.io_update_regions(img_md, Location.empty);
            end
        end

        function onSelectAllButtonPushed(con)
            disp("RegionsController::onSelectAllButtonPushed")
            N = height(con.View.ImageTable.Data);
            con.View.ImageTable.Selection = 1:N;
        end

        function onWorkspaceUpdated(con) 
            disp("RegionsController::on_workspace_updated")

            reg_idx         = [con.Model.WS.Images.Aligned];
            con.ImageSet    = con.Model.WS.Images(reg_idx);
            
            if (isempty(con.ImageSet))
                return;
            end

            fns = [con.ImageSet.ID]';
            region_names = repmat("--", numel(fns), 1);

            for i = 1:numel(con.ImageSet)
                im = con.ImageSet(i);
                rns = arrayfun(@(r) r.Location.to_string(), im.Regions);
                if isempty(rns)
                    continue
                end
                region_names(i) = join(rns, ", ");
            end

            con.View.ImageTable.Data = [fns region_names];

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

                case (RegionsEvent.RegionChecked)
                    con.onRegionChecked()

                case (RegionsEvent.ButtonAddToSelected)
                    con.onAddToSelectedButtonPushed()

                case (RegionsEvent.ButtonDeselectAll)
                    con.onDeselectAllButtonPushed()

                case (RegionsEvent.ButtonEraseRegions)
                    con.onEraseRegionsButtonPushed()

                case (RegionsEvent.ButtonSelectAll)
                    con.onSelectAllButtonPushed()

                case (ModelEvents.WorkspaceUpdated)
                    con.onWorkspaceUpdated()
            end
        end
        
    end

    methods (Access=private)
        function locs = get_selected_locs(con)
            selected = con.View.RegionSelector.CheckedNodes;
            l_node = con.View.RegionSelector.Children(1);
            r_node = con.View.RegionSelector.Children(2);
            l_locs = RegionsController.extract_nodes(l_node, selected);
            r_locs = RegionsController.extract_nodes(r_node, selected);
            locs = cat(1, l_locs, r_locs);
        end
    end

    methods (Static)

        function locs = extract_nodes(node, selected_nodes)
            if ismember(node, selected_nodes)
                locs = [node.NodeData];
                return
            end

            locs = arrayfun(@(n) RegionsController.extract_nodes(n, selected_nodes), node.Children, UniformOutput=false);
            locs = Utility.cat_cells(locs);

            if isempty(locs)
                locs = Location.empty;
            end
        end

    end
    
end