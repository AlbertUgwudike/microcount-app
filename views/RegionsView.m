classdef RegionsView < Component

    properties ( Access = public )
        MainGrid
        LabelGrid
        LeftLabel
        RightLabel
        ImageTable
        HistologyImage
        Atlas Atlas = Atlas()
    end

    methods

        function obj = RegionsView(namedArgs)

            arguments
                namedArgs.?RegionsView 
            end

            obj@Component() 
            set(obj, namedArgs)
        end 

    end 

    methods ( Access = protected ) 

        function setup(view) 

            % Create MainGrid
            view.MainGrid = uigridlayout(view);
            view.MainGrid.ColumnWidth = {'1x'};
            view.MainGrid.RowHeight = {'0.15x', '0.6x', '1.3x'};
            view.MainGrid.RowSpacing = 5;

            % Create ImageTable
            view.ImageTable = uitable(view.MainGrid);
            view.ImageTable.ColumnName = {'Images'; ''; 'HIP'; 'HY'; 'TH'; 'SS'; 'AU'; 'AM'; ''; 'HIP'; 'HY'; 'TH'; 'SS'; 'AU'; 'AM'};
            view.ImageTable.ColumnWidth = {'60x', '1x', '10x', '10x', '10x', '10x', '10x', '10x', '1x', '10x', '10x', '10x', '10x', '10x', '10x'};
            view.ImageTable.RowName = {};
            view.ImageTable.Layout.Row = 2;
            view.ImageTable.Layout.Column = 1;
            view.ImageTable.Multiselect = 'off';
            view.ImageTable.CellSelectionCallback = @(~, ~) view.call_registrar(RegionsEvent.SelectionImageTable);
            view.ImageTable.DoubleClickedFcn = @(~, ~) view.call_registrar(RegionsEvent.RegionSelection);

            % Create LabelGrid
            view.LabelGrid = uigridlayout(view.MainGrid);
            view.LabelGrid.ColumnWidth = {'1x', '1x', '1x'};
            view.LabelGrid.RowHeight = {'1x'};
            view.LabelGrid.ColumnSpacing = 1;
            view.LabelGrid.RowSpacing = 1;
            view.LabelGrid.Layout.Row = 1;
            view.LabelGrid.Layout.Column = 1;

            % Create LeftLabel
            view.LeftLabel = uilabel(view.LabelGrid);
            view.LeftLabel.HorizontalAlignment = 'center';
            view.LeftLabel.FontSize = 18;
            view.LeftLabel.Layout.Row = 1;
            view.LeftLabel.Layout.Column = 2;
            view.LeftLabel.Text = 'Left';

            % Create RightLabel
            view.RightLabel = uilabel(view.LabelGrid);
            view.RightLabel.HorizontalAlignment = 'center';
            view.RightLabel.FontSize = 18;
            view.RightLabel.Layout.Row = 1;
            view.RightLabel.Layout.Column = 3;
            view.RightLabel.Text = 'Right';

            % Create Image
            view.HistologyImage = uiimage(view.MainGrid);
            view.HistologyImage.Layout.Row = 3;
            view.HistologyImage.Layout.Column = 1;

        end

    end

end