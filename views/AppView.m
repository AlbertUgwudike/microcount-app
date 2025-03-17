classdef AppView < Component

    properties ( Access = public )
        HomeTab matlab.ui.container.Tab
        SelectTab matlab.ui.container.Tab
        RegisterTab matlab.ui.container.Tab
        TabGroup matlab.ui.container.TabGroup
    end

    methods

        function obj = AppView(namedArgs)

            arguments
                namedArgs.?AppView 
            end

            obj@Component() 
            set(obj, namedArgs)
        end 

    end 

    methods ( Access = protected ) 

        function setup(view) 
            view.TabGroup = uitabgroup('Parent', view);
            view.TabGroup.Units = "normalized";
            view.TabGroup.Position = [0, 0, 1.00000001, 1.00000001];

            view.HomeTab = uitab(view.TabGroup);
            view.HomeTab.Title = 'Home';

            view.SelectTab = uitab(view.TabGroup);
            view.SelectTab.Title = 'Select Images';

            view.RegisterTab = uitab(view.TabGroup);
            view.RegisterTab.Title = 'Register';
        end

    end

end