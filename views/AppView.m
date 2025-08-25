classdef AppView < Component

    properties ( Access = public )
        HomeTab matlab.ui.container.Tab
        SelectTab matlab.ui.container.Tab
        RegisterTab matlab.ui.container.Tab
        RegionsTab matlab.ui.container.Tab
        SelectAlgoTab matlab.ui.container.Tab
        AnalyseTab matlab.ui.container.Tab
        TabGroup matlab.ui.container.TabGroup
    end

    methods

        function obj = AppView(parent)

            arguments
                parent
            end

            obj@Component(parent) 
        end 

    end 

    methods ( Access = protected ) 

        function setup(view) 
            view.TabGroup = uitabgroup('Parent', view);
            view.TabGroup.Units = "normalized";
            view.TabGroup.Position = [0, 0, 1.00000001, 1.00000001];
            view.TabGroup.SelectionChangedFcn = @(~, ~) view.call_registrar(AppEvent.TabSelected);

            view.HomeTab = uitab(view.TabGroup);
            view.HomeTab.Title = 'Home';

            view.SelectTab = uitab(view.TabGroup);
            view.SelectTab.Title = 'Select Images';

            view.RegisterTab = uitab(view.TabGroup);
            view.RegisterTab.Title = 'Register';

            view.RegionsTab = uitab(view.TabGroup);
            view.RegionsTab.Title = 'Select Regions';

            view.AnalyseTab = uitab(view.TabGroup);
            view.AnalyseTab.Title = 'Analyse';
        end

    end

end