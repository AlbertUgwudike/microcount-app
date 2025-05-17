classdef SelectImagesView < Component

    properties ( Access = public )
        MainGrid
            ButtonGrid
                AddImagesButton
                SelectAllButton
                RemoveSelectedButton
                ConvertSelectedButton
                CancelButton
            ImageTable
            ChannelOrderGrid
                ApplyChannelIndexButton
                RegistrationChannelField
                CellMarkerChannelField
                CoMarkerChannelField
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
            view.ButtonGrid.ColumnWidth = {'1x', '1x', '1x', '1x', '1x'};
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

            % Create ConvertSelectedButton
            view.CancelButton = uibutton(view.ButtonGrid, 'push');
            view.CancelButton.Layout.Row = 1;
            view.CancelButton.Layout.Column = 5;
            view.CancelButton.Text = 'Cancel All';
            view.CancelButton.ButtonPushedFcn = @(~, ~) view.call_registrar(SelectImagesEvent.ButtonCancel);

            % Create ImageTable
            view.ImageTable = uitable(view.MainGrid);
            view.ImageTable.ColumnName = {'Image'; 'Channel Count'; 'Ch. Align'; 'Ch. Cell'; 'Ch. CoMarker'; 'Converted'; 'Progress'};
            view.ImageTable.RowName = {};
            view.ImageTable.ColumnEditable = [false false true true true false, false];
            view.ImageTable.Layout.Row = 2;
            view.ImageTable.Layout.Column = 1;
            view.ImageTable.Multiselect = 'on';
            view.ImageTable.SelectionType = 'row';
            view.ImageTable.CellEditCallback = @(~, e) view.call_registrar(SelectImagesEvent.ChannelOrderEdited, e);

            % Create ChannelOrderGrid
            view.ChannelOrderGrid = uigridlayout(view.MainGrid);
            view.ChannelOrderGrid.ColumnWidth = {'2x', '1x', '1x', '1x', '1x', '1x'};
            view.ChannelOrderGrid.RowHeight = {'1x'};
            view.ChannelOrderGrid.Padding = [1 1 1 1];
            view.ChannelOrderGrid.Layout.Row = 3;
            view.ChannelOrderGrid.Layout.Column = 1;

            % Create ApplyChannelIndexButton
            view.ApplyChannelIndexButton = uibutton(view.ChannelOrderGrid, 'push');
            view.ApplyChannelIndexButton.Layout.Row = 1;
            view.ApplyChannelIndexButton.Layout.Column = 1;
            view.ApplyChannelIndexButton.Text = 'Apply Channel Order';
            view.ApplyChannelIndexButton.ButtonPushedFcn = @(~, ~) view.call_registrar(SelectImagesEvent.ButtonApplyChannelIndex);

            % Create RegistrationChannelField
            view.RegistrationChannelField = uieditfield(view.ChannelOrderGrid, 'numeric', 'RoundFractionalValues', 'on');
            view.RegistrationChannelField.Layout.Row = 1;
            view.RegistrationChannelField.Layout.Column = 2;

            % Create CellMarkerChannelField
            view.CellMarkerChannelField = uieditfield(view.ChannelOrderGrid, 'numeric', 'RoundFractionalValues', 'on');
            view.CellMarkerChannelField.Layout.Row = 1;
            view.CellMarkerChannelField.Layout.Column = 3;

            % Create CoMarkerChannelField
            view.CoMarkerChannelField = uieditfield(view.ChannelOrderGrid, 'numeric', 'RoundFractionalValues', 'on');
            view.CoMarkerChannelField.Layout.Row = 1;
            view.CoMarkerChannelField.Layout.Column = 4;

        end

    end

end