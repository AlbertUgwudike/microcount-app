classdef RegisterView < Component

    properties ( Access = private )
        WorkspaceListener(:, 1) event.listener {mustBeScalarOrEmpty}
        RegistrationListener(:, 1) event.listener {mustBeScalarOrEmpty}

        MainGrid
        TopGrid
        AlignmentTable
        ButtonGrid
        ToggleOverlayButton
        AlignColorButton
        AlignControlButton
        SliderGrid
        AtlasSliceSlider
        BottomGrid
        AtlasSliceAxes
        HistSliceAxes
    end

    methods

        function obj = RegisterView(model, controller, namedArgs)

            arguments
                model Model
                controller RegisterController
                namedArgs.?RegisterView 
            end 

            obj@Component(model, controller) 

            obj.WorkspaceListener = listener(obj.Model, "WorkspaceUpdated", @obj.on_workspace_updated);

            set(obj, namedArgs) 
        end 

    end 

    methods ( Access = private ) 

        function on_workspace_updated(view, ~, ~) 
            disp("RegisterView::on_workspace_updated")

            % Table 
            down_idx  = [view.Model.WS.Images.DownSampled];
            down_imgs = view.Model.WS.Images(down_idx);
            new_data  = [[down_imgs.SourceFn]' [down_imgs.Aligned]'];
            view.AlignmentTable.Data = new_data;

            % Slider Position

            % Alignment Hexs

            % Overlay
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
            view.AlignmentTable.CellSelectionCallback = @(~, ~) view.Contr.handle_event(RegisterEvent.SelectionAlignmentTable);
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
            view.ButtonGrid.ColumnWidth = {'1x', '1x', '1x'};
            view.ButtonGrid.RowHeight = {'1x'};
            view.ButtonGrid.Layout.Row = 1;
            view.ButtonGrid.Layout.Column = 1;

            % Create AlignColorButton
            view.AlignColorButton = uibutton(view.ButtonGrid, 'push');
            view.AlignColorButton.ButtonPushedFcn = @(~, ~) view.Contr.handle_event(RegisterEvent.ButtonAlignColor);
            view.AlignColorButton.Layout.Row = 1;
            view.AlignColorButton.Layout.Column = 1;
            view.AlignColorButton.Text = 'Align Color';

            % Create AlignControlButton
            view.AlignControlButton = uibutton(view.ButtonGrid, 'push');
            view.AlignControlButton.ButtonPushedFcn = @(~, ~) view.Contr.handle_event(RegisterEvent.ButtonAlignControl);
            view.AlignControlButton.Layout.Row = 1;
            view.AlignControlButton.Layout.Column = 2;
            view.AlignControlButton.Text = 'Align Control';

            % Create ToggleOverlayButton
            view.ToggleOverlayButton = uibutton(view.ButtonGrid, 'push');
            view.ToggleOverlayButton.ButtonPushedFcn = @(~, ~) view.Contr.handle_event(RegisterEvent.ButtonToggleOverlay);
            view.ToggleOverlayButton.Layout.Row = 1;
            view.ToggleOverlayButton.Layout.Column = 3;
            view.ToggleOverlayButton.Text = 'Toggle Overlay';

            % Create AtlasSliceSlider
            view.AtlasSliceSlider = uislider(view.SliderGrid);
            atlas_sz = size(view.Model.Atlas.ReferenceAtlas);
            view.AtlasSliceSlider.Limits = [1 atlas_sz(3)];
            view.AtlasSliceSlider.MajorTicks = [1 atlas_sz(3)];
            view.AtlasSliceSlider.ValueChangingFcn = @(~, ~) view.Contr.handle_event(RegisterEvent.SliderAtlasSlice);
            view.AtlasSliceSlider.MinorTicks = [];
            view.AtlasSliceSlider.Layout.Row = 2;
            view.AtlasSliceSlider.Layout.Column = 1;
            view.AtlasSliceSlider.FontSize = 8;
            view.AtlasSliceSlider.Value = atlas_sz(3) / 2;

        end

    end

end