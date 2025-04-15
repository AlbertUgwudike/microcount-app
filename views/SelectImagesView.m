classdef SelectImagesView < Component

    properties ( Access = public )
        MainGrid
            ButtonGrid
                AddImagesButton
                SelectAllButton
                RemoveSelectedButton
                ConvertSelectedButton
            ImageTable
            ChannelOrderGrid
                ApplyChannelOrderButton
                ChannelOrderField
                ApplyChannelNamesButton
                ChannelNamesField
    end

    methods

        function obj = SelectImagesView(parent)

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
            view.MainGrid.RowHeight = {'0.1x', '1x', '0.1x', '0.8x'};

            % Create ButtonGrid
            view.ButtonGrid = uigridlayout(view.MainGrid);
            view.ButtonGrid.ColumnWidth = {'1x', '1x', '1x', '1x'};
            view.ButtonGrid.RowHeight = {'1x'};
            view.ButtonGrid.Padding = [1 1 1 1];
            view.ButtonGrid.Layout.Row = 1;
            view.ButtonGrid.Layout.Column = 1;

            % Create AddImagesButton
            view.AddImagesButton = uibutton(view.ButtonGrid, 'push');
            view.AddImagesButton.Layout.Row = 1;
            view.AddImagesButton.Layout.Column = 1;
            view.AddImagesButton.Text = 'Add Images';
            view.AddImagesButton.ButtonPushedFcn = @(~, ~) view.call_registrar(SelectImagesEvent.ButtonAddImages);

            % Create SelectAllButton
            view.SelectAllButton = uibutton(view.ButtonGrid, 'push');
            view.SelectAllButton.Layout.Row = 1;
            view.SelectAllButton.Layout.Column = 2;
            view.SelectAllButton.Text = 'Select All';
            view.SelectAllButton.ButtonPushedFcn = @(~, ~) view.call_registrar(SelectImagesEvent.ButtonSelectAll);

            % Create RemoveSelectedButton
            view.RemoveSelectedButton = uibutton(view.ButtonGrid, 'push');
            view.RemoveSelectedButton.Layout.Row = 1;
            view.RemoveSelectedButton.Layout.Column = 3;
            view.RemoveSelectedButton.Text = 'Remove Selected';
            view.RemoveSelectedButton.ButtonPushedFcn = @(~, ~) view.call_registrar(SelectImagesEvent.ButtonRemoveSelected);

            % Create ConvertSelectedButton
            view.ConvertSelectedButton = uibutton(view.ButtonGrid, 'push');
            view.ConvertSelectedButton.Layout.Row = 1;
            view.ConvertSelectedButton.Layout.Column = 4;
            view.ConvertSelectedButton.Text = 'Convert Selected';
            view.ConvertSelectedButton.ButtonPushedFcn = @(~, ~) view.call_registrar(SelectImagesEvent.ButtonConvert);

            % Create ImageTable
            view.ImageTable = uitable(view.MainGrid);
            view.ImageTable.ColumnName = {'Image'; 'Channel Count'; 'Channel Order'; 'Channel Names'; 'Converted'; 'Progress'};
            view.ImageTable.RowName = {};
            view.ImageTable.ColumnEditable = [false false true false, false];
            view.ImageTable.Layout.Row = 2;
            view.ImageTable.Layout.Column = 1;
            view.ImageTable.Multiselect = 'on';
            view.ImageTable.SelectionType = 'row';
            view.ImageTable.CellEditCallback = @(~, e) view.call_registrar(SelectImagesEvent.ChannelOrderEdited, e);

            % Create ChannelOrderGrid
            view.ChannelOrderGrid = uigridlayout(view.MainGrid);
            view.ChannelOrderGrid.ColumnWidth = {'1x', '1x', '0.5x', '1x', '1x'};
            view.ChannelOrderGrid.RowHeight = {'1x'};
            view.ChannelOrderGrid.Padding = [1 1 1 1];
            view.ChannelOrderGrid.Layout.Row = 3;
            view.ChannelOrderGrid.Layout.Column = 1;

            % Create ApplyChannelOrderButton
            view.ApplyChannelOrderButton = uibutton(view.ChannelOrderGrid, 'push');
            view.ApplyChannelOrderButton.Layout.Row = 1;
            view.ApplyChannelOrderButton.Layout.Column = 1;
            view.ApplyChannelOrderButton.Text = 'Apply Channel Order';
            view.ApplyChannelOrderButton.ButtonPushedFcn = @(~, ~) view.call_registrar(SelectImagesEvent.ButtonApplyChannelOrder);

            % Create ChannelOrderField
            view.ChannelOrderField = uieditfield(view.ChannelOrderGrid, 'text');
            view.ChannelOrderField.Layout.Row = 1;
            view.ChannelOrderField.Layout.Column = 2;

            % Create ApplyChannelNamesButton
            view.ApplyChannelNamesButton = uibutton(view.ChannelOrderGrid, 'push');
            view.ApplyChannelNamesButton.Layout.Row = 1;
            view.ApplyChannelNamesButton.Layout.Column = 4;
            view.ApplyChannelNamesButton.Text = 'Apply Channel Names';
            view.ApplyChannelNamesButton.ButtonPushedFcn = @(~, ~) view.call_registrar(SelectImagesEvent.ButtonApplyChannelNames);

            % Create ChannelNamesField
            view.ChannelNamesField = uieditfield(view.ChannelOrderGrid, 'text');
            view.ChannelNamesField.Layout.Row = 1;
            view.ChannelNamesField.Layout.Column = 5;

        end

    end

end