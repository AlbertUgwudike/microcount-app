classdef RegionsView < Component

    properties ( Access = public )
        MainGrid
            TopGrid
                LeftGrid
                    ImageTableButtonGrid
                        SelectAllButton
                        EraseRegionsButton
                    ImageTable
                RightGrid
                    RegionSelectorButtonGrid
                        AddToSelectedLeftButton
                        AddToSelectedRightButton
                        RemoveFromSelectedLeftButton
                        RemoveFromSelectedRightButton
                    RegionSelector
            BottomGrid
                HistologyImage
    end

    methods

        function obj = RegionsView(parent)

            arguments
                parent
            end

            obj@Component(parent) 
        end 

    end 

    methods ( Access = protected ) 

        function setup(view) 

            % Create MainGrid
            view.MainGrid = uigridlayout(view);
            view.MainGrid.ColumnWidth = {'1x'};
            view.MainGrid.RowHeight = {'0.75x', '1.3x'};
            view.MainGrid.RowSpacing = 1;

            % Create TopGrid
            view.TopGrid = uigridlayout(view.MainGrid);
            view.TopGrid.RowHeight = {'1x'};
            view.TopGrid.ColumnSpacing = 1;
            view.TopGrid.RowSpacing = 1;
            view.TopGrid.Layout.Row = 1;
            view.TopGrid.Layout.Column = 1;

            % Create LeftGrid
            view.LeftGrid = uigridlayout(view.TopGrid);
            view.LeftGrid.ColumnWidth = {'1x'};
            view.LeftGrid.RowHeight = {'1x', '6x'};
            view.LeftGrid.RowSpacing = 1;
            view.LeftGrid.Layout.Row = 1;
            view.LeftGrid.Layout.Column = 1;

            % Create ImageTableButtonGrid
            view.ImageTableButtonGrid = uigridlayout(view.LeftGrid);
            view.ImageTableButtonGrid.ColumnWidth = {'1x', '1x', '1x'};
            view.ImageTableButtonGrid.RowHeight = {'1x'};
            view.ImageTableButtonGrid.ColumnSpacing = 1;
            view.ImageTableButtonGrid.RowSpacing = 1;
            view.ImageTableButtonGrid.Padding = [1 1 1 1];
            view.ImageTableButtonGrid.Layout.Row = 1;
            view.ImageTableButtonGrid.Layout.Column = 1;

            % Create SelectAllButton
            view.SelectAllButton = uibutton(view.ImageTableButtonGrid, 'push');
            view.SelectAllButton.Text = 'Select All';
            view.SelectAllButton.Layout.Row = 1;
            view.SelectAllButton.Layout.Column = 1;
            view.SelectAllButton.ButtonPushedFcn = @(~, ~) view.call_registrar(RegionsEvent.ButtonSelectAll);

            % Create EraseRegionsButton
            view.EraseRegionsButton = uibutton(view.ImageTableButtonGrid, 'push');
            view.EraseRegionsButton.Text = 'Erase Regions';
            view.EraseRegionsButton.Layout.Row = 1;
            view.EraseRegionsButton.Layout.Column = 2;
            view.EraseRegionsButton.ButtonPushedFcn = @(~, ~) view.call_registrar(RegionsEvent.ButtonEraseRegions);

            % Create ImageTable
            view.ImageTable = uitable(view.LeftGrid);
            view.ImageTable.ColumnName = {'Images'; 'Regions'};
            view.ImageTable.RowName = {};
            view.ImageTable.SelectionType = 'row';
            view.ImageTable.Multiselect = 'on';
            view.ImageTable.CellSelectionCallback = @(~, ~) view.call_registrar(RegionsEvent.SelectionImageTable);
            view.ImageTable.Layout.Row = 2;
            view.ImageTable.Layout.Column = 1;

            % Create RightGrid
            view.RightGrid = uigridlayout(view.TopGrid);
            view.RightGrid.ColumnWidth = {'1x'};
            view.RightGrid.RowHeight = {'1x', '6x'};
            view.RightGrid.RowSpacing = 1;
            view.RightGrid.Layout.Row = 1;
            view.RightGrid.Layout.Column = 2;

            % Create RegionSelectorButtonGrid
            view.RegionSelectorButtonGrid = uigridlayout(view.RightGrid);
            view.RegionSelectorButtonGrid.ColumnWidth = {'3x', '3x', '1x', '3x', '3x'};
            view.RegionSelectorButtonGrid.RowHeight = {'1x'};
            view.RegionSelectorButtonGrid.ColumnSpacing = 1;
            view.RegionSelectorButtonGrid.RowSpacing = 1;
            view.RegionSelectorButtonGrid.Padding = [1 1 1 1];
            view.RegionSelectorButtonGrid.Layout.Row = 1;
            view.RegionSelectorButtonGrid.Layout.Column = 1;

            % Create AddToSelectedLeftButton
            view.AddToSelectedLeftButton = uibutton(view.RegionSelectorButtonGrid, 'push');
            view.AddToSelectedLeftButton.Text = 'Add - L';
            view.AddToSelectedLeftButton.Layout.Row = 1;
            view.AddToSelectedLeftButton.Layout.Column = 1;
            view.AddToSelectedLeftButton.ButtonPushedFcn = @(~, ~) view.call_registrar(RegionsEvent.ButtonAddToSelected, Laterality.LEFT);


            % Create AddToSelectedRightButton
            view.AddToSelectedRightButton = uibutton(view.RegionSelectorButtonGrid, 'push');
            view.AddToSelectedRightButton.Text = 'Add - R';
            view.AddToSelectedRightButton.Layout.Row = 1;
            view.AddToSelectedRightButton.Layout.Column = 2;
            view.AddToSelectedRightButton.ButtonPushedFcn = @(~, ~) view.call_registrar(RegionsEvent.ButtonAddToSelected, Laterality.RIGHT);

            % Create RemoveFromSelectedLeftButton
            view.RemoveFromSelectedLeftButton = uibutton(view.RegionSelectorButtonGrid, 'push');
            view.RemoveFromSelectedLeftButton.Text = 'Del - L';
            view.RemoveFromSelectedLeftButton.Layout.Row = 1;
            view.RemoveFromSelectedLeftButton.Layout.Column = 4;
            view.RemoveFromSelectedLeftButton.ButtonPushedFcn = @(~, ~) view.call_registrar(RegionsEvent.ButtonRemoveFromSelected, Laterality.LEFT);

             % Create RemoveFromSelectedRightButton
            view.RemoveFromSelectedRightButton = uibutton(view.RegionSelectorButtonGrid, 'push');
            view.RemoveFromSelectedRightButton.Text = 'Del - R';
            view.RemoveFromSelectedRightButton.Layout.Row = 1;
            view.RemoveFromSelectedRightButton.Layout.Column = 5;
            view.RemoveFromSelectedRightButton.ButtonPushedFcn = @(~, ~) view.call_registrar(RegionsEvent.ButtonRemoveFromSelected, Laterality.RIGHT);

            % Create RegionSelector
            view.RegionSelector = uitree(view.RightGrid, 'checkbox');
            view.RegionSelector.Layout.Row = 2;
            view.RegionSelector.Layout.Column = 1;
            view.RegionSelector.CheckedNodesChangedFcn = @(~, e) view.call_registrar(RegionsEvent.RegionChecked);
            RegionsView.create_region_selector(view.RegionSelector, "Whole Brain");

            % Create BottomGrid
            view.BottomGrid = uigridlayout(view.MainGrid);
            view.BottomGrid.ColumnWidth = {'1x'};
            view.BottomGrid.RowHeight = {'1x'};
            view.BottomGrid.Layout.Row = 2;
            view.BottomGrid.Layout.Column = 1;
            view.BottomGrid.BackgroundColor = [0, 0, 0];

            % Create HistologyImage
            view.HistologyImage = uiimage(view.BottomGrid);
            view.HistologyImage.Layout.Row = 1;
            view.HistologyImage.Layout.Column = 1;

        end

    end

    methods (Static)

        function create_region_selector(ui_tree, name)
            this_fn = mfilename('fullpath');
            [curr_dir, ~, ~] = fileparts(this_fn);
            rt_fn = sprintf("%s/../assets/RegionTree.mat", curr_dir);
            region_tree = load(rt_fn).rt;
            Node = uitreenode(ui_tree);
            Node.Text = name;
            Node.NodeData = RegionKey.root;
            RegionsView.create_rs_tree(Node, region_tree.Descendants)
        end

        function create_rs_tree(parent_node, descendants)

            if isempty(descendants)
                return
            end

            select_all_desc = descendants(1);
            key = parent_node.NodeData;
            label = sprintf("Select All %s", select_all_desc.Name);
            uitreenode(parent_node, NodeData=key, Text=label);

            for i = 2:numel(descendants)
                descendant = descendants(i);
                child_key = descendant.Key;
                label = sprintf("%s (%s)", descendant.Name, descendant.Key.Name);
                child_node = uitreenode(parent_node, NodeData=child_key, Text=label);
                RegionsView.create_rs_tree(child_node, descendant.Descendants);
            end
        end

    end

end