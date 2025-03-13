classdef SelectImagesView < Component

    properties ( Access = private )
        WorkspaceListener(:, 1) event.listener {mustBeScalarOrEmpty}
        ImageSetListener(:, 1) event.listener {mustBeScalarOrEmpty}

        MainGrid
        SelectAllButton
        RemoveButton
        ConvertandDownsampleButton
        AddImagesButton
        ImageSetTable
        SaveButton
    end

    methods

        function obj = SelectImagesView(model, controller, namedArgs)

            arguments
                model Model
                controller SelectImagesController
                namedArgs.?SelectImagesView 
            end 

            obj@Component(model, controller) 

            obj.WorkspaceListener = listener(obj.Model, "WorkspaceUpdated", @obj.on_workspace_updated);       

            set(obj, namedArgs) 
        end 

    end 

    methods ( Access = private ) 

        function on_workspace_updated(view, ~, ~) 
            disp("SelectImagesView::on_workspace_updated")
            
            img_mds = view.Model.WS.Images;
            source_fns  = [img_mds.SourceFn];
            converted   = [img_mds.Converted];
            downsampled = [img_mds.DownSampled];
            new_data = [source_fns' converted' downsampled'];
            view.ImageSetTable.Data = new_data;
        end

    end

    methods ( Access = protected ) 

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
            view.ConvertandDownsampleButton.ButtonPushedFcn = @(~, ~) view.Contr.handle_event(SelectImagesEvent.ButtonConvertDownsample);
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

            % Create SaveButton
            view.SaveButton = uibutton(view.MainGrid, 'push');
            view.SaveButton.ButtonPushedFcn = @(~, ~) view.Contr.handle_event(AppEvent.ButtonSave);
            view.SaveButton.Layout.Row = 8;
            view.SaveButton.Layout.Column = 1;
            view.SaveButton.Text = 'Save';

        end

    end

end