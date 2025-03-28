classdef HomeView < Component

    properties
        MainGrid
        LoadWorkspaceButton
        CreateWorkspaceButton
        CurrentWorkspaceName
    end

    methods

        function obj = HomeView(parent)

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
            view.MainGrid.ColumnWidth = {'0.25x', '1x', '0.25x'};
            view.MainGrid.RowHeight = {'1.5x', '1x', '1x', '0.5x', '0.5x', '0.5x', '1.5x'};

            % Create LoadWorkspaceButton
            view.LoadWorkspaceButton = uibutton(view.MainGrid, 'push');
            view.LoadWorkspaceButton.ButtonPushedFcn = @(~, ~) view.call_registrar(HomeEvent.ButtonLoadWorkspace);
            view.LoadWorkspaceButton.FontSize = 24;
            view.LoadWorkspaceButton.Layout.Row = 3;
            view.LoadWorkspaceButton.Layout.Column = 2;
            view.LoadWorkspaceButton.Text = 'Load Workspace';

            % Create CreateWorkspaceButton
            view.CreateWorkspaceButton = uibutton(view.MainGrid, 'push');
            view.CreateWorkspaceButton.ButtonPushedFcn = @(~, ~) view.call_registrar(HomeEvent.ButtonCreateWorkspace);
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