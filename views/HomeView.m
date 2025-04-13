classdef HomeView < Component

    properties
        MainGrid matlab.ui.container.GridLayout
        LogoImage matlab.ui.control.Image
        Title matlab.ui.control.Label
        ButtonGrid
        LoadWorkspaceButton
        CreateWorkspaceButton
        LabelGrid
        PanelGrid
        WorkspacePanel
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
            view.MainGrid.ColumnWidth = {'1x'};
            view.MainGrid.RowHeight = {'0.15x', '0.5x', '0.1x', '0.1x'};

            % Create Title
            view.Title = uilabel(view.MainGrid);
            view.Title.Text = "Microcount";
            view.Title.FontSize = 62;
            view.Title.FontWeight = 'bold';
            view.Title.HorizontalAlignment = 'center';
            view.Title.Layout.Row = 1;
            view.Title.Layout.Column = 1;


            this_fn = mfilename('fullpath');
            [curr_dir, ~, ~] = fileparts(this_fn);
            logo_fn = sprintf("%s/../assets/microcount_logo.png", curr_dir);

            % Create LogoImage
            view.LogoImage = uiimage(view.MainGrid);
            view.LogoImage.ImageSource = logo_fn;
            view.LogoImage.Layout.Row = 2;
            view.LogoImage.Layout.Column = 1;

            % Create ButtonGrid
            view.ButtonGrid = uigridlayout(view.MainGrid);
            view.ButtonGrid.ColumnWidth = {'0.25x', '0.5x', '0.5x', '0.25x'};
            view.ButtonGrid.RowHeight = {'1x'};
            view.ButtonGrid.Layout.Row = 3;
            view.ButtonGrid.Layout.Column = 1;

            % Create LoadWorkspaceButton
            view.LoadWorkspaceButton = uibutton(view.ButtonGrid, 'push');
            view.LoadWorkspaceButton.ButtonPushedFcn = @(~, ~) view.call_registrar(HomeEvent.ButtonLoadWorkspace);
            view.LoadWorkspaceButton.FontSize = 24;
            view.LoadWorkspaceButton.Layout.Row = 1;
            view.LoadWorkspaceButton.Layout.Column = 2;
            view.LoadWorkspaceButton.Text = 'Load Workspace';

            % Create CreateWorkspaceButton
            view.CreateWorkspaceButton = uibutton(view.ButtonGrid, 'push');
            view.CreateWorkspaceButton.ButtonPushedFcn = @(~, ~) view.call_registrar(HomeEvent.ButtonCreateWorkspace);
            view.CreateWorkspaceButton.FontSize = 24;
            view.CreateWorkspaceButton.Layout.Row = 1;
            view.CreateWorkspaceButton.Layout.Column = 3;
            view.CreateWorkspaceButton.Text = 'Create Workspace';

            % Create PanelGrid
            view.PanelGrid = uigridlayout(view.MainGrid);
            view.PanelGrid.ColumnWidth = {'0.25x', '1x', '0.25x'};
            view.PanelGrid.RowHeight = {'1x'};
            view.PanelGrid.Layout.Row = 4;
            view.PanelGrid.Layout.Column = 1;
            
            % Create WorkspacePanel
            view.WorkspacePanel = uipanel(view.PanelGrid);
            view.WorkspacePanel.Layout.Row = 1;
            view.WorkspacePanel.Layout.Column = 2;

            % Create LabelGrid
            view.LabelGrid = uigridlayout(view.WorkspacePanel);
            view.LabelGrid.ColumnWidth = {'1x'};
            view.LabelGrid.RowHeight = {'1x'};
            
            % Create CurrentWorkspaceName
            view.CurrentWorkspaceName = uilabel(view.LabelGrid);
            view.CurrentWorkspaceName.HorizontalAlignment = 'center';
            view.CurrentWorkspaceName.Layout.Row = 1;
            view.CurrentWorkspaceName.Layout.Column = 1;
            view.CurrentWorkspaceName.Text = 'No Workspace Selected';

        end

    end

end