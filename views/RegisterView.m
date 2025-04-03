classdef RegisterView < Component

    properties ( Access = public )
        MainGrid
        TopGrid
        AlignmentTable
        ButtonGrid
        ToggleOverlayButton
        RotateButton
        CycleOrientationButton
        AlignColorButton
        AlignControlButton
        SliderGrid
        AtlasSliceSlider
        BottomGrid
        AtlasSliceAxes
        AtlasHex
        HistSliceAxes
        HistHex

        Atlas Atlas = Atlas()

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
            view.MainGrid.RowHeight = {'0.5x', '0.4x', '1x'};
            
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
            view.BottomGrid.RowHeight = {'1x'};
            view.BottomGrid.Layout.Row = 3;
            view.BottomGrid.Layout.Column = 1;

            % Create AtlasSliceAxes
            view.AtlasSliceAxes = uiaxes(view.BottomGrid);
            view.AtlasSliceAxes.XTick = [];
            view.AtlasSliceAxes.YTick = [];
            view.AtlasSliceAxes.Layout.Row = 1;
            view.AtlasSliceAxes.Layout.Column = 1;

            % Create HistSliceAxes
            view.HistSliceAxes = uiaxes(view.BottomGrid);
            view.HistSliceAxes.XTick = [];
            view.HistSliceAxes.YTick = [];
            view.HistSliceAxes.Layout.Row = 1;
            view.HistSliceAxes.Layout.Column = 2;

            % Create SliderGrid
            view.SliderGrid = uigridlayout(view.MainGrid);
            view.SliderGrid.ColumnWidth = {'1x'};
            view.SliderGrid.RowHeight = {'0.75x', '0.5x'};
            view.SliderGrid.Layout.Row = 2;
            view.SliderGrid.Layout.Column = 1;

            % Create ButtonGrid
            view.ButtonGrid = uigridlayout(view.SliderGrid);
            view.ButtonGrid.ColumnWidth = {'1x', '1x', '1x', '1x'};
            view.ButtonGrid.RowHeight = {'1x'};
            view.ButtonGrid.Layout.Row = 1;
            view.ButtonGrid.Layout.Column = 1;

            % Create AlignColorButton
            view.AlignColorButton = uibutton(view.ButtonGrid, 'push');
            view.AlignColorButton.ButtonPushedFcn = @(~, ~) view.call_registrar(RegisterEvent.ButtonAlignColor);
            view.AlignColorButton.Layout.Row = 1;
            view.AlignColorButton.Layout.Column = 1;
            view.AlignColorButton.Text = 'Align Color';

            % Create AlignControlButton
            view.AlignControlButton = uibutton(view.ButtonGrid, 'push');
            view.AlignControlButton.ButtonPushedFcn = @(~, ~) view.call_registrar(RegisterEvent.ButtonAlignControl);
            view.AlignControlButton.Layout.Row = 1;
            view.AlignControlButton.Layout.Column = 2;
            view.AlignControlButton.Text = 'Align Control';

            % Create ToggleOverlayButton
            view.ToggleOverlayButton = uibutton(view.ButtonGrid, 'push');
            view.ToggleOverlayButton.ButtonPushedFcn = @(~, ~) view.call_registrar(RegisterEvent.ButtonToggleOverlay);
            view.ToggleOverlayButton.Layout.Row = 1;
            view.ToggleOverlayButton.Layout.Column = 3;
            view.ToggleOverlayButton.Text = 'Toggle Overlay';

            % Create RotateButton
            view.RotateButton = uibutton(view.ButtonGrid, 'push');
            view.RotateButton.ButtonPushedFcn = @(~, ~) view.call_registrar(RegisterEvent.ButtonRotateImage);
            view.RotateButton.Layout.Row = 1;
            view.RotateButton.Layout.Column = 4;
            view.RotateButton.Text = 'Rotate';

             % Create CycleOrientationButton
            view.CycleOrientationButton = uibutton(view.ButtonGrid, 'push');
            view.CycleOrientationButton.ButtonPushedFcn = @(~, ~) view.call_registrar(RegisterEvent.ButtonCycleOrientation);
            view.CycleOrientationButton.Layout.Row = 1;
            view.CycleOrientationButton.Layout.Column = 5;
            view.CycleOrientationButton.Text = 'Atlas Orientation';

            % Create AtlasSliceSlider
            view.AtlasSliceSlider = uislider(view.SliderGrid);
            view.AtlasSliceSlider.Limits = [1 view.Atlas.Size(3)];
            view.AtlasSliceSlider.MajorTicks = [1 view.Atlas.Size(3)];
            view.AtlasSliceSlider.ValueChangingFcn = @(~, e) view.call_registrar(RegisterEvent.SliderAtlasSlice, e.Value);
            view.AtlasSliceSlider.ValueChangedFcn = @(~, e) view.call_registrar(RegisterEvent.SliderStop, e.Value);
            view.AtlasSliceSlider.MinorTicks = [];
            view.AtlasSliceSlider.Layout.Row = 2;
            view.AtlasSliceSlider.Layout.Column = 1;
            view.AtlasSliceSlider.FontSize = 8;
            view.AtlasSliceSlider.Value = view.Atlas.Size(3) / 2;
            imshow(view.Atlas.ReferenceAtlas(:, :, view.Atlas.Size(3) / 2), 'Parent', view.AtlasSliceAxes);

        end

    end

end