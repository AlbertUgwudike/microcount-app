classdef HomeView < Component

    properties ( Access = private )
        Listener(:, 1) event.listener {mustBeScalarOrEmpty}
        MainGrid
        LoadWorkspaceButton
        CreateWorkspaceButton
        CurrentWorkspaceLabel
        CurrentWorkspaceName
    end

    methods

        function obj = HomeView(model, controller, namedArgs)

            arguments
                model Model
                controller HomeController
                namedArgs.?HomeView 
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
            disp("HomeView Update!")
        end

    end

    methods ( Access = protected ) 

        function update(view) 
            if ~isempty(view.Model.WS)
                view.CurrentWorkspaceName.Text = view.Model.WS.DirName;
            end
        end

        function setup(view) 

            % Create MainGrid
            view.MainGrid = uigridlayout(view);
            view.MainGrid.ColumnWidth = {'0.25x', '1x', '0.25x'};
            view.MainGrid.RowHeight = {'1.5x', '1x', '1x', '0.5x', '0.5x', '0.5x', '1.5x'};

            % Create LoadWorkspaceButton
            view.LoadWorkspaceButton = uibutton(view.MainGrid, 'push');
            view.LoadWorkspaceButton.ButtonPushedFcn = @(~, ~) view.Contr.handle_event(HomeEvent.ButtonLoadWorkspace);
            view.LoadWorkspaceButton.FontSize = 24;
            view.LoadWorkspaceButton.Layout.Row = 3;
            view.LoadWorkspaceButton.Layout.Column = 2;
            view.LoadWorkspaceButton.Text = 'Load Workspace';

            % Create CreateWorkspaceButton
            view.CreateWorkspaceButton = uibutton(view.MainGrid, 'push');
            view.CreateWorkspaceButton.ButtonPushedFcn = @(~, ~) view.Contr.handle_event(HomeEvent.ButtonCreateWorkspace);
            view.CreateWorkspaceButton.FontSize = 24;
            view.CreateWorkspaceButton.Layout.Row = 2;
            view.CreateWorkspaceButton.Layout.Column = 2;
            view.CreateWorkspaceButton.Text = 'Create Workspace';
            
            % Create CurrentWorkspaceLabel
            workspace_label = uilabel(view.MainGrid);
            workspace_label.HorizontalAlignment = 'center';
            workspace_label.FontSize = 18;
            workspace_label.Layout.Row = 5;
            workspace_label.Layout.Column = 2;
            workspace_label.Text = 'Current Workspace';
            
            % Create CurrentWorkspaceName
            view.CurrentWorkspaceName = uilabel(view.MainGrid);
            view.CurrentWorkspaceName.HorizontalAlignment = 'center';
            view.CurrentWorkspaceName.Layout.Row = 6;
            view.CurrentWorkspaceName.Layout.Column = 2;
            view.CurrentWorkspaceName.Text = 'None Selected';

        end

    end

end