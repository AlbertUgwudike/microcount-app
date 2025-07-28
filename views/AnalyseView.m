classdef AnalyseView < Component

    properties ( Access = public )
        MainGrid
            SettingGrid
                ApplySettingButton
                CellThresholdEditField
                CoMarkerThresholdEditField
                MaxSizeEditField
                SomaThresholdEditField
                SelectAllButton
            RegionTable matlab.ui.control.Table
            ButtonGrid
                SelectUnprocessedButton
                ProcessSelectedButton
                CancelButton
                ExportButton
            BottomGrid
                ThumbnailPanel 
                Thumbnail matlab.ui.control.UIAxes
                ProcessedImagePanel 
                ProcessedImage 
                ResultsPanel 
                ResultGrid
                    PercentageCellAreaLabel
                    CellCountLabel
                    PercentageCoMarkerAreaLabel
                    PercentageCoMarkerNumLabel
                    BranchCountLabel
                    ConvexityLabel
                    BranchLengthLabel
                    SchollLabel
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
            view.SettingGrid.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x'};
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
            view.CellThresholdEditField.HorizontalAlignment = 'center';
            view.CellThresholdEditField.Layout.Row = 1;
            view.CellThresholdEditField.Layout.Column = 2;

            % Create CD68EditField
            view.CoMarkerThresholdEditField = uieditfield(view.SettingGrid, 'numeric');
            view.CoMarkerThresholdEditField.HorizontalAlignment = 'center';
            view.CoMarkerThresholdEditField.Layout.Row = 1;
            view.CoMarkerThresholdEditField.Layout.Column = 3;

            % Create MaxEditField
            view.MaxSizeEditField = uieditfield(view.SettingGrid, 'numeric');
            view.MaxSizeEditField.HorizontalAlignment = 'center';
            view.MaxSizeEditField.Layout.Row = 1;
            view.MaxSizeEditField.Layout.Column = 4;

            % Create SomaThresholdEditField
            view.SomaThresholdEditField = uieditfield(view.SettingGrid, 'numeric');
            view.SomaThresholdEditField.HorizontalAlignment = 'center';
            view.SomaThresholdEditField.Layout.Row = 1;
            view.SomaThresholdEditField.Layout.Column = 5;

            % Create RegionTable
            view.RegionTable = uitable(view.MainGrid);
            view.RegionTable.ColumnName = {'RegionID'; 'Cell Threshold'; 'CoMarker Threshold'; 'Max CoMarker Size'; 'Soma Threshold'; 'Processed'};
            view.RegionTable.ColumnWidth = {'4x', '4x', '4x', '4x', '4x', '4x'};
            view.RegionTable.RowName = {};
            view.RegionTable.Layout.Row = 2;
            view.RegionTable.Layout.Column = 1;
            view.RegionTable.Multiselect = 'on';
            view.RegionTable.SelectionType = 'row';
            view.RegionTable.ColumnEditable = [false, true, true, true, true, false];
            view.RegionTable.CellSelectionCallback = @(~, ~) view.call_registrar(AnalyseEvent.SelectionRegionTable);
            view.RegionTable.CellEditCallback = @(~, e) view.call_registrar(AnalyseEvent.CellEdited, e);

            % Create ButtonGrid
            view.ButtonGrid = uigridlayout(view.MainGrid);
            view.ButtonGrid.ColumnWidth = {'2x', '2x', '2x', '2x', '2x'};
            view.ButtonGrid.RowHeight = {'1x'};
            view.ButtonGrid.ColumnSpacing = 5;
            view.ButtonGrid.Layout.Row = 3;
            view.ButtonGrid.Layout.Column = 1;

            % Create ProcessAllButton
            view.SelectAllButton = uibutton(view.ButtonGrid, 'push');
            view.SelectAllButton.ButtonPushedFcn = @(~, ~) view.call_registrar(AnalyseEvent.ButtonSelectAll);
            view.SelectAllButton.Layout.Row = 1;
            view.SelectAllButton.Layout.Column = 1;
            view.SelectAllButton.Text = 'Select All';

            % Create SelectUnprocessedButton
            view.SelectUnprocessedButton = uibutton(view.ButtonGrid, 'push');
            view.SelectUnprocessedButton.ButtonPushedFcn = @(~, ~) view.call_registrar(AnalyseEvent.ButtonSelectUnprocessed);
            view.SelectUnprocessedButton.Layout.Row = 1;
            view.SelectUnprocessedButton.Layout.Column = 2;
            view.SelectUnprocessedButton.Text = 'Select Unprocessed';

            % Create ProcessSelectedButton
            view.ProcessSelectedButton = uibutton(view.ButtonGrid, 'push');
            view.ProcessSelectedButton.ButtonPushedFcn = @(~, ~) view.call_registrar(AnalyseEvent.ButtonProcessSelected);
            view.ProcessSelectedButton.Layout.Row = 1;
            view.ProcessSelectedButton.Layout.Column = 3;
            view.ProcessSelectedButton.Text = 'Process Selected';

            % Create CancelButton
            view.CancelButton = uibutton(view.ButtonGrid, 'push');
            view.CancelButton.ButtonPushedFcn = @(~, ~) view.call_registrar(AnalyseEvent.ButtonCancel);
            view.CancelButton.Layout.Row = 1;
            view.CancelButton.Layout.Column = 4;
            view.CancelButton.Text = 'Cancel';

            % Create ExportButton
            view.ExportButton = uibutton(view.ButtonGrid, 'push');
            view.ExportButton.ButtonPushedFcn = @(~, ~) view.call_registrar(AnalyseEvent.ButtonExport);
            view.ExportButton.Layout.Row = 1;
            view.ExportButton.Layout.Column = 5;
            view.ExportButton.Text = 'Export Processed';

            % Create BottomGrid
            view.BottomGrid = uigridlayout(view.MainGrid);
            view.BottomGrid.ColumnWidth = {'0.37x', '0.47x', '0.15x'};
            view.BottomGrid.RowHeight = {'1x'};
            view.BottomGrid.Layout.Row = 4;
            view.BottomGrid.Layout.Column = 1;
            view.BottomGrid.Padding = 1;

            %Create ThumbnailPanel
            view.ThumbnailPanel = uigridlayout(view.BottomGrid);
            view.ThumbnailPanel.ColumnWidth = {'1x'};
            view.ThumbnailPanel.RowHeight = {'1x'};
            view.ThumbnailPanel.Layout.Row = 1;
            view.ThumbnailPanel.Layout.Column = 1;
            view.ThumbnailPanel.BackgroundColor = [0, 0, 0];
            view.ThumbnailPanel.Padding = 1;

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
            view.ProcessedImagePanel.Padding = 1;

            % Create ProcessedImage
            view.ProcessedImage = uiimage(view.ProcessedImagePanel);
            view.ProcessedImage.Layout.Row = 1;
            view.ProcessedImage.Layout.Column = 1;
            view.ProcessedImage.ImageSource = zeros(3, 3, 3);

            % Creat ResultsPanel
            view.ResultsPanel = uipanel(view.BottomGrid);
            view.ResultsPanel.Layout.Row = 1;
            view.ResultsPanel.Layout.Column = 3;

            % Create ResultGrid
            view.ResultGrid = uigridlayout(view.ResultsPanel);
            view.ResultGrid.RowHeight = repmat({'1x'}, 8, 1);
            view.ResultGrid.ColumnWidth = {'1x'};
            view.ResultGrid.Padding = 1;
            view.ResultGrid.Padding = 1;

            % Create PercentageCellAreaTextAreaLabel
            view.PercentageCellAreaLabel = view.create_result_label(Constants.LABEL_CELL_AREA, 1);

            % Create CellCountTextAreaLabel
            view.CellCountLabel = view.create_result_label(Constants.LABEL_CELL_DENSITY, 2);

            % Create PercentageCoMarkerAreaTextAreaLabel
            view.PercentageCoMarkerAreaLabel = view.create_result_label(Constants.LABEL_CO_AREA, 3);

            % Create PercentageCoMarkerNumTextAreaLabel
            view.PercentageCoMarkerNumLabel = view.create_result_label(Constants.LABEL_CO_NUM, 4);

            % Create BranchCountTextAreaLabel
            view.BranchCountLabel = view.create_result_label(Constants.LABEL_BRANCH, 5);

            % Create BranchLengthTextAreaLabel
            view.BranchLengthLabel = view.create_result_label(Constants.LABEL_LENGTH, 6);

            % Create ConvexityTextAreaLabel
            view.ConvexityLabel = view.create_result_label(Constants.LABEL_CONVEXITY, 7);

            % Create SchollTextAreaLabel
            view.SchollLabel = view.create_result_label(Constants.LABEL_SCHOLL, 8);

        end

        function l = create_result_label(parent, title, row)
            % Create TextAreaLabel
            l = uilabel(parent.ResultGrid);
            l.FontWeight = 'bold';
            l.HorizontalAlignment = 'center';
            l.FontSize = 10;
            l.Layout.Row = row;
            l.Layout.Column = 1;
            format_str = join(repmat("%s\n", 1, numel(title)), "") + "--";
            l.Text = sprintf(format_str, title);
        end

    end

end