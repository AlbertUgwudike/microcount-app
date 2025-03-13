classdef SelectImagesView < Component

    properties ( Access = private )
        Listener(:, 1) event.listener {mustBeScalarOrEmpty}
        MainGrid
        SelectAllButton
        RemoveButton
        ConvertandDownsampleButton
        AddImagesButton
        ImageSetTable
    end

    methods

        function obj = SelectImagesView(model, controller, namedArgs)

            arguments
                model Model
                controller SelectImagesController
                namedArgs.?SelectImagesView 
            end 

            obj@Component(model, controller) 

            % Listen for changes to the data. 
            obj.Listener = addlistener( obj.Model, ... 
                "DataChanged", @obj.onDataChanged );

            % Set any user-specified properties.
            set( obj, namedArgs ) 

            % Refresh the view. 
            onDataChanged( obj ) 

        end 

    end 

    methods ( Access = private ) 

        function onDataChanged(view, ~, ~) 
            disp("SelectImagesView Update!")
        end

    end

    methods ( Access = protected ) 

        function update(view) 
            
        end

        function setup(view) 

            % Create MainGrid
            view.MainGrid = uigridlayout(view);
            view.MainGrid.ColumnWidth = {'1x', '1x', '1x', '1x'};
            view.MainGrid.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};

            % Create SelectAllButton
            view.SelectAllButton = uibutton(view.MainGrid, 'push');
            view.SelectAllButton.ButtonPushedFcn = @(~, ~) view.Contr.handle_event(SelectImagesEvent.ButtonSelectAll);
            view.SelectAllButton.Layout.Row = 2;
            view.SelectAllButton.Layout.Column = 2;
            view.SelectAllButton.Text = 'Select All';

            % Create RemoveButton
            view.RemoveButton = uibutton(view.MainGrid, 'push');
            view.RemoveButton.ButtonPushedFcn = @(~, ~) view.Contr.handle_event(SelectImagesEvent.ButtonRemoveAll);
            view.RemoveButton.Layout.Row = 2;
            view.RemoveButton.Layout.Column = 3;
            view.RemoveButton.Text = 'Remove';

            % Create ConvertandDownsampleButton
            view.ConvertandDownsampleButton = uibutton(view.MainGrid, 'push');
            view.ConvertandDownsampleButton.ButtonPushedFcn = @(~, ~) @(~, ~) view.Contr.handle_event(SelectImagesEvent.ButtonConvertDownsample);
            view.ConvertandDownsampleButton.Layout.Row = 2;
            view.ConvertandDownsampleButton.Layout.Column = 4;
            view.ConvertandDownsampleButton.Text = 'Convert and Downsample';

            % Create AddImagesButton
            view.AddImagesButton = uibutton(view.MainGrid, 'push');
            view.AddImagesButton.ButtonPushedFcn = @(~, ~) view.Contr.handle_event(SelectImagesEvent.ButtonAddImages);
            view.AddImagesButton.Layout.Row = 2;
            view.AddImagesButton.Layout.Column = 1;
            view.AddImagesButton.Text = 'Add Images';

            % Create ImageSetTable
            view.ImageSetTable = uitable(view.MainGrid);
            view.ImageSetTable.ColumnName = {'Name'; 'Converted'; 'Downsampled'};
            view.ImageSetTable.ColumnWidth = {'2x', '1x', '1x'};
            view.ImageSetTable.RowName = {};
            view.ImageSetTable.SelectionType = 'row';
            view.ImageSetTable.Layout.Row = [3 7];
            view.ImageSetTable.Layout.Column = [1 4];

        end

    end

end