classdef AppView < Component

    properties ( Access = private )
        HomeTab matlab.ui.container.Tab
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
            disp("AppView Update!")
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
            hv = HomeView(view.Model, hc, 'Parent', view.HomeTab);
        end

        function update( ~ ) 
            %UPDATE Update the view. This method is empty because there are 
            %no public properties of the view. 

        end

    end

end