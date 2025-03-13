classdef AppView < Component

    properties ( Access = private )
        HomeTab matlab.ui.container.Tab
        SelectTab matlab.ui.container.Tab
        RegisterTab matlab.ui.container.Tab
        TabGroup matlab.ui.container.TabGroup
        Listener(:, 1) event.listener {mustBeScalarOrEmpty}
    end

    methods

        function obj = AppView(model, controller, namedArgs)

            arguments
                model Model
                controller AppController
                namedArgs.?AppView 
            end 

            obj@Component(model, controller) 
            obj.Listener = listener(obj.Model, "WorkspaceUpdated", @obj.on_workspace_updated);

            % Set any user-specified properties.
            set( obj, namedArgs ) 
        end 

    end 

    methods ( Access = private ) 

        function on_workspace_updated(~, ~, ~) 
            disp("AppView::on_workspace_updated")
        end

    end

    methods ( Access = protected ) 

        function setup(view) 
            view.TabGroup = uitabgroup('Parent', view);
            view.TabGroup.Units = "normalized";
            view.TabGroup.Position = [0, 0, 1.00000001, 1.00000001];

            view.HomeTab = uitab(view.TabGroup);
            view.HomeTab.Title = 'Home';
            hc = HomeController(view.Model);
            HomeView(view.Model, hc, 'Parent', view.HomeTab);

            view.SelectTab = uitab(view.TabGroup);
            view.SelectTab.Title = 'Select Images';
            sic = SelectImagesController(view.Model);
            SelectImagesView(view.Model, sic, 'Parent', view.SelectTab);

            view.RegisterTab = uitab(view.TabGroup);
            view.RegisterTab.Title = 'Register';
            rc = RegisterController(view.Model);
            RegisterView(view.Model, rc, 'Parent', view.RegisterTab);
        end

    end

end