classdef RegisterView < Component

    properties ( Access = public )
        MainGrid
            TopGrid
                AlignmentTable
            BottomGrid
                AtlasPanel
                AtlasGrid
                    AtlasButtonGrid
                        CycleOrientationButton
                    AtlasSliceAxes
                    AtlasSliceSlider
                HistologyPanel
                HistologyGrid
                    HistologyButtonGrid
                        AlignColorButton
                        AlignControlButton
                    HistSliceAxes
                    HistologyButtonGrid2
                        ToggleOverlayButton
                        RotateButton

        Atlas Atlas = Atlas()
        AtlasHex
        HistHex

        CurrentAtlasSliceIdx = 150
    end

    methods

        function obj = RegisterView(parent)

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
            view.MainGrid.RowHeight = {'0.5x' '1.2x'};
            view.MainGrid.RowSpacing = 1;
            
            % Create TopGrid
            view.TopGrid = uigridlayout(view.MainGrid);
            view.TopGrid.ColumnWidth = {'1x'};
            view.TopGrid.RowHeight = {'1x'};
            view.TopGrid.Layout.Row = 1;
            view.TopGrid.Layout.Column = 1;

            % Create AlignmentTable
            view.AlignmentTable = uitable(view.TopGrid);
            view.AlignmentTable.ColumnName = {'Image'; 'Aligned'};
            view.AlignmentTable.ColumnWidth = {'4x', '1x'};
            view.AlignmentTable.RowName = {};
            view.AlignmentTable.SelectionType = 'row';
            view.AlignmentTable.CellSelectionCallback = @(~, ~) view.call_registrar(RegisterEvent.SelectionAlignmentTable);
            view.AlignmentTable.Multiselect = 'off';
            view.AlignmentTable.Layout.Row = 1;
            view.AlignmentTable.Layout.Column = 1;

            % Create BottomGrid
            view.BottomGrid = uigridlayout(view.MainGrid);
            view.BottomGrid.ColumnWidth = {'1x', '1x'};
            view.BottomGrid.RowHeight = {'1x'};
            view.BottomGrid.Padding = [1 1 1 1];
            view.BottomGrid.Layout.Row = 2;
            view.BottomGrid.Layout.Column = 1;

            % AtlasPanel
            view.AtlasPanel = uipanel(view.BottomGrid);
            view.AtlasPanel.Layout.Row = 1;
            view.AtlasPanel.Layout.Column = 1;

            % Create AtlasGrid
            view.AtlasGrid = uigridlayout(view.AtlasPanel);
            view.AtlasGrid.ColumnWidth = {'1x'};
            view.AtlasGrid.RowHeight = {'1x', '8x', '1x'};
            view.AtlasGrid.Padding = [1 1 1 1];

            % Create AtlasButtonGrid
            view.AtlasButtonGrid = uigridlayout(view.AtlasGrid);
            view.AtlasButtonGrid.ColumnWidth = {'1x', '1x'};
            view.AtlasButtonGrid.RowHeight = {'1x'};
            view.AtlasButtonGrid.RowHeight = {'1x'};
            view.AtlasButtonGrid.Padding = [1 1 1 1];
            view.AtlasButtonGrid.Layout.Row = 1;
            view.AtlasButtonGrid.Layout.Column = 1;

            % Create CycleOrientationButton
            view.CycleOrientationButton = uibutton(view.AtlasButtonGrid, 'push');
            view.CycleOrientationButton.ButtonPushedFcn = @(~, ~) view.call_registrar(RegisterEvent.ButtonCycleOrientation);
            view.CycleOrientationButton.Layout.Row = 1;
            view.CycleOrientationButton.Layout.Column = 1;
            view.CycleOrientationButton.Text = 'Atlas Orientation';

            % Create AtlasSliceAxes
            view.AtlasSliceAxes = uiaxes(view.AtlasGrid);
            view.AtlasSliceAxes.XTick = [];
            view.AtlasSliceAxes.YTick = [];
            view.AtlasSliceAxes.Layout.Row = 2;
            view.AtlasSliceAxes.Layout.Column = 1;

            % Create AtlasSliceSlider
            view.AtlasSliceSlider = uislider(view.AtlasGrid);
            view.AtlasSliceSlider.Limits = [1 view.Atlas.Size(3)];
            view.AtlasSliceSlider.MajorTicks = [];
            view.AtlasSliceSlider.ValueChangingFcn = @(~, e) view.call_registrar(RegisterEvent.SliderAtlasSlice, e.Value);
            view.AtlasSliceSlider.ValueChangedFcn = @(~, e) view.call_registrar(RegisterEvent.SliderStop, e.Value);
            view.AtlasSliceSlider.MinorTicks = [];
            view.AtlasSliceSlider.Layout.Row = 3;
            view.AtlasSliceSlider.Layout.Column = 1;
            view.AtlasSliceSlider.FontSize = 8;
            view.AtlasSliceSlider.Value = view.Atlas.Size(3) / 2;

            % HistologyPanel
            view.HistologyPanel = uipanel(view.BottomGrid);
            view.HistologyPanel.Layout.Row = 1;
            view.HistologyPanel.Layout.Column = 2;

            % Create HistologyGrid
            view.HistologyGrid = uigridlayout(view.HistologyPanel);
            view.HistologyGrid.ColumnWidth = {'1x'};
            view.HistologyGrid.RowHeight = {'1x', '8x', '1x'};
            view.HistologyGrid.Padding = [1 1 1 1];

            % Create HistologyButtonGrid
            view.HistologyButtonGrid = uigridlayout(view.HistologyGrid);
            view.HistologyButtonGrid.ColumnWidth = {'1x', '1x'};
            view.HistologyButtonGrid.RowHeight = {'1x'};
            view.HistologyButtonGrid.Padding = [1 1 1 1];
            view.HistologyButtonGrid.Layout.Row = 1;
            view.HistologyButtonGrid.Layout.Column = 1;

            % Create AlignColorButton
            view.AlignColorButton = uibutton(view.HistologyButtonGrid, 'push');
            view.AlignColorButton.ButtonPushedFcn = @(~, ~) view.call_registrar(RegisterEvent.ButtonAlignColor);
            view.AlignColorButton.Layout.Row = 1;
            view.AlignColorButton.Layout.Column = 1;
            view.AlignColorButton.Text = 'Automatic Registration';

            % Create AlignControlButton
            view.AlignControlButton = uibutton(view.HistologyButtonGrid, 'push');
            view.AlignControlButton.ButtonPushedFcn = @(~, ~) view.call_registrar(RegisterEvent.ButtonAlignControl);
            view.AlignControlButton.Layout.Row = 1;
            view.AlignControlButton.Layout.Column = 2;
            view.AlignControlButton.Text = 'C.P. Registration';

            % Create HistSliceAxes
            view.HistSliceAxes = uiaxes(view.HistologyGrid);
            view.HistSliceAxes.XTick = [];
            view.HistSliceAxes.YTick = [];
            view.HistSliceAxes.Layout.Row = 2;
            view.HistSliceAxes.Layout.Column = 1;

            % Create HistologyButtonGrid
            view.HistologyButtonGrid2 = uigridlayout(view.HistologyGrid);
            view.HistologyButtonGrid2.ColumnWidth = {'1x', '1x'};
            view.HistologyButtonGrid2.RowHeight = {'1x'};
            view.HistologyButtonGrid2.Padding = [1 1 1 1];
            view.HistologyButtonGrid2.Layout.Row = 3;
            view.HistologyButtonGrid2.Layout.Column = 1;

            % Create ToggleOverlayButton
            view.ToggleOverlayButton = uibutton(view.HistologyButtonGrid2, 'push');
            view.ToggleOverlayButton.ButtonPushedFcn = @(~, ~) view.call_registrar(RegisterEvent.ButtonToggleOverlay);
            view.ToggleOverlayButton.Layout.Row = 1;
            view.ToggleOverlayButton.Layout.Column = 1;
            view.ToggleOverlayButton.Text = 'Hide Overlay';

            % Create RotateButton
            view.RotateButton = uibutton(view.HistologyButtonGrid2, 'push');
            view.RotateButton.ButtonPushedFcn = @(~, ~) view.call_registrar(RegisterEvent.ButtonRotateImage);
            view.RotateButton.Layout.Row = 1;
            view.RotateButton.Layout.Column = 2;
            view.RotateButton.Text = 'Rotate Image';

            imshow(view.Atlas.ReferenceAtlas(:, :, view.Atlas.Size(3) / 2), 'Parent', view.AtlasSliceAxes);
        end

    end

end