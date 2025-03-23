classdef RegionsView < Component

    properties ( Access = public )
        MainGrid
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
            view.MainGrid.RowHeight = {'0.5x', '1.4x'};

            % Create ImageTable
            view.ImageTable = uitable(view.MainGrid);
            view.ImageTable.ColumnName = {'Image'; 'HI'; 'HY'; 'TH'; 'SS'; 'AU'; 'AM'; 'HI'; 'HY'; 'TH'; 'SS'; 'AU'; 'AM'};
            view.ImageTable.ColumnWidth = {'8x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            view.ImageTable.RowName = {};
            view.ImageTable.Layout.Row = 1;
            view.ImageTable.Layout.Column = 1;
            view.ImageTable.Multiselect = 'off';
            view.ImageTable.CellSelectionCallback = @(~, ~) view.call_registrar(RegionsEvent.SelectionImageTable);
            view.ImageTable.DoubleClickedFcn = @(~, ~) view.call_registrar(RegionsEvent.RegionSelection);

            % Create HistologyImage
            view.HistologyImage = uiimage(view.MainGrid);
            view.HistologyImage.Layout.Row = 2;
            view.HistologyImage.Layout.Column = 1;

        end

    end

end