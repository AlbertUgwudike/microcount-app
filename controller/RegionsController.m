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
            img = imadjust(p_img) + con.Model.Atlas.calc_borders(tform_d, locs);
            con.View.HistologyImage.ImageSource = cat(3, img, img, img);
        end

        function onRegionChecked(con)
            disp("RegionsController::onRegionChecked")
            keys = con.get_selected_keys();
            disp(keys)
        end

        function onAddToSelectedButtonPushed(con, laterality)
            disp("RegionsController::onAddToSelectedButtonPushed")
            if (isempty(con.View.ImageTable.Selection))
                return
            end
            idx = con.View.ImageTable.Selection;
            keys = con.get_selected_keys();
            for i = 1:numel(idx)
                img_md = con.ImageSet(idx(i));
                con.Model.io_update_regions(img_md, keys, laterality);
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
                con.Model.io_remove_regions(img_md);
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
        
        function handle_event(con, event, data)
            switch event

                case (RegionsEvent.SelectionImageTable)
                    con.onImageSelected()

                case (RegionsEvent.RegionChecked)
                    con.onRegionChecked()

                case (RegionsEvent.ButtonAddToSelected)
                    con.onAddToSelectedButtonPushed(data)

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
        function keys = get_selected_keys(con)
            selected = con.View.RegionSelector.CheckedNodes;
            node = con.View.RegionSelector.Children(1);
            keys = RegionsController.extract_keys(node, selected);
        end
    end

    methods (Static)

        function keys = extract_keys(node, selected_nodes)
            if ismember(node, selected_nodes)
                keys = [node.NodeData];
                return
            end

            keys = arrayfun(@(n) RegionsController.extract_keys(n, selected_nodes), node.Children, UniformOutput=false);
            keys = Utility.cat_cells(keys);

            if isempty(keys)
                keys = RegionKey.empty;
            end
        end

    end
    
end