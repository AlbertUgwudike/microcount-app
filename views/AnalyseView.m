classdef AnalyseView < Component

    properties ( Access = public )
        MainGrid
            SettingGrid
                ApplySettingButton
                CellThresholdEditField
                CoMarkerThresholdEditField
                MaxSizeEditField
                SelectAllButton
            RegionTable
            ButtonGrid
                ProcessSelectedButton
                CancelButton
                ExportButton
            BottomGrid
                ThumbnailPanel 
                Thumbnail matlab.ui.control.UIAxes
                ProcessedImagePanel 
                ProcessedImage 
                ResultsPanel matlab.ui.container.Panel
                ResultGrid
                    PercentageCellAreaTextAreaLabel
                    PercentageCellAreaTextArea
                    CellCountTextAreaLabel
                    CellCountTextArea
                    PercentageCoMarkerAreaTextAreaLabel
                    PercentageCoMarkerAreaTextArea
                    PercentageCoMarkerNumTextAreaLabel
                    PercentageCoMarkerNumTextArea
                    BranchCountTextAreaLabel
                    BranchCountTextArea
                    ConvexityTextAreaLabel
                    ConvexityTextArea
    end

    methods

        function obj = AnalyseView(parent)

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

            % Create SettingGrid
            view.SettingGrid = uigridlayout(view.MainGrid);
            view.SettingGrid.ColumnWidth = {'1x', '1x', '1x', '1x', '1x'};
            view.SettingGrid.RowHeight = {'1x'};
            view.SettingGrid.Layout.Row = 1;
            view.SettingGrid.Layout.Column = 1;

            % Create ApplySettingButton
            view.ApplySettingButton = uibutton(view.SettingGrid, 'push');
            view.ApplySettingButton.ButtonPushedFcn = @(~, ~) view.call_registrar(AnalyseEvent.ButtonApplySetting);
            view.ApplySettingButton.Layout.Row = 1;
            view.ApplySettingButton.Layout.Column = 1;
            view.ApplySettingButton.Text = 'Apply Setting';

            % Create Iba1EditField
            view.CellThresholdEditField = uieditfield(view.SettingGrid, 'numeric');
            view.CellThresholdEditField.Layout.Row = 1;
            view.CellThresholdEditField.Layout.Column = 2;

            % Create CD68EditField
            view.CoMarkerThresholdEditField = uieditfield(view.SettingGrid, 'numeric');
            view.CoMarkerThresholdEditField.Layout.Row = 1;
            view.CoMarkerThresholdEditField.Layout.Column = 3;

            % Create MaxEditField
            view.MaxSizeEditField = uieditfield(view.SettingGrid, 'numeric');
            view.MaxSizeEditField.Layout.Row = 1;
            view.MaxSizeEditField.Layout.Column = 4;

            % Create ProcessAllButton
            view.SelectAllButton = uibutton(view.SettingGrid, 'push');
            view.SelectAllButton.ButtonPushedFcn = @(~, ~) view.call_registrar(AnalyseEvent.ButtonSelectAll);
            view.SelectAllButton.Layout.Row = 1;
            view.SelectAllButton.Layout.Column = 5;
            view.SelectAllButton.Text = 'Select All';

            % Create RegionTable
            view.RegionTable = uitable(view.MainGrid);
            view.RegionTable.ColumnName = {'RegionID'; 'Cell Threshold'; 'CoMarker Threshold'; 'Max CoMarker Size'; 'Processed'};
            view.RegionTable.ColumnWidth = {'4x', '4x', '4x', '4x', '4x'};
            view.RegionTable.RowName = {};
            view.RegionTable.Layout.Row = 2;
            view.RegionTable.Layout.Column = 1;
            view.RegionTable.Multiselect = 'on';
            view.RegionTable.SelectionType = 'row';
            view.RegionTable.ColumnEditable = [false, true, true, true, false];
            view.RegionTable.CellSelectionCallback = @(~, ~) view.call_registrar(AnalyseEvent.SelectionRegionTable);
            view.RegionTable.CellEditCallback = @(~, e) view.call_registrar(AnalyseEvent.CellEdited, e);

            % Create ButtonGrid
            view.ButtonGrid = uigridlayout(view.MainGrid);
            view.ButtonGrid.ColumnWidth = {'1x', '1x', '1x', '1x', '1x'};
            view.ButtonGrid.RowHeight = {'1x'};
            view.ButtonGrid.ColumnSpacing = 5;
            view.ButtonGrid.Layout.Row = 3;
            view.ButtonGrid.Layout.Column = 1;

            % Create ProcessSelectedButton
            view.ProcessSelectedButton = uibutton(view.ButtonGrid, 'push');
            view.ProcessSelectedButton.ButtonPushedFcn = @(~, ~) view.call_registrar(AnalyseEvent.ButtonProcessSelected);
            view.ProcessSelectedButton.Layout.Row = 1;
            view.ProcessSelectedButton.Layout.Column = 2;
            view.ProcessSelectedButton.Text = 'Process Selected';

            % Create CancelButton
            view.CancelButton = uibutton(view.ButtonGrid, 'push');
            view.CancelButton.ButtonPushedFcn = @(~, ~) view.call_registrar(AnalyseEvent.ButtonCancel);
            view.CancelButton.Layout.Row = 1;
            view.CancelButton.Layout.Column = 3;
            view.CancelButton.Text = 'Cancel';

            % Create ExportButton
            view.ExportButton = uibutton(view.ButtonGrid, 'push');
            view.ExportButton.ButtonPushedFcn = @(~, ~) view.call_registrar(AnalyseEvent.ButtonExport);
            view.ExportButton.Layout.Row = 1;
            view.ExportButton.Layout.Column = 4;
            view.ExportButton.Text = 'Export Processed';

            % Create BottomGrid
            view.BottomGrid = uigridlayout(view.MainGrid);
            view.BottomGrid.ColumnWidth = {'0.3x', '0.4x', '0.3x'};
            view.BottomGrid.RowHeight = {'1x'};
            view.BottomGrid.Layout.Row = 4;
            view.BottomGrid.Layout.Column = 1;

            %Create ThumbnailPanel
            view.ThumbnailPanel = uigridlayout(view.BottomGrid);
            view.ThumbnailPanel.ColumnWidth = {'1x'};
            view.ThumbnailPanel.RowHeight = {'1x'};
            view.ThumbnailPanel.Layout.Row = 1;
            view.ThumbnailPanel.Layout.Column = 1;
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
            

            %Create ProcessedImagePanel
            view.ProcessedImagePanel = uigridlayout(view.BottomGrid);
            view.ProcessedImagePanel.ColumnWidth = {'1x'};
            view.ProcessedImagePanel.RowHeight = {'1x'};
            view.ProcessedImagePanel.Layout.Row = 1;
            view.ProcessedImagePanel.Layout.Column = 2;
            view.ProcessedImagePanel.BackgroundColor = [0, 0, 0];

            % Create ProcessedImage
            view.ProcessedImage = uiimage(view.ProcessedImagePanel);
            view.ProcessedImage.Layout.Row = 1;
            view.ProcessedImage.Layout.Column = 1;

            % Creat ResultsPanel
            view.ResultsPanel = uipanel(view.BottomGrid);
            view.ResultsPanel.Layout.Row = 1;
            view.ResultsPanel.Layout.Column = 3;

            % Create ResultGrid
            view.ResultGrid = uigridlayout(view.ResultsPanel);
            view.ResultGrid.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x'};

            % Create PercentageIba1AreaTextAreaLabel
            view.PercentageCellAreaTextAreaLabel = uilabel(view.ResultGrid);
            view.PercentageCellAreaTextAreaLabel.HorizontalAlignment = 'center';
            view.PercentageCellAreaTextAreaLabel.FontWeight = 'bold';
            view.PercentageCellAreaTextAreaLabel.Layout.Row = 1;
            view.PercentageCellAreaTextAreaLabel.Layout.Column = 1;
            view.PercentageCellAreaTextAreaLabel.Text = {'Cell Area (%)'};

            % Create PercentageIba1AreaTextArea
            view.PercentageCellAreaTextArea = uitextarea(view.ResultGrid);
            view.PercentageCellAreaTextArea.FontWeight = 'bold';
            view.PercentageCellAreaTextArea.Layout.Row = 1;
            view.PercentageCellAreaTextArea.Layout.Column = 2;

            % Create CellCountTextAreaLabel
            view.CellCountTextAreaLabel = uilabel(view.ResultGrid);
            view.CellCountTextAreaLabel.HorizontalAlignment = 'center';
            view.CellCountTextAreaLabel.FontWeight = 'bold';
            view.CellCountTextAreaLabel.Layout.Row = 2;
            view.CellCountTextAreaLabel.Layout.Column = 1;
            view.CellCountTextAreaLabel.Text = {'Cell Density'};

            % Create CellCountTextArea
            view.CellCountTextArea = uitextarea(view.ResultGrid);
            view.CellCountTextArea.FontWeight = 'bold';
            view.CellCountTextArea.Layout.Row = 2;
            view.CellCountTextArea.Layout.Column = 2;

            % Create PercentageCD68AreaTextAreaLabel
            view.PercentageCoMarkerAreaTextAreaLabel = uilabel(view.ResultGrid);
            view.PercentageCoMarkerAreaTextAreaLabel.HorizontalAlignment = 'center';
            view.PercentageCoMarkerAreaTextAreaLabel.FontWeight = 'bold';
            view.PercentageCoMarkerAreaTextAreaLabel.Layout.Row = 3;
            view.PercentageCoMarkerAreaTextAreaLabel.Layout.Column = 1;
            view.PercentageCoMarkerAreaTextAreaLabel.Text = {'CoMarker'; '(% Area)'};

            % Create PercentageCD68AreaTextArea
            view.PercentageCoMarkerAreaTextArea = uitextarea(view.ResultGrid);
            view.PercentageCoMarkerAreaTextArea.FontWeight = 'bold';
            view.PercentageCoMarkerAreaTextArea.Layout.Row = 3;
            view.PercentageCoMarkerAreaTextArea.Layout.Column = 2;

            % Create PercentageCD68NumTextAreaLabel
            view.PercentageCoMarkerNumTextAreaLabel = uilabel(view.ResultGrid);
            view.PercentageCoMarkerNumTextAreaLabel.HorizontalAlignment = 'center';
            view.PercentageCoMarkerNumTextAreaLabel.FontWeight = 'bold';
            view.PercentageCoMarkerNumTextAreaLabel.Layout.Row = 4;
            view.PercentageCoMarkerNumTextAreaLabel.Layout.Column = 1;
            view.PercentageCoMarkerNumTextAreaLabel.Text = {'CoMarker'; '(% Number)'};

            % Create PercentageCD68NumTextArea
            view.PercentageCoMarkerNumTextArea = uitextarea(view.ResultGrid);
            view.PercentageCoMarkerNumTextArea.FontWeight = 'bold';
            view.PercentageCoMarkerNumTextArea.Layout.Row = 4;
            view.PercentageCoMarkerNumTextArea.Layout.Column = 2;

            % Create BranchCountTextAreaLabel
            view.BranchCountTextAreaLabel = uilabel(view.ResultGrid);
            view.BranchCountTextAreaLabel.HorizontalAlignment = 'center';
            view.BranchCountTextAreaLabel.FontWeight = 'bold';
            view.BranchCountTextAreaLabel.Layout.Row = 5;
            view.BranchCountTextAreaLabel.Layout.Column = 1;
            view.BranchCountTextAreaLabel.Text = {'Branch Points'};

            % Create BranchCountTextArea
            view.BranchCountTextArea = uitextarea(view.ResultGrid);
            view.BranchCountTextArea.FontWeight = 'bold';
            view.BranchCountTextArea.Layout.Row = 5;
            view.BranchCountTextArea.Layout.Column = 2;

            % Create ConvexityTextAreaLabel
            view.ConvexityTextAreaLabel = uilabel(view.ResultGrid);
            view.ConvexityTextAreaLabel.HorizontalAlignment = 'center';
            view.ConvexityTextAreaLabel.FontWeight = 'bold';
            view.ConvexityTextAreaLabel.Layout.Row = 6;
            view.ConvexityTextAreaLabel.Layout.Column = 1;
            view.ConvexityTextAreaLabel.Text = 'Convexity';

            % Create ConvexityTextArea
            view.ConvexityTextArea = uitextarea(view.ResultGrid);
            view.ConvexityTextArea.FontWeight = 'bold';
            view.ConvexityTextArea.Layout.Row = 6;
            view.ConvexityTextArea.Layout.Column = 2;

            

        end

    end

end