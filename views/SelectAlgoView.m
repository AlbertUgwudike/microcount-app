classdef SelectAlgoView < Component

    properties
        MainGrid matlab.ui.container.GridLayout
        ButtonGroup
        MicroFluorButton
        MicroDabButton
        AstroFluorButton
        AstroDabButton
    end

    methods

        function obj = SelectAlgoView(parent)

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
            view.MainGrid.ColumnWidth = {'1x', '4x', '1x'};
            view.MainGrid.RowHeight = {'1x', '4x', '1x'};

            % Create ButtonGroup
            view.ButtonGroup = uibuttongroup(view.MainGrid);
            view.ButtonGroup.Title = 'Select Algorithm';
            view.ButtonGroup.Layout.Row = 2;
            view.ButtonGroup.Layout.Column = 2;
            view.ButtonGroup.SelectionChangedFcn = @(~, ~) view.call_registrar(SelectAlgoEvent.AlgoSelected);

            % Create MicroFluorButton
            view.MicroFluorButton = uitogglebutton(view.ButtonGroup);
            view.MicroFluorButton.Text = 'Fluorescent Microglia';
            view.MicroFluorButton.Position = [11 113 100 22];
            view.MicroFluorButton.UserData = Algorithm.MicroFluor;
            view.MicroFluorButton.Value = true;

            % Create MicroDabButton
            view.MicroDabButton = uitogglebutton(view.ButtonGroup);
            view.MicroDabButton.Text = 'DAB-Stained Microglia';
            view.MicroDabButton.Position = [11 92 100 22];
            view.MicroDabButton.UserData = Algorithm.MicroDab;

            % Create AstroFluorButton
            view.AstroFluorButton = uitogglebutton(view.ButtonGroup);
            view.AstroFluorButton.Text = 'Fluorescent Astrocytes';
            view.AstroFluorButton.Position = [11 71 100 22];
            view.AstroFluorButton.UserData = Algorithm.AstroFluor;

            % Create AstroDabButton
            view.AstroDabButton = uitogglebutton(view.ButtonGroup);
            view.AstroDabButton.Text = 'DAB-Stained Astrocytes';
            view.AstroDabButton.Position = [11 50 100 22];
            view.AstroDabButton.UserData = Algorithm.AstroDab;

        end

    end

end