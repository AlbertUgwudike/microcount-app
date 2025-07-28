classdef SelectImagesView < Component

    properties ( Access = public )

        MainGrid
            ChannelOrderGrid
                ApplyChannelIndexButton
                RegistrationChannelField
                CellMarkerChannelField
                CoMarkerChannelField
            ImageTable
            ButtonGrid
                AddImagesButton
                SelectAllButton
                RemoveSelectedButton
                ConvertSelectedButton
                CancelButton
            BottomGrid
                ThumbnailPanel 
                Thumbnail matlab.ui.control.UIAxes
                ProcessedImagePanel 
                ProcessedImage 
            ChannelButtonGrid
                ChannelButton
           
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
            view.MainGrid.RowSpacing = 1;
            view.MainGrid.RowHeight = {'0.15x', '0.5x', '0.15x', '1.2x'};
            view.MainGrid.Padding = [5 5 5 5];

            % Create ChannelOrderGrid
            view.ChannelOrderGrid = uigridlayout(view.MainGrid);
            view.ChannelOrderGrid.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x'};
            view.ChannelOrderGrid.RowHeight = {'1x'};
            view.ChannelOrderGrid.Layout.Row = 1;
            view.ChannelOrderGrid.Layout.Column = 1;

            % Create ApplyChannelIndexButton
            view.ApplyChannelIndexButton = uibutton(view.ChannelOrderGrid, 'push');
            view.ApplyChannelIndexButton.Layout.Row = 1;
            view.ApplyChannelIndexButton.Layout.Column = 1;
            view.ApplyChannelIndexButton.Text = 'Apply Channels';
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

            % Create ImageTable
            view.ImageTable = uitable(view.MainGrid);
            view.ImageTable.ColumnName = {'Image'; 'Registration'; 'Cell Marker'; 'Co-Marker'; 'Converted'; 'Progress'};
            view.ImageTable.ColumnWidth = {'4x', '4x', '4x', '4x', '4x', '4x'};
            view.ImageTable.RowName = {};
            view.ImageTable.ColumnEditable = [false true true true false, false];
            view.ImageTable.Layout.Row = 2;
            view.ImageTable.Layout.Column = 1;
            view.ImageTable.Multiselect = 'on';
            view.ImageTable.SelectionType = 'row';
            view.ImageTable.CellSelectionCallback = @(~, ~) view.call_registrar(SelectImagesEvent.SelectionImageTable);
            view.ImageTable.CellEditCallback = @(~, e) view.call_registrar(SelectImagesEvent.ChannelOrderEdited, e);

            % Create ButtonGrid
            view.ButtonGrid = uigridlayout(view.MainGrid);
            view.ButtonGrid.ColumnWidth = {'1x', '1x', '1x', '1x', '1x'};
            view.ButtonGrid.RowHeight = {'1x'};
            view.ButtonGrid.ColumnSpacing = 5;
            view.ButtonGrid.Layout.Row = 3;
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

            % Create CancelButton
            view.CancelButton = uibutton(view.ButtonGrid, 'push');
            view.CancelButton.Layout.Row = 1;
            view.CancelButton.Layout.Column = 5;
            view.CancelButton.Text = 'Cancel All';
            view.CancelButton.ButtonPushedFcn = @(~, ~) view.call_registrar(SelectImagesEvent.ButtonCancel);

            % Create BottomGrid
            view.BottomGrid = uigridlayout(view.MainGrid);
            view.BottomGrid.ColumnWidth = {'0.5x', '0.5x'};
            view.BottomGrid.RowHeight = {'1x'};
            view.BottomGrid.Padding = 1;
            view.BottomGrid.Layout.Row = 4;
            view.BottomGrid.Layout.Column = 1;

            %Create ThumbnailPanel
            view.ThumbnailPanel = uigridlayout(view.BottomGrid);
            view.ThumbnailPanel.ColumnWidth = {'1x'};
            view.ThumbnailPanel.RowHeight = {'1x', '0.1x'};
            view.ThumbnailPanel.Layout.Row = 1;
            view.ThumbnailPanel.Layout.Column = 1;
            view.ThumbnailPanel.Padding = 1;
            view.ThumbnailPanel.BackgroundColor = [0, 0, 0];

            % Create Thumbnail
            view.Thumbnail = uiaxes(view.ThumbnailPanel);
            view.Thumbnail.Units = 'normalized';
            view.Thumbnail.InnerPosition = [0, 0, 1, 1];
            view.Thumbnail.Layout.Row = 1;
            view.Thumbnail.Layout.Column = 1;
            view.Thumbnail.XTick = [];
            view.Thumbnail.YTick = [];
            view.Thumbnail.Color = [0,0,0];

            %Create ChannelButtonGrid
            view.ChannelButtonGrid = uigridlayout(view.ThumbnailPanel);
            view.ChannelButtonGrid.ColumnWidth = {'1x', '1x', '1x'};
            view.ChannelButtonGrid.RowHeight = {'1x'};
            view.ChannelButtonGrid.Layout.Row = 2;
            view.ChannelButtonGrid.Layout.Column = 1;
            view.ChannelButtonGrid.Padding = 5;
            view.ChannelButtonGrid.BackgroundColor = [0, 0, 0];

            % Create ChannelButton
            view.ChannelButton = uibutton(view.ChannelButtonGrid, 'push');
            view.ChannelButton.Layout.Row = 1;
            view.ChannelButton.Layout.Column = 1;
            view.ChannelButton.Text = 'Channel -/-';
            view.ChannelButton.ButtonPushedFcn = @(~, ~) view.call_registrar(SelectImagesEvent.ButtonCycleChannel);

            %Create ProcessedImagePanel
            view.ProcessedImagePanel = uigridlayout(view.BottomGrid);
            view.ProcessedImagePanel.ColumnWidth = {'1x'};
            view.ProcessedImagePanel.RowHeight = {'1x'};
            view.ProcessedImagePanel.Layout.Row = 1;
            view.ProcessedImagePanel.Layout.Column = 2;
            view.ProcessedImagePanel.Padding = 1;
            view.ProcessedImagePanel.BackgroundColor = [0, 0, 0];

            % Create ProcessedImage
            view.ProcessedImage = uiimage(view.ProcessedImagePanel);
            view.ProcessedImage.Layout.Row = 1;
            view.ProcessedImage.Layout.Column = 1;
            view.ProcessedImage.ImageSource = zeros(3, 3, 3);
        end

    end

end