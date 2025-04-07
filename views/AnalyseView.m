classdef AnalyseView < Component

    properties ( Access = public )
        MainGrid
        SettingGrid
        Iba1EditField
        CD68EditField
        MaxEditField
        RegionTable
        ButtonGrid
        ProcessSelectedButton
        ProcessAllButton
        ApplySettingButton
        CancelButton
        ExportButton
        BottomGrid
        Thumbnail matlab.ui.control.UIAxes
        ProcessedImage
        ResultGrid
        PercentageIba1AreaTextAreaLabel
        PercentageIba1AreaTextArea
        CellCountTextAreaLabel
        CellCountTextArea
        PercentageCD68AreaTextAreaLabel
        PercentageCD68AreaTextArea
        PercentageCD68NumTextAreaLabel
        PercentageCD68NumTextArea
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
            view.MainGrid.RowHeight = {'0.15x', '0.5x', '0.15x', '1.2x'};
            view.MainGrid.Padding = [5 5 5 5];

            % Create RegionTable
            view.RegionTable = uitable(view.MainGrid);
            view.RegionTable.ColumnName = {'RegionID'; 'Iba1 Threshold'; 'CD68 Threshold'; 'Max CD68 Size'; 'Processed'};
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

            % Create Thumbnail
            view.Thumbnail = uiaxes(view.BottomGrid);
            view.Thumbnail.Layout.Row = 1;
            view.Thumbnail.Layout.Column = 1;
            view.Thumbnail.InnerPosition = [0, 0, 1, 1];
            view.Thumbnail.XTick = [];
            view.Thumbnail.YTick = [];

            % Create ProcessedImage
            view.ProcessedImage = uiimage(view.BottomGrid);
            view.ProcessedImage.Layout.Row = 1;
            view.ProcessedImage.Layout.Column = 2;

            % Create ResultGrid
            view.ResultGrid = uigridlayout(view.BottomGrid);
            view.ResultGrid.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x'};
            view.ResultGrid.Layout.Row = 1;
            view.ResultGrid.Layout.Column = 3;

            % Create PercentageIba1AreaTextAreaLabel
            view.PercentageIba1AreaTextAreaLabel = uilabel(view.ResultGrid);
            view.PercentageIba1AreaTextAreaLabel.HorizontalAlignment = 'center';
            view.PercentageIba1AreaTextAreaLabel.FontWeight = 'bold';
            view.PercentageIba1AreaTextAreaLabel.Layout.Row = 1;
            view.PercentageIba1AreaTextAreaLabel.Layout.Column = 1;
            view.PercentageIba1AreaTextAreaLabel.Text = {'Percentage'; 'Iba1 Area'};

            % Create PercentageIba1AreaTextArea
            view.PercentageIba1AreaTextArea = uitextarea(view.ResultGrid);
            view.PercentageIba1AreaTextArea.FontWeight = 'bold';
            view.PercentageIba1AreaTextArea.Layout.Row = 1;
            view.PercentageIba1AreaTextArea.Layout.Column = 2;

            % Create CellCountTextAreaLabel
            view.CellCountTextAreaLabel = uilabel(view.ResultGrid);
            view.CellCountTextAreaLabel.HorizontalAlignment = 'center';
            view.CellCountTextAreaLabel.FontWeight = 'bold';
            view.CellCountTextAreaLabel.Layout.Row = 2;
            view.CellCountTextAreaLabel.Layout.Column = 1;
            view.CellCountTextAreaLabel.Text = {'Cell'; 'Count'};

            % Create CellCountTextArea
            view.CellCountTextArea = uitextarea(view.ResultGrid);
            view.CellCountTextArea.FontWeight = 'bold';
            view.CellCountTextArea.Layout.Row = 2;
            view.CellCountTextArea.Layout.Column = 2;

            % Create PercentageCD68AreaTextAreaLabel
            view.PercentageCD68AreaTextAreaLabel = uilabel(view.ResultGrid);
            view.PercentageCD68AreaTextAreaLabel.HorizontalAlignment = 'center';
            view.PercentageCD68AreaTextAreaLabel.FontWeight = 'bold';
            view.PercentageCD68AreaTextAreaLabel.Layout.Row = 3;
            view.PercentageCD68AreaTextAreaLabel.Layout.Column = 1;
            view.PercentageCD68AreaTextAreaLabel.Text = {'Percentage'; 'CD68 Area'};

            % Create PercentageCD68AreaTextArea
            view.PercentageCD68AreaTextArea = uitextarea(view.ResultGrid);
            view.PercentageCD68AreaTextArea.FontWeight = 'bold';
            view.PercentageCD68AreaTextArea.Layout.Row = 3;
            view.PercentageCD68AreaTextArea.Layout.Column = 2;

            % Create PercentageCD68NumTextAreaLabel
            view.PercentageCD68NumTextAreaLabel = uilabel(view.ResultGrid);
            view.PercentageCD68NumTextAreaLabel.HorizontalAlignment = 'center';
            view.PercentageCD68NumTextAreaLabel.FontWeight = 'bold';
            view.PercentageCD68NumTextAreaLabel.Layout.Row = 4;
            view.PercentageCD68NumTextAreaLabel.Layout.Column = 1;
            view.PercentageCD68NumTextAreaLabel.Text = {'Percentage'; 'CD68 Num'};

            % Create PercentageCD68NumTextArea
            view.PercentageCD68NumTextArea = uitextarea(view.ResultGrid);
            view.PercentageCD68NumTextArea.FontWeight = 'bold';
            view.PercentageCD68NumTextArea.Layout.Row = 4;
            view.PercentageCD68NumTextArea.Layout.Column = 2;

            % Create BranchCountTextAreaLabel
            view.BranchCountTextAreaLabel = uilabel(view.ResultGrid);
            view.BranchCountTextAreaLabel.HorizontalAlignment = 'center';
            view.BranchCountTextAreaLabel.FontWeight = 'bold';
            view.BranchCountTextAreaLabel.Layout.Row = 5;
            view.BranchCountTextAreaLabel.Layout.Column = 1;
            view.BranchCountTextAreaLabel.Text = {'Branch'; 'Count'};

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
            view.Iba1EditField = uieditfield(view.SettingGrid, 'numeric');
            view.Iba1EditField.Layout.Row = 1;
            view.Iba1EditField.Layout.Column = 2;

            % Create CD68EditField
            view.CD68EditField = uieditfield(view.SettingGrid, 'numeric');
            view.CD68EditField.Layout.Row = 1;
            view.CD68EditField.Layout.Column = 3;

            % Create MaxEditField
            view.MaxEditField = uieditfield(view.SettingGrid, 'numeric');
            view.MaxEditField.Layout.Row = 1;
            view.MaxEditField.Layout.Column = 4;

            % Create ProcessAllButton
            view.ProcessAllButton = uibutton(view.SettingGrid, 'push');
            view.ProcessAllButton.ButtonPushedFcn = @(~, ~) view.call_registrar(AnalyseEvent.ButtonSelectAll);
            view.ProcessAllButton.Layout.Row = 1;
            view.ProcessAllButton.Layout.Column = 5;
            view.ProcessAllButton.Text = 'Select All';

        end

    end

end